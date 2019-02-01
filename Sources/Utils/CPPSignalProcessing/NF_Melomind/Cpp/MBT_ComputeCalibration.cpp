//
//  MBT_ComputeCalibration.cpp
//
//  Created by Fanny Grosselin on 04/01/17.
//  Inspired by MBT_ComputeCalibration.cpp of Emma Barme on 20/10/2015.
//  Copyright (c) 2017 myBrain Technologies. All rights reserved.
//
// Update: Fanny Grosselin : 2017/01/16 Smooth the SNR of calibration.
//         Fanny Grosselin : 2017/01/26 Compute SNR on segments of 4s but with a sliding window of 1s.
//         Fanny Grosselin : 2017/02/03 Add in inputs and for MBT_ComputeSNR, the Bounds to detect the outliers of the signal.
//		   Fanny Grosselin : 2017/02/14 Add the values of Bounds when there is error.
// 		   Fanny Grosselin : 2017/03/23 Change float by double for the functions not directly used by Andro�d. For the others, keep inputs and outputs in double, but do the steps with double.
//         Fanny Grosselin : 2017/03/27 Fix all the warnings.
//         Fanny Grosselin : 2017/09/18 Remove BoundsRow from the input of MBT_ComputeSNR
//         Katerina Pandremmenou : 2017/09/20 Change all implicit type castings to explicit ones
//         Fanny Grosselin : 2017/09/27 Instead of dividing meanQualities by the number of packets kept, we divide by the number of second during calibration
//		   Fanny Grosselin : 2017/09/27 Change the decision rule to know if the calibration is good.
//         Katerina Pandremmenou : 2017/09/28 Consider the bounds for the outliers for both channels of the calibration
//                                            Put infinite outliers to all 4 bounds in cases of a bad calibration
//         Fanny Grosselin : 2017/09/28 Change the decision rule to know if the calibration is good.
//         Fanny Grosselin : 2017/10/10 Remove the Bounds from the inputs of MBT_ComputeCalibration and from CalibrationParameters.
//         Fanny Grosselin : 2017/11/30 Fixed error: Get the EEG data corresponding to the packetsToKeepIndex and not all the EEG data from calibration
//         Fanny Grosselin : 2017/12/05 Add histFreq (the vector containing the previous frequencies) in input.
//         Fanny Grosselin : 2017/12/14 Change the code to compute SNR from both channels.
//         Fanny Grosselin : 2017/12/22 Add raw SNR values in the map holding parameters of the calibration.
//         Fanny Grosselin : 2017/12/22 Put all the keys of maps in camelcase.
//         Fanny Grosselin : 2018/01/24 Optimize the way we use histFreq.
//         Etienne GARIN   : 2018/01/26 Removed first input of histFreq as it can be local
//         Fanny Grosselin : 2018/02/14 Fix a problem of kept packets (when the quality was bad in only one channel, we didn't get the corresponding second! Now we kept the second if at least one channel has a quality >=0.5).
//         Fanny Grosselin : 2018/02/21 Consider a quality of 0.25 as a quality of 0.5.
//         Fanny Grosselin : 2018/02/28 Consider a quality of -1 as a quality of 0.
//         Fanny Grosselin : 2018/08/20 Compute the snr on a spectrum of 2s instead of 4s.
//         Xavier Navarro  : 2018/08/21 Major changes concerning the SNR computation (use of alpha bandpass filter)
//         Xavier Navarro  : 2018/09/14 Use of alpha peak detector during calibration (MBT_ComputeIAFCalibration.cpp) for version 2.5.0

#include "../Headers/MBT_ComputeCalibration.h"

#define MIN_QUALITY_PER_PACKET 0.5

#define GENERAL_QUALITY_THRESHOLD 0.5
#define CHANNEL_QUALITY_THRESHOLD 0.75

std::map<std::string, std::vector<float> > MBT_ComputeCalibration(MBT_Matrix<float> calibrationRecordings, MBT_Matrix<float> calibrationRecordingsQuality, const float sampRate, const int packetLength, float IAFminf, float IAFmsup, int smoothingDuration)
{
    std::vector<float> histFreq;
    std::map<std::string, std::vector<float> > calibrationParameters;
    std::cout<<"IAFminf = "<<IAFminf<<std::endl;
    if ((calibrationRecordings.size().first > 0) & (calibrationRecordings.size().second > 0) & (calibrationRecordingsQuality.size().first > 0) & (calibrationRecordingsQuality.size().second > 0) & (calibrationRecordings.size().first == calibrationRecordingsQuality.size().first) & (calibrationRecordings.size().second == calibrationRecordingsQuality.size().second*packetLength))
    {

        //Selecting the packets with a good enough quality value.
        //The minimum quality value for a packet to be taken into account. Hard coded to 0.5.
        int channelNb = calibrationRecordings.size().first;
        std::vector<int> packetsToKeepIndex; //A vector holding the indices of the good packets in both channel.
        std::vector<double> meanQualities;
        meanQualities.assign(channelNb, 0);


        //For each packet
        for (int packetIndex = 0; packetIndex < calibrationRecordingsQuality.size().second; packetIndex++)
        {
            int comptQual = 0;
            //For each channel
            for (int channelIndex = 0; channelIndex < channelNb; channelIndex++)
            {
                double quality = calibrationRecordingsQuality(channelIndex, packetIndex);
                if (quality==(double)0.25)
                {
                    quality = (double)0.5;
                }
                if (quality==(double)-1)
                {
                    quality = (double)0;
                }
                meanQualities[channelIndex] += quality;
                //If the signal is good enough
                if (quality >= MIN_QUALITY_PER_PACKET)
                {
                    comptQual = comptQual + 1;
                }
                if ((channelIndex == channelNb - 1) && (comptQual >= 1)) // If at least 1 channel has signal good enough
                {
                    packetsToKeepIndex.push_back(packetIndex);// we keep this packet in both channel
                }
                if (packetIndex == calibrationRecordingsQuality.size().second-1) // if we have looked all the packets
                {
                    meanQualities[channelIndex] /= calibrationRecordingsQuality.size().second;
                }
            }
        }

        unsigned int counter = 0;
        for (unsigned int co = 0; co<meanQualities.size(); co++)
        {
            if(meanQualities[co] >= CHANNEL_QUALITY_THRESHOLD){
                counter = (unsigned int) meanQualities.size();
                break;
            }
            if (meanQualities[co] >= GENERAL_QUALITY_THRESHOLD)
            {
                counter = counter + 1;
            }
        }

        //If all the channels have an average quality higher or equal to 0.5, or if 1 channel has an averaged quality >= 0.75,
        // the calibration is good. Otherwise the calibration fails.
        // Return value to be handled in case of problem / false and if needed to start calibration over and to use different values than default
        if (counter<meanQualities.size())
        {
            // Store values to be handled in case of problem into MBT_ComputeCalibration
            std::vector<float> RMSCalib;
            RMSCalib.push_back(std::numeric_limits<float>::infinity());
            std::vector<float> SmoothedRMSCalib;
            SmoothedRMSCalib.push_back(std::numeric_limits<float>::infinity());
            std::vector<float> errorMsg;
            errorMsg.push_back(-2);
            calibrationParameters["rawSnrCalib"] = RMSCalib;
            calibrationParameters["histFrequencies"] = histFreq;
            calibrationParameters["errorMsg"] = errorMsg;
            calibrationParameters["snrCalib"] = SmoothedRMSCalib;
            errno = EINVAL;
            perror("ERROR: MBT_COMPUTECALIBRATION CANNOT PROCESS WITH ONLY BAD QUALITY SIGNALS");

            return calibrationParameters;
        }

        std::vector<float> RMSCalib;
        std::vector<float> SmoothedRMSCalib;
        //Creating a new matrix with only the data values for the packets with a good quality value of the channel with the best mean quality value.
        int Buffer = 1 * (int) sampRate;
        int SlidWin = Buffer;
        MBT_Matrix<double> goodCalibrationRecordings(channelNb, Buffer);
        // Get the EEG data corresponding to the packetsToKeepIndex
        MBT_Matrix<double> entireGoodCalibrationRecordings(channelNb, packetsToKeepIndex.size()*sampRate);
        for (unsigned int p=0; p<packetsToKeepIndex.size(); p++)
        {
            for (int c= 0; c<channelNb; c++)
            {
                for (int index=0; index<(int)sampRate; index++)
                {
                    entireGoodCalibrationRecordings(c,p*(int)sampRate+index) = calibrationRecordings(c, sampRate*packetsToKeepIndex[p]+index);
                }
            }
        }

        for (int k = 0;k< packetsToKeepIndex.size()*sampRate - Buffer + SlidWin; k= k +SlidWin)
        {
            for (int ccc = 0; ccc<channelNb; ccc++)
            {
                int tmp1 = k;
                int tmp2 = Buffer + k - 1;
                for (int dataPointInPacketIndex = tmp1; dataPointInPacketIndex < tmp2 + 1; dataPointInPacketIndex++)
                {
                    goodCalibrationRecordings(ccc, dataPointInPacketIndex-tmp1) = entireGoodCalibrationRecordings(ccc, dataPointInPacketIndex);
                }
            }
            std::map<std::string, std::vector<double> >  computeRMS = MBT_ComputeRMS(goodCalibrationRecordings, double(sampRate), double(IAFminf), double(IAFmsup), histFreq); // there is only one value into the vector RMSCalib because packetOfGoodCalibrationRecordings contains one segment of 4 seconds of values of only the best channel and we apply a sliding window of 1s.
            std::vector<double> RMSCalibPacket = computeRMS["rms"];
            std::vector<double> qualityRMS = computeRMS["qualityRms"];
            std::cout<<"Compute cal : l160 "<<std::endl;

            // Combine RMS from both channel, according to the quality of the alpha peak:
            // compute general RMS from both channel, derived by qualityRMS of both
            // channel and the RMSCalibPacket of both channel
            // WARNING : THIS CODE IS CORRECT ONLY IF 2 CHANNELS !!!!!!!
            // -------------------------------------------------------------------
            std::vector<int> QFNaN;
            std::vector<int> goodPeak;
            double sumQf = 0.0;
            for (unsigned int cq = 0; cq<qualityRMS.size(); cq++)
            {
                if (std::isnan(qualityRMS[cq]))
                {
                    QFNaN.push_back(cq);
                }
                else
                {
                    sumQf = sumQf + qualityRMS[cq];
                }
                if (RMSCalibPacket[cq]>1) // find what are the channels with RMS>1
                {
                    goodPeak.push_back(cq);
                }
            }
            std::cout<<"Compute cal : l185 "<<std::endl;
            
            if (!QFNaN.empty()) // if at least one channel has qualityRMS=NaN (nb peaks = 0 or >1), we don't weight the average of RMS
            {
                std::cout<<"Compute cal : l189 "<<std::endl;
                if (goodPeak.empty()) // if all channels have RMS=1 (no peak in both channels)
                {
                    // we average the RMS of both channel: = (1+1)/2 = 1
                    RMSCalib.push_back((float)1.0);
                }
                else if ((!goodPeak.empty()) && (goodPeak.size()==1)) // if one channel has RMS>1 (no peak in 1 channel and 1 dominant peak in the other channel)
                {
                    // we keep the RMS value of this channel
                    RMSCalib.push_back((float)RMSCalibPacket[goodPeak[0]]);
                }
                else if ((!goodPeak.empty()) && (goodPeak.size()==2)) // if both channel has RMS>1 (1 dominant peak in both channels)
                {
                    // we average the RMS values of both channels
                    double tmp_s = (RMSCalibPacket[goodPeak[0]] + RMSCalibPacket[goodPeak[1]])/2;
                    RMSCalib.push_back((float)tmp_s);
                }
            }
            else // both channels have QFNaN~=NaN (1 dominant peak in each channel)
            {
                // we weight the RMS of each channel by its QFNaN
                std::cout<<"Compute cal : l210 "<<std::endl;
                std::cout<<"RMSCalibPacket[0]"<<RMSCalibPacket[0]<<std::endl;
                std::cout<<"qualityRMS[0]"<<qualityRMS[0]<<std::endl;
                std::cout<<"sumQf"<<sumQf<<std::endl;
                std::cout<<"RMSCalibPacket[1]"<<RMSCalibPacket[1]<<std::endl;
                std::cout<<"qualityRMS[1]"<<qualityRMS[1]<<std::endl;
                
                double tmp_s = RMSCalibPacket[0]*(qualityRMS[0]/sumQf) + RMSCalibPacket[1]*(qualityRMS[1]/sumQf);
                RMSCalib.push_back((float)tmp_s);
            }
            std::cout<<"Compute cal : l212 "<<std::endl;
            // -------------------------------------------------------------------
            calibrationParameters["rawSnrCalib"] = RMSCalib;
            SmoothedRMSCalib.push_back(MBT_SmoothRelaxIndex(RMSCalib, smoothingDuration)); // we smooth the RMS from calibration
        }

        std::vector<float> errorMsg;
        errorMsg.push_back(0);

        
        
        // Store the parameters into calibrationParameters
        calibrationParameters["histFrequencies"] = histFreq;
        calibrationParameters["errorMsg"] = errorMsg;
        calibrationParameters["snrCalib"] = SmoothedRMSCalib;

        return calibrationParameters;
    }

    else
    {
        // Store values to be handled in case of problem into MBT_ComputeCalibration
        std::vector<float> RMSCalib;
        RMSCalib.push_back(std::numeric_limits<float>::infinity());
        std::vector<float> SmoothedRMSCalib;
        SmoothedRMSCalib.push_back(std::numeric_limits<float>::infinity());
        std::vector<float> errorMsg;
        errorMsg.push_back(-1);
        calibrationParameters["rawSnrCalib"] = RMSCalib;
        calibrationParameters["histFrequencies"] = histFreq;
        calibrationParameters["errorMsg"] = errorMsg;
        calibrationParameters["snrCalib"] = SmoothedRMSCalib;
        errno = EINVAL;
        perror("ERROR: MBT_COMPUTECALIBRATION CANNOT PROCESS WITHOUT GOOD INPUTS");

        return calibrationParameters;
    }

}
