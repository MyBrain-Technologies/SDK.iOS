//
//  MBT_ComputeRelaxIndex.cpp
//
//  Created by Fanny Grosselin on 06/01/2017.
//  Copyright (c) 2017 myBrain Technologies. All rights reserved.
//
//  Update: Fanny Grosselin 2017/01/16 --> Remove the normalization of SNR because we do that after smoothing and not before.
//          Fanny Grosselin 2017/02/03 --> Get the Bounds (from parametersFromCalibration) to detect the outliers of the signal.
// 		    Fanny Grosselin 2017/03/23 --> Change float by double for the functions not directly used by Androïd. For the others, keep inputs and outputs in double, but do the steps with double.
//          Fanny Grosselin 2017/03/27 --> Fix all the warnings.

#include "../Headers/MBT_ComputeRelaxIndex.h"

float MBT_ComputeRelaxIndex(MBT_Matrix<float> sessionPacket, std::map<std::string, std::vector<float> > parametersFromCalibration, const float sampRate, const float IAFinf, const float IAFsup)
{
    // Get BestChannel from the calibration
    std::vector<float> bestChannelVector = parametersFromCalibration["BestChannel"];
    std::vector<float> tmp_Bounds = parametersFromCalibration["Bounds_For_Outliers"]; // Fanny Grosselin 2017/02/03
    std::vector<double> Bounds(tmp_Bounds.begin(), tmp_Bounds.end());

    int bestChannel = round(bestChannelVector[0]);

    double relaxIndex;

    if ((sessionPacket.size().first>0) & (sessionPacket.size().second>0) & (bestChannel != -2) & (bestChannel != -1))
    {
        // Get  SNR vector from the calibration
        //std::vector<double> SNRCalib = parametersFromCalibration["SNRCalib_ofBestChannel"];
        MBT_Matrix<double> packetBestChannel(1,sessionPacket.size().second);
        for (int sample = 0; sample < sessionPacket.size().second; sample++)
        {
            packetBestChannel(0,sample) = nan(" ");
            if (!std::isnan(sessionPacket(bestChannel,sample)))
            {
                packetBestChannel(0,sample) = sessionPacket(bestChannel,sample);
            }
        }

        std::vector<double> SNRSession;

        std::vector<double> packetBestChannelVector = packetBestChannel.row(0); // get the vector inside the matrix to test if all the element are NaN
        if (std::all_of(packetBestChannelVector.begin(), packetBestChannelVector.end(), [](double testNaN){return std::isnan(testNaN);}) )
        {
            SNRSession.push_back(nan(" "));
        }
        else
        {
            // Compute SNR
            SNRSession = MBT_ComputeSNR(packetBestChannel, double(sampRate), double(IAFinf), double(IAFsup), Bounds); // there is only one value but this is a vector
        }


        // Normalize SNR
        /*double meanSNRCalib = mean(SNRCalib);
        double stdSNRCalib = standardDeviation(SNRCalib);
        relaxIndex = SNRSession[0] - meanSNRCalib;
        if (stdSNRCalib != 0)
        {
            relaxIndex = relaxIndex/stdSNRCalib;
        }*/
        relaxIndex = SNRSession[0];
    }
    else
    {
        // Store values to be handled in case of problem into MBT_ComputeRelaxIndex
        relaxIndex = std::numeric_limits<double>::infinity();
        errno = EINVAL;
        perror("ERROR: MBT_COMPUTERELAXINDEX CANNOT PROCESS WITHOUT GOOD INPUTS");
    }
    return relaxIndex;
}
