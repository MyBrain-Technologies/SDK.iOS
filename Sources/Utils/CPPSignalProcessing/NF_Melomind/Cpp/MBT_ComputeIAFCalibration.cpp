//
//  MBT_ComputeIAFCalibration.cpp
//
//  Created by Fanny Grosselin on 14/09/2018.
//  Inspired by MBT_ComputeCalibration.cpp of Emma Barme on 20/10/2015.
//  Copyright (c) 2018 myBrain Technologies. All rights reserved.
//

#include "../Headers/MBT_ComputeIAFCalibration.h"

#define MIN_QUALITY_PER_PACKET 0.5

#define GENERAL_QUALITY_THRESHOLD 0.5
#define CHANNEL_QUALITY_THRESHOLD 0.75

std::vector<float> MBT_ComputeIAFCalibration(MBT_Matrix<float> calibrationRecordings, MBT_Matrix<float> calibrationRecordingsQuality, const float sampRate, const int packetLength, const float IAFinf, const float IAFsup)
{
    std::vector<float> histFreq;
    std::vector<float> iafMedian;
    iafMedian.assign(2,0);
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
            // Store values to be handled in case of problem into MBT_ComputeIAFCalibration
            iafMedian[0] = 7.0;
            iafMedian[1] = 13.0;
            return iafMedian;
        }
        
        std::vector<float> IAFCalibInf;
        std::vector<float> IAFCalibSup;
        //Creating a new matrix with only the data values for the packets with a good quality value of the channel with the best mean quality value.
        int Buffer = 8 * (int) sampRate;
        int SlidWin = Buffer/8;
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
            
            std::map<std::string, std::vector<double> >  computeIAF = MBT_ComputeIAF(goodCalibrationRecordings, double(sampRate), double(IAFinf), double(IAFsup), histFreq); // there is only one value into the vector SNRCalib because packetOfGoodCalibrationRecordings contains one segment of 4 seconds of values of only the best channel and we apply a sliding window of 1s.
            std::vector<double> IAFCalibPacket = computeIAF["iaf"];
            std::vector<double> qualityIAF = computeIAF["qualityIaf"];
            
            
            // Combine IAF from both channel, according to the quality of the alpha peak:
            // compute general IAF from both channel, derived by qualityIaf of both
            // channel and the IAFCalibPacket of both channel
            // WARNING : THIS CODE IS CORRECT ONLY IF 2 CHANNELS !!!!!!!
            // -------------------------------------------------------------------
            std::vector<int> QFNaN;
            std::vector<int> goodPeak;
            double sumQf = 0.0;
            for (unsigned int cq = 0; cq<qualityIAF.size(); cq++)
            {
                if (std::isnan(qualityIAF[cq]))
                {
                    QFNaN.push_back(cq);
                }
                else
                {
                    sumQf = sumQf + qualityIAF[cq];
                }
                if (!std::isnan(IAFCalibPacket[cq]))
                {
                    goodPeak.push_back(cq);
                }
            }
            if (!QFNaN.empty()) // if at least one channel has qualityIAF=NaN (nb peaks = 0 or >1), we don't weight the average of IAF
            {
                if (goodPeak.empty()) // if all channels have no IAF (no peak in both channels)
                {
                    // we set default IAF bounds
                    IAFCalibInf.push_back((float)7.0);
                    IAFCalibSup.push_back((float)13.0);
                }
                else if ((!goodPeak.empty()) && (goodPeak.size()==1)) // if no peak in 1 channel and 1 dominant peak in the other channel
                {
                    // we keep the IAF value of this channel
                    IAFCalibInf.push_back((float)IAFCalibPacket[goodPeak[0]]-1);
                    IAFCalibSup.push_back((float)IAFCalibPacket[goodPeak[0]]+1);
                }
                else if ((!goodPeak.empty()) && (goodPeak.size()==2)) // if both channel have 1 dominant peak in both channels
                {
                    // we set default IAF bounds
                    IAFCalibInf.push_back((float)7.0);
                    IAFCalibSup.push_back((float)13.0);
                }
            }
            else // both channels have QFNaN~=NaN (1 dominant peak in each channel)
            {
                // we keep the IAF of the channel with the best qualityIAF
                if (qualityIAF[0] > qualityIAF[1])
                {
                    IAFCalibInf.push_back((float)IAFCalibPacket[0]-1);
                    IAFCalibSup.push_back((float)IAFCalibPacket[0]+1);
                }
                else if (qualityIAF[0] < qualityIAF[1])
                {
                    IAFCalibInf.push_back((float)IAFCalibPacket[1]-1);
                    IAFCalibSup.push_back((float)IAFCalibPacket[1]+1);
                }
                else
                {
                    IAFCalibInf.push_back((float)IAFCalibPacket[0]-1);
                    IAFCalibSup.push_back((float)IAFCalibPacket[0]+1);
                }
            }
            
            // -------------------------------------------------------------------
            
            float sumCalibInf = 0.0;
            float sumCalibSup = 0.0;
            int countCalibInf = 0;
            int countCalibSup = 0;
            for (unsigned int value=0; value<IAFCalibInf.size();value++)
            {
                if (!isnan(IAFCalibInf[value]) && !isinf(IAFCalibInf[value]))
                {
                    sumCalibInf += IAFCalibInf[value];
                    countCalibInf += 1;
                }
                
            }
            for (unsigned int value=0; value<IAFCalibSup.size();value++)
            {
                if (!isnan(IAFCalibSup[value]) && !isinf(IAFCalibSup[value]))
                {
                    sumCalibSup += IAFCalibSup[value];
                    countCalibSup += 1;
                }
            }
            iafMedian[0] = sumCalibInf / (float)countCalibInf;
            iafMedian[1] = sumCalibSup / (float)countCalibSup;
            // ------------------------------------------------------------------------
        }
        std::cout<<"iafMedian[0]= "<<iafMedian[0]<<std::endl;
        return iafMedian;
    }
    
    
    else
    {
        // Store values to be handled in case of problem into MBT_ComputeCalibration
        std::vector<float> iafMedian;
        iafMedian.push_back(std::numeric_limits<float>::infinity());
        errno = EINVAL;
        perror("ERROR: MBT_COMPUTECALIBRATION CANNOT PROCESS WITHOUT GOOD INPUTS");
        
        return iafMedian;
    }
    
}
