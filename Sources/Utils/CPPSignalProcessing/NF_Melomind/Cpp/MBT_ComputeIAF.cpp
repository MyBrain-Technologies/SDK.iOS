//
//  MBT_ComputeIAF.cpp
//
//  Created by Fanny Grosselin on 14/09/2018.
//  Copyright (c) 2018 myBrain Technologies. All rights reserved.
//

#include "../Headers/MBT_ComputeIAF.h"


std::map<std::string, std::vector<double> > MBT_ComputeIAF(MBT_Matrix<double> signal, const double sampRate, const double IAFinf, const double IAFsup, std::vector<float> &histFreq)
{
    std::vector<double> tmpHistFreq(histFreq.begin(),histFreq.end());
    std::map<std::string, std::vector<double> > computeIAF;
    
    if ((signal.size().first > 0) & (signal.size().second > 0))
    {
        std::vector<double> IAF;
        IAF.assign(signal.size().first,0);
        std::vector<double> QF;
        QF.assign(signal.size().first,0);
        for (int channel=0; channel<signal.size().first; channel++)
        {
            //std::cout<<"Channel = "<<channel<<std::endl;
            std::vector<double> signal_ch = signal.row(channel);
            
            // Interpolate the outliers
            // -----------------------------------
            if (std::all_of(signal_ch.begin(), signal_ch.end(), [](double testNaN){return std::isnan(testNaN);}) )
            {
                IAF[channel] = nan(" ");
                QF[channel] = nan(" ");
            }
            else
            {
                // Do a linear interpolation of NaN values
                std::vector<double> n_x_notnan; // indexes of known values (n_x_notnan) (values != nan)
                std::vector<double> n_v_notnan; // values of known values (n_v_notnan) (values != nan)
                std::vector<double> n_xq_nan; // indexes of unknown values (n_xq_nan) (values == nan)
                for (unsigned int sig=0; sig<signal_ch.size(); sig++)
                {
                    if (std::isnan(signal_ch[sig]))
                    {
                        n_xq_nan.push_back(sig);
                    }
                    else
                    {
                        n_x_notnan.push_back(sig);
                        n_v_notnan.push_back(signal_ch[sig]);
                    }
                }
                std::vector<double> n_vq_nan = MBT_linearInterp(n_x_notnan, n_v_notnan, n_xq_nan);  // find the interpolated values (n_vq_nan)
                for (unsigned int signan=0; signan<n_xq_nan.size(); signan++)
                {
                    signal_ch[n_xq_nan[signan]] = n_vq_nan[signan];
                }
                
                signal_ch.erase(std::remove_if(signal_ch.begin(), signal_ch.end(),[](double testNaN){return std::isnan(testNaN);}),signal_ch.end()); // remove NaN values
                
                std::vector<double> signal_ch_withoutDC = RemoveDC(signal_ch); // Remove DC
                
                std::vector<double> freqBoundsBandPass;
                freqBoundsBandPass.assign(2,0);
                freqBoundsBandPass[0] = 2.0;
                freqBoundsBandPass[1] = 30.0;
                std::vector<double> tmp_outputBandpass = BandPassFilter(signal_ch_withoutDC,freqBoundsBandPass); // BandPass
                
                std::vector<double> tmp_Bounds = CalculateBounds(tmp_outputBandpass); // Find the bounds for outliers
                std::vector<double> dataWithoutOutliers = InterpolateOutliers(tmp_outputBandpass, tmp_Bounds); // Interpolate outliers
                
                if (std::all_of(dataWithoutOutliers.begin(), dataWithoutOutliers.end(), [](double testNaN){return std::isnan(testNaN);}) )
                {
                    IAF[channel] = nan(" ");
                    QF[channel] = nan(" ");
                }
                else
                {
                    
                    dataWithoutOutliers.erase(std::remove_if(dataWithoutOutliers.begin(), dataWithoutOutliers.end(),[](double testNaN){return std::isnan(testNaN);}),dataWithoutOutliers.end()); // remove NaN values
                    // -----------------------------------
                    
                    MBT_Matrix<double> signal_ch_mat(1,dataWithoutOutliers.size());
                    for (int m = 0; m<signal_ch_mat.size().second;m++)
                    {
                        signal_ch_mat(0,m) = dataWithoutOutliers[m];
                    }
                    
                    
                    MBT_PWelchComputer psd = MBT_PWelchComputer(signal_ch_mat, sampRate, "HAMMING",128,64,512); // Compute spectrum
                    std::vector<double> frequencies = psd.get_PSD(0); //Extract the frequencies for the psd
                    std::vector<double> channelPSD = psd.get_PSD(1);
                    
                    if (std::all_of(channelPSD.begin(), channelPSD.end(), [](double testNaN){return std::isnan(testNaN);}) )
                    {
                        IAF[channel] = nan(" ");
                        QF[channel] = nan(" ");
                    }
                    else
                    {
                        // Find the first index of the frequencies which is higher to 2Hz
                        // and find the last index of the frequencies which is lower to 30Hz
                        std::pair<int,int> truncBounds = MBT_frequencyBounds(frequencies, freqBoundsBandPass[0], freqBoundsBandPass[1]);
                        int n_f2 = truncBounds.first; // strictly higher
                        int n_f30 = truncBounds.second; // strictly lower
                        std::vector<double> trunc_frequencies(frequencies.begin()+n_f2,frequencies.begin()+n_f30+1);
                        std::vector<double> trunc_channelPSD(channelPSD.begin()+n_f2,channelPSD.begin()+n_f30+1);
                        
                        // BACKGROUND SPECTRAL NOISE
                        std::vector<double> noisePow = MBT_ComputeNoise(trunc_frequencies, trunc_channelPSD);
                        
                        // compute the difference between the observed spectrum and the estimated one
                        std::vector<double> logPSD = trunc_channelPSD; // copy trunc_channelPSD in y
                        std::transform(logPSD.begin(), logPSD.end(), logPSD.begin(), [](double p){ return 10*std::log10(p); });// apply 10*log10 on the vector containing the power values
                        
                        std::vector<double> difference = noisePow;
                        for (unsigned int di=0;di<noisePow.size();di++)
                        {
                            difference[di] = logPSD[di] - noisePow[di];
                            // only highlight the positive differences (maxima)
                            if (difference[di]<0)
                            {
                                difference[di]=0;
                            }
                        }
                        
                        // compute 1st derivative to detect the local maxima
                        int hstep = 1;
                        std::vector<double> d1 = derivative(difference, hstep);
                        
                        
                        // Find the last index of the frequencies which is lower or equal to IAFinf
                        // and find the first index of the frequencies which is higher or equal to IAFsup
                        std::pair<int,int> freqBounds = MBT_frequencyBounds(trunc_frequencies, IAFinf, IAFsup);
                        int lower_alpha = freqBounds.first-1;
                        int upper_alpha = freqBounds.second+1;
                        
                        // initialization of some variables
                        double mu_peakF = mean(tmpHistFreq);
                        double sigma_peakF = standardDeviation(tmpHistFreq);
                        std::vector<int> bin_index;
                        std::vector<double> zero_cross_freq, amp_difference;
                        
                        int cnt = 0;                                              // start counter at 0
                        for (int k = lower_alpha; k<upper_alpha; k++)             // step through frequency bins in alpha band (upper_band-1 because we compare k with k+1)
                        {
                            if((d1[k]==0.0 && d1[k+1]<0.0)||(d1[k]>0.0 && d1[k+1]<=0.0)) // look for switch from positive to negative derivative values (i.e. downward zero-crossing)
                            {
                                int maxim = k;
                                if (difference[k+1]>difference[k]) // ensure correct frequency bin is picked out (find larger of two values either side of crossing (in the smoothed signal))
                                {
                                    maxim = k+1;
                                }
                                cnt = cnt+1;                                             // advance counter by 1
                                bin_index.push_back(maxim);                              // keep bin index for later
                                zero_cross_freq.push_back(trunc_frequencies[maxim]);     // zero-crossing frequency
                                amp_difference.push_back(difference[maxim]);             // size of the estimated peak
                            }
                        }
                        
                        // sort out appropriate estimates for output
                        std::vector<double> peakBin;
                        int nbPeak = 0;
                        if (bin_index.size() == 0)                   // if no zero-crossing detected --> report NaNs
                        {
                            peakBin.push_back(nan(" "));
                            nbPeak = 0;
                            //std::cout<<"No Peak"<<std::endl;
                        }
                        else if (bin_index.size()== 1)           // if singular crossing...
                        {
                            peakBin.push_back((double)bin_index[0]);
                            nbPeak = 1;
                            histFreq.push_back((float)zero_cross_freq[0]); // we increment histFreq (the history of the alpha peak frequencies)
                            //std::cout<<"Singular Peak"<<std::endl;
                        }
                        else
                        {
                            // find the peaks whose frequency is in the range ([mu_peakF-sigma_peakF
                            // : mu_peakF+sigma_peakF]) = condition D
                            std::vector<int> usualIdxPeak;
                            if ((!histFreq.empty()) && (histFreq.size()>=10))
                            {
                                for (unsigned int zcf=0;zcf<zero_cross_freq.size();zcf++)
                                {
                                    if ((zero_cross_freq[zcf]>=floor(mu_peakF-sigma_peakF)) && (zero_cross_freq[zcf]<=ceil(mu_peakF+sigma_peakF)))
                                    {
                                        usualIdxPeak.push_back(zcf);
                                    }
                                }
                            }
                            if (usualIdxPeak.size()==1) // if there is only one peak that satisfies this condition D
                            {
                                peakBin.push_back(bin_index[usualIdxPeak[0]]);
                                nbPeak = 1;
                                //std::cout<<"The most probable peak (based on condition D) from "<<bin_index.size()<<" subpeaks."<<std::endl;
                            }
                            else if (usualIdxPeak.size()>1) // if there are several peaks that satisfies this condition D
                            {
                                std::vector<int> bin_index_bis;
                                std::vector<double> amp_difference_bis;
                                double first_peak_amp = 0.0;
                                double second_peak_amp = 0.0;
                                int first_peak_bin_index = 0;
                                for (unsigned u = 0; u<usualIdxPeak.size(); u++) // we keep only the peaks that satisfy the condition D
                                {
                                    bin_index_bis.push_back(bin_index[usualIdxPeak[u]]);                       // keep bin index for later
                                    amp_difference_bis.push_back(amp_difference[usualIdxPeak[u]]);
                                    if (amp_difference_bis[u]>first_peak_amp)
                                    {
                                        second_peak_amp = first_peak_amp;
                                        first_peak_amp = amp_difference_bis[u];
                                        first_peak_bin_index = bin_index_bis[u];
                                    }
                                    else if ((amp_difference_bis[u]>second_peak_amp) && (first_peak_amp>amp_difference_bis[u]))
                                    {
                                        second_peak_amp = amp_difference_bis[u];
                                    }
                                }
                                // we try to see if the higher peak is higher enough compared to the peak just after it in terms of peak amplitude
                                if (first_peak_amp*0.8 > second_peak_amp)     // Is the higher peak enough highest?
                                {
                                    peakBin.push_back(first_peak_bin_index);
                                    nbPeak = 1;
                                    //std::cout<<"The highest peak from "<<usualIdxPeak.size()<<" most probable peaks (based on condition D) from "<<bin_index.size()<<" subpeaks."<<std::endl;
                                }
                                else                        // ...if not...no clear peak : we will compute the alpha center of gravity
                                {
                                    std::sort(bin_index_bis.begin(), bin_index_bis.end(), std::greater<int>());
                                    std::vector<double> tmp_peakBin(bin_index_bis.begin(), bin_index_bis.end());
                                    peakBin = tmp_peakBin;
                                    nbPeak = bin_index_bis.size();
                                    //std::cout<<"Alpha center of gravity : several ("<<usualIdxPeak.size()<<") most probable peaks (based on condition D) from "<<bin_index.size()<<" subpeaks."<<std::endl;
                                }
                            }
                            else if (usualIdxPeak.empty()) // if there is no peak that satisfies this condition D or the length of HistFit not sufficiently high
                            {
                                std::vector<int> bin_index_ter;
                                std::vector<double> amp_difference_ter;
                                double first_peak_amp = 0.0;
                                double second_peak_amp = 0.0;
                                int first_peak_bin_index = 0;
                                for (unsigned u = 0; u<bin_index.size(); u++) // we keep only the peaks that satisfy the condition D
                                {
                                    bin_index_ter.push_back(bin_index[u]);                       // keep bin index for later
                                    amp_difference_ter.push_back(amp_difference[u]);
                                    if (amp_difference_ter[u]>first_peak_amp)
                                    {
                                        second_peak_amp = first_peak_amp;
                                        first_peak_amp = amp_difference_ter[u];
                                        first_peak_bin_index = bin_index_ter[u];
                                    }
                                    else if ((amp_difference_ter[u]>second_peak_amp) && (first_peak_amp>amp_difference_ter[u]))
                                    {
                                        second_peak_amp = amp_difference_ter[u];
                                    }
                                }
                                // we try to see if the higher peak is higher enough compared to the peak just after it in terms of peak amplitude
                                if ((first_peak_amp*0.8 > second_peak_amp) && (histFreq.size()>=20))    // Is the higher peak enough highest?
                                {
                                    peakBin.push_back(first_peak_bin_index);
                                    nbPeak = 1;
                                    //std::cout<<"The highest peak from "<<bin_index.size()<<" subpeaks (no subpeak satisfy the condition D)."<<std::endl;
                                }
                                else                        // ...if not...no clear peak : we will compute the alpha center of gravity
                                {
                                    if (histFreq.size()>=20) // if the history of the frequencies is sufficiently high, we will compute the alpha center of gravity
                                    {
                                        std::sort(bin_index_ter.begin(), bin_index_ter.end(), std::greater<int>());
                                        std::vector<double> tmp_peakBin(bin_index_ter.begin(), bin_index_ter.end());
                                        peakBin = tmp_peakBin;
                                        nbPeak = bin_index_ter.size();
                                        //std::cout<<"'Alpha center of gravity : "<<bin_index.size()<<" subpeaks (no subpeak satisfy the condition D)."<<std::endl;
                                    }
                                    else                    // if not, we consider the highest peak
                                    {
                                        peakBin.push_back(first_peak_bin_index);
                                        nbPeak = 1;
                                        //std::cout<<"History of frequencies is too small: the highest peak is selected from "<<bin_index.size()<<" subpeaks."<<std::endl;
                                    }
                                }
                            }
                        }
                        
                        
                        // by default, there is no peak, iaf_val is nan, qf is nan
                        double iaf_val = nan(" ");
                        double qf = nan(" ");
                        if (nbPeak>0)
                        {
                            // Find the closest bounds either side of peak/subpeak(s)
                            // ------------------------------------------------------
                            // DEFAULT BOUNDs EITHER SIDE OF THE PEAK/SUBPEAK(S)
                            std::pair<int,int> threshold_crossNoisePow_Bounds = MBT_frequencyBounds(trunc_frequencies, IAFinf-2, IAFsup+2);
                            // find the first time before the 1st peak where the spectrum is lower or
                            // equal than the background noise; if there is no crossing  point, we
                            // consider than the lower bound of a peak can't be higher than the lower
                            // bound of the alpha band - 2Hz
                            int threshold_crossNoisePow_before = threshold_crossNoisePow_Bounds.first-1;
                            // find the first time after the last peak where the spectrum is lower
                            // or equal than the background noise; if there is no crossing  point,
                            // we consider than the upper bound of a peak can't be higher than the
                            // upper bound of the alpha band + 2Hz
                            int threshold_crossNoisePow_after = threshold_crossNoisePow_Bounds.second+1;
                            
                            // THE LOWER BOUND OF THE PEAK IS THE CLOSEST ZERO-CROSSING POINT BEFORE THE PEAK/SUBPEAK(s)
                            int BinBeg = peakBin[peakBin.size()-1];
                            int BinEnd = peakBin[0];
                            std::vector<int> tmp_crossPoint_before, tmp_crossPoint_after;
                            for (unsigned int cc=1; cc<difference.size(); cc++)
                            {
                                if ((cc<=(unsigned) BinBeg-1) && (difference[cc]==0))
                                {
                                    tmp_crossPoint_before.push_back(cc);
                                }
                                if ((cc>=(unsigned) BinEnd+1) && (difference[cc]==0))
                                {
                                    tmp_crossPoint_after.push_back(cc);
                                }
                            }
                            int crossPoint_before;
                            if ((!tmp_crossPoint_before.empty()) && (tmp_crossPoint_before[tmp_crossPoint_before.size()-1]>0))
                            {
                                crossPoint_before = tmp_crossPoint_before[tmp_crossPoint_before.size()-1];
                                if (crossPoint_before != BinBeg - 1)
                                {
                                    // find the closest point from the crossPoint_before
                                    double C = sqrt(pow(logPSD[crossPoint_before] - noisePow[crossPoint_before],2));
                                    double B = C;
                                    if (crossPoint_before!=0) // to fix border issues
                                    {
                                        B = sqrt(pow(logPSD[crossPoint_before-1] - noisePow[crossPoint_before-1],2));
                                    }
                                    double A = sqrt(pow(logPSD[crossPoint_before+1] - noisePow[crossPoint_before+1],2));
                                    if ((B<=C) && (B<=A))
                                    {
                                        crossPoint_before = crossPoint_before-1;
                                    }
                                    else if ((C<B) && (C<=A))
                                    {
                                        crossPoint_before = crossPoint_before;
                                    }
                                    else if ((A<C) && (A<B))
                                    {
                                        crossPoint_before = crossPoint_before+1;
                                    }
                                }
                            }
                            if ((tmp_crossPoint_before.empty()) || (tmp_crossPoint_before[tmp_crossPoint_before.size()-1]<=0) || (crossPoint_before < threshold_crossNoisePow_before))
                            {
                                crossPoint_before = threshold_crossNoisePow_before;
                            }
                            int min1 = crossPoint_before;
                            
                            // THE LOWER BOUND OF THE PEAK IS A MINIMUM BETWEEN CROSSNOISEPOW_BEFORE AND THE PEAK
                            for (int k = BinBeg-1; k>=crossPoint_before+1; k--)
                            {
                                if((d1[k]==0.0 && d1[k-1]<0.0)||(d1[k]>0.0 && d1[k-1]<=0.0)) // look for switch from negative to positive derivative values (i.e. upward zero-crossing)
                                {
                                    min1 = k-1;
                                    if (difference[k-1]>difference[k]) // ensure correct frequency bin is picked out (find larger of two values either side of crossing (in the smoothed signal))
                                    {
                                        min1 = k;
                                    }
                                    k = crossPoint_before+1;
                                }
                            }
                            
                            
                            // THE UPPER BOUND OF THE PEAK IS THE CLOSEST ZERO-CROSSING POINT AFTER THE PEAK/SUBPEAK(S)
                            int crossPoint_after;
                            if ((!tmp_crossPoint_after.empty()) && (tmp_crossPoint_after[0]<noisePow.size()-1))
                            {
                                crossPoint_after = tmp_crossPoint_after[0];
                                if (crossPoint_after != BinEnd + 1)
                                {
                                    // find the closest point from the crossPoint_after
                                    double B = sqrt(pow(logPSD[crossPoint_after-1] - noisePow[crossPoint_after-1],2));
                                    double C = sqrt(pow(logPSD[crossPoint_after] - noisePow[crossPoint_after],2));
                                    double A = C;
                                    if (crossPoint_after!=0) // to fix border issues
                                    {
                                        A = sqrt(pow(logPSD[crossPoint_after+1] - noisePow[crossPoint_after+1],2));
                                    }
                                    if ((B<=C) && (B<=A))
                                    {
                                        crossPoint_after = crossPoint_after-1;
                                    }
                                    else if ((C<B) && (C<=A))
                                    {
                                        crossPoint_after = crossPoint_after;
                                    }
                                    else if ((A<C) && (A<B))
                                    {
                                        crossPoint_after = crossPoint_after+1;
                                    }
                                }
                            }
                            if ((tmp_crossPoint_after.empty()) || (tmp_crossPoint_after[0]>=noisePow.size()-1) || (crossPoint_after > threshold_crossNoisePow_after))
                            {
                                crossPoint_after = threshold_crossNoisePow_after;
                            }
                            int min2 = crossPoint_after;
                            
                            // THE UPPER BOUND OF THE PEAK IS A MINIMUM BETWEEN THE PEAK AND CROSSNOISEPOW_AFTER
                            for (int k = BinEnd+1; k<=crossPoint_after-1; k++)
                            {
                                if((d1[k+1]==0.0 && d1[k]<0.0)||(d1[k+1]>0.0 && d1[k]<=0.0)) // look for switch from negative to positive derivative values (i.e. upward zero-crossing)
                                {
                                    min2 = k;
                                    if (difference[k]>difference[k+1]) // ensure correct frequency bin is picked out (find larger of two values either side of crossing (in the smoothed signal))
                                    {
                                        min2 = k+1;
                                    }
                                    k = crossPoint_after-1;
                                }
                            }
                            // ----------------------------------------------------------
                            
                            
                            std::vector<double> bound_frequencies(trunc_frequencies.begin()+min1,trunc_frequencies.begin()+min2+1);
                            if (nbPeak>1) // if several peaks, we compute alpha center of gravity; qf is kept to nan
                            {
                                std::vector<double> bound_logPSD(logPSD.begin()+min1,logPSD.begin()+min2+1);
                                double sum1 = 0.0;
                                double sum2 = 0.0;
                                for (unsigned int n=0; n<bound_logPSD.size(); n++)
                                {
                                    sum1 = sum1 + bound_logPSD[n]*bound_frequencies[n];
                                    sum2 = sum2 + bound_logPSD[n];
                                }
                                double coG = sum1/sum2;
                                
                                double distance = 100; // default distance between trunc_frequencies and coG
                                for (unsigned int di=0; di<trunc_frequencies.size(); di++)
                                {
                                    if(sqrt(pow(trunc_frequencies[di]-coG,2))<distance)
                                    {
                                        distance = sqrt(pow(trunc_frequencies[di]-coG,2));
                                        std::vector<double> final_peakBin;
                                        final_peakBin.assign(1,di);
                                        peakBin = final_peakBin;
                                    }
                                }
                            }
                            else // if one peak, we compute qf
                            {
                                std::vector<double> bound_difference(difference.begin()+min1,difference.begin()+min2+1);
                                //qf = trapz(bound_frequencies, bound_difference)/(min2-min1);
                                qf = trapz(bound_frequencies, bound_difference);
                            }
                            iaf_val = trunc_frequencies[peakBin[0]];
                        }
                        else
                        {
                            iaf_val = nan(" ");
                        }
                        
                        IAF[channel] = iaf_val;
                        QF[channel] = qf;
                    }
                }
            }
        }
        computeIAF["iaf"] = IAF;
        computeIAF["qualityIaf"] = QF;
        //std::cout << "IAF = " << IAF[0] <<std::endl;
    }
    else
    {
        // Return NaN values to be handled in case of problem into MBT_ComputeIAF
        std::vector<double> IAF;
        IAF.push_back(std::numeric_limits<double>::infinity());
        computeIAF["iaf"] = IAF;
        std::vector<double> QF;
        QF.push_back(nan(" "));
        computeIAF["qualityIaf"] = QF;
        errno = EINVAL;
        perror("ERROR: MBT_COMPUTEIAF CANNOT PROCESS WITHOUT SIGNALS IN INPUT");
    }
    
    return computeIAF;
    
}
