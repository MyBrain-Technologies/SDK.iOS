//
//  MBT_NormalizeRelaxIndex.cpp
//
//  Created by Fanny Grosselin on 16/01/2017.
//  Copyright (c) 2017 myBrain Technologies. All rights reserved.
//
// 	Update: Fanny Grosselin on 2017/03/23 --> Change float by double for the functions not directly used by Androïd. For the others, keep inputs and outputs in double, but do the steps with double
//          Xavier Navarro on 2018/09/14  --> Adaptation to RMS (Substitute SNR by RMS)

#include "../Headers/MBT_NormalizeRelaxIndex.h"

float MBT_NormalizeRelaxIndex(float relaxIndexSession, std::vector<float> relaxIndexCalibration)
{
    std::vector<double> tmp_relaxIndexCalibration(relaxIndexCalibration.begin(),relaxIndexCalibration.end());

    double NormalizedVector;
    if (tmp_relaxIndexCalibration.size()> 0)
    {
        double meanRMSCalib = mean(tmp_relaxIndexCalibration);
        double stdRMSCalib = standardDeviation(tmp_relaxIndexCalibration);

        NormalizedVector = double(relaxIndexSession) - meanRMSCalib;
        if (stdRMSCalib != 0)
        {
            NormalizedVector = NormalizedVector/stdRMSCalib;
        }
    }

    else
    {
        // Store values to be handled in case of problem into MBT_NormalizeRelaxIndex
        NormalizedVector = std::numeric_limits<double>::infinity();
        errno = EINVAL;
        perror("ERROR: MBT_NORMALIZERELAXINDEX CANNOT PROCESS WITHOUT GOOD INPUTS");
    }

   return float(NormalizedVector);
}
