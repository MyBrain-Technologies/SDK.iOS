//
//  MBT_ComputeRMS.cpp
//
//  Created by Xavier Navarro on 14/09/2018, based on Fanny Grosselin MBT_ComputeSNR.cpp
//  Copyright (c) 2018 myBrain Technologies. All rights reserved.
//


#include "../Headers/MBT_ComputeRMS.h"


std::map<std::string, std::vector<double> > MBT_ComputeRMS(MBT_Matrix<double> signal, const double sampRate,  double IAFminf,  double IAFmsup, std::vector<float> &histFreq)
{
    std::vector<double> tmpHistFreq(histFreq.begin(),histFreq.end());
    std::map<std::string, std::vector<double> > computeRMS;
    if ((signal.size().first > 0) & (signal.size().second > 0))
    {
        std::vector<double> RMS;
        RMS.assign(signal.size().first,0);
        std::vector<double> QF;
        QF.assign(signal.size().first,0);
        for (int channel=0; channel<signal.size().first; channel++)
        {
            //std::cout<<"Channel = "<<channel<<std::endl;
            std::vector<double> signal_ch = signal.row(channel);
            std::vector<double> signal_ch_withoutDC = RemoveDC(signal_ch); // Remove DC
            
            std::vector<double> freqBoundsBandPass;
            freqBoundsBandPass.assign(2,0);
            freqBoundsBandPass[0] = IAFminf;
            freqBoundsBandPass[1] = IAFmsup;
            
            std::vector<double> freqBoundsGuardLow;
            freqBoundsGuardLow.assign(2,0);
            freqBoundsGuardLow[0] = 3.0;
            freqBoundsGuardLow[1] = 6.5;
            
            std::vector<double> freqBoundsGuardHigh;
            freqBoundsGuardHigh.assign(2,0);
            freqBoundsGuardHigh[0] = 13.5;
            freqBoundsGuardHigh[1] = 18.5;
            
            std::vector<double> tmp_outputBandpass_alpha = BandPassFilter(signal_ch_withoutDC,freqBoundsBandPass); // Alpha BandPass
            std::vector<double> tmp_outputBandpass_guardL = BandPassFilter(signal_ch_withoutDC,freqBoundsGuardLow); // Guard band low
            std::vector<double> tmp_outputBandpass_guardH = BandPassFilter(signal_ch_withoutDC,freqBoundsGuardHigh); // BandPass
            
            double sum_alpha=0.0;
            double sqno_alpha;
            double sum_guardL=0.0;
            double sqno_guardL;
            double sum_guardH=0.0;
            double sqno_guardH;
            
            int nan_count = 0;
            for (int i=0; i<tmp_outputBandpass_alpha.size(); i++)
            {
                //cout << "tmp_outputBandpass  = "<< tmp_outputBandpass[i] << '\n';
                if (isnan(tmp_outputBandpass_alpha[i]))
                {
                    nan_count++;
                }
                else
                {
                    sqno_alpha=pow(1.0e6*tmp_outputBandpass_alpha[i],2);
                    sqno_guardL=pow(1.0e6*tmp_outputBandpass_guardL[i],2);
                    sqno_guardH=pow(1.0e6*tmp_outputBandpass_guardH[i],2);
                    sum_alpha=sum_alpha+sqno_alpha;
                    sum_guardL=sum_guardL+sqno_guardL;
                    sum_guardH=sum_guardH+sqno_guardH;
                }
            }
            RMS[channel] = sqrt(sum_alpha/tmp_outputBandpass_alpha.size());
            QF[channel] = 2*(sqrt(sum_alpha/tmp_outputBandpass_alpha.size())) / (sqrt(sum_guardL/tmp_outputBandpass_alpha.size()+sqrt(sum_guardH/tmp_outputBandpass_alpha.size())));
            //cout << "RMS  = "<< RMS[channel] <<" QF = "<< QF[channel] <<" NaN values="<< nan_count <<'\n';
        }
        computeRMS["rms"] = RMS;
        computeRMS["qualityRms"] = QF;
    }
    else
    {
        // Return NaN values to be handled in case of problem into MBT_ComputeRMS
        std::vector<double> RMS;
        RMS.push_back(std::numeric_limits<double>::infinity());
        std::vector<double> QF;
        QF.push_back(nan(" "));
        computeRMS["rms"] = RMS;
        computeRMS["qualityRMS"] = QF;
        errno = EINVAL;
        perror("ERROR: MBT_ComputeRMS CANNOT PROCESS WITHOUT SIGNALS IN INPUT");
    }
    return computeRMS;
}

