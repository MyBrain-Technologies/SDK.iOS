#ifndef MBT_COMPUTEIAFCALIBRATION_H_INCLUDED
#define MBT_COMPUTEIAFCALIBRATION_H_INCLUDED

//
//  MBT_ComputeIAFCalibration.h
//
//  Created by Fanny Grosselin on 14/09/18.
//  Inspired by MBT_ComputeCalibration.h of Emma Barme on 20/10/2015.
//  Copyright (c) 2018 myBrain Technologies. All rights reserved.
//


#include <iostream>
#include <stdio.h>
#include <map>
#include <string>
#include <errno.h>
#include "MBT_ComputeIAF.h"
#include <limits>
#include "../../SignalProcessing.Cpp/Transformations/Headers/MBT_PWelchComputer.h"
#include "../../SignalProcessing.Cpp/DataManipulation/Headers/MBT_Matrix.h"

//Calibration process generating the parameters necessary for the computation of the relaxation index. For now, the calibration is only taking the first two channels into account.

/*
 * @brief Takes the data from the calibration recordings and compute the bounds of the IAF based on the calibration segments. These bounds
 are computed on each second with segments of 4s with a sliding window of 1s.
 * @param calibrationRecordings A matrix holding the concatenation of the calibration recordings, one channel per row. (No GPIOs)
 * @param calibrationRecordingsQuality A matrix holding the quality values, one channel per row, in the same order as in the matrix. (No GPIOs) Each quality value is between 0 and 1, and is the quality for a packet.
 * @param sampRate The signal sampling rate.
 * @param packetLength The number of data points in a packet.
 * @param IAFinf Lower bound of the frequency range which will be used to compute SNR. For example IAFinf = 7 to compute SNR alpha.
 * @param IAFsup Upper bound of the frequency range which will be used to compute SNR. For example IAFsup = 13 to compute SNR alpha.
 * @param histFreq Vector containing the previous frequencies.
 * @return iafMedian a vector that contains the averaged values of the bounds of the IAF.
 * @todo Use an enum for the output parameters?
 */
std::vector<float> MBT_ComputeIAFCalibration(MBT_Matrix<float> calibrationRecordings, MBT_Matrix<float> calibrationRecordingsQuality, const float sampRate, const int packetLength, const float IAFinf, const float IAFsup);

#endif // MBT_COMPUTEIAFCALIBRATION_H_INCLUDED

