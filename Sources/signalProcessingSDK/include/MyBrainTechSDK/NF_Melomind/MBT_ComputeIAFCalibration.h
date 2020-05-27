/**
 * @file MBT_ComputeIAFCalibration.h
 *
 * @author Emma Barme
 * @author Fanny Grosselin
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 *
 * @brief Calibration process generating the parameters necessary for the computation of the relaxation index.
 *          For now, the calibration is only taking the first two channels into account.
 *
 */

#ifndef MBT_COMPUTEIAFCALIBRATION_H_INCLUDED
#define MBT_COMPUTEIAFCALIBRATION_H_INCLUDED

#include <iostream>
#include <stdio.h>
#include <map>
#include <string>
#include <errno.h>
#include "MBT_ComputeIAF.h"
#include <limits>

#include "Transformations/MBT_PWelchComputer.h"
#include "DataManipulation/MBT_Matrix.h"

/**
 * @brief Filter calibration recordings to get only packets of good quality
 * 
 * @param calibrationRecordings A matrix holding the concatenation of the calibration recordings, one channel per row. (No GPIOs)
 * @param packetsToKeepIndex A vector containing packets of good quality indexes
 * @param sampRate The signal sampling rate.
 * @return SP_Matrix The calibration recording with only good quality packets
 */
SP_Matrix filterCalibrationRecordingByQualities(SP_FloatMatrix& calibrationRecordings, std::vector<int>& packetsToKeepIndex, const SP_FloatType sampRate);

/**
 * @brief Manage IAFCalib values when QF is not empty
 * 
 * @param IAFCalibInf Inferior bond of IAF
 * @param IAFCalibSup Superior bond of IAF
 * @param IAFCalibPacket IAF result of MBT_ComputeIAF
 * @param goodPeak goodPeak
 */
void notEmptyQFNaN(SP_FloatVector& IAFCalibInf, SP_FloatVector& IAFCalibSup, const SP_Vector& IAFCalibPacket, const std::vector<int>& goodPeak);

/**
 * @brief Manage IAFCalib values when QF is empty
 * 
 * @param IAFCalibInf Inferior bond of IAF
 * @param IAFCalibSup Superior bond of IAF
 * @param IAFCalibPacket IAF result of MBT_ComputeIAF
 * @param qualityIAF qualityIAF result of MBT_ComputeIAF
 */
void emptyQFNaN(SP_FloatVector& IAFCalibInf, SP_FloatVector& IAFCalibSup, const SP_Vector& IAFCalibPacket, const SP_Vector& qualityIAF);

/**
 * @brief Update IAF bonds from an IAF computation
 * 
 * @param computeIAF A dictionnary containing one IAF value by channel and the updated vector histFreq.
 * @param IAFCalibInf Inferior bond of IAF
 * @param IAFCalibSup Superior bond of IAF
 */
void pushBondsFromIAFComputation(std::map<std::string, SP_Vector >&  computeIAF, SP_FloatVector& IAFCalibInf, SP_FloatVector& IAFCalibSup);

/**
 * @brief Compute median from IAF bonds
 * 
 * @param IAFCalibInf Inferior bond of IAF
 * @param IAFCalibSup Superior bond of IAF
 * @return SP_FloatVector Computed IAF median
 */
SP_FloatVector computeMedianFromIAFBonds(SP_FloatVector& IAFCalibInf, SP_FloatVector& IAFCalibSup);

/**
 * @brief Compute IAF median of the current recording
 * 
 * @param calibrationRecordings A matrix holding the concatenation of the calibration recordings, one channel per row. (No GPIOs)
 * @param entireGoodCalibrationRecordings The calibration recording with only good quality packets
 * @param IAFinf Lower bound of the frequency range which will be used to compute SNR. For example IAFinf = 7 to compute SNR alpha.
 * @param IAFsup Upper bound of the frequency range which will be used to compute SNR. For example IAFsup = 13 to compute SNR alpha.
 * @param packetsToKeepIndex A vector containing packets of good quality indexes
 * @param sampRate The signal sampling rate.
 * @return SP_FloatVector Computed IAF median
 */
SP_FloatVector computeIAFMedian(SP_FloatMatrix& calibrationRecordings, SP_Matrix& entireGoodCalibrationRecordings,
                                    const SP_FloatType IAFinf, const SP_FloatType IAFsup,
                                    std::vector<int>& packetsToKeepIndex, const SP_FloatType sampRate);

class IafCalibrationOutputKeys {
    public:
        static const std::string IAF;
};

/**
 * @brief Takes the data from the calibration recordings and compute the bounds of the IAF based on the calibration segments.
 *          These bounds are computed on each second with segments of 4s with a sliding window of 1s.
 * 
 * @param calibrationRecordings A matrix holding the concatenation of the calibration recordings, one channel per row. (No GPIOs)
 * @param calibrationRecordingsQuality A matrix holding the quality values, one channel per row, in the same order as in the matrix. (No GPIOs) Each quality value is between 0 and 1, and is the quality for a packet.
 * @param sampRate The signal sampling rate.
 * @param packetLength The number of data points in a packet.
 * @param IAFinf Lower bound of the frequency range which will be used to compute SNR. For example IAFinf = 7 to compute SNR alpha.
 * @param IAFsup Upper bound of the frequency range which will be used to compute SNR. For example IAFsup = 13 to compute SNR alpha.
 * @return SP_FloatVector A vector that contains the averaged values of the bounds of the IAF.
 */
// TODO : Use an enum for the output parameters ?
SP_FloatVector MBT_ComputeIAFCalibration(SP_FloatMatrix calibrationRecordings, SP_FloatMatrix calibrationRecordingsQuality, const SP_FloatType sampRate, const int packetLength, const SP_FloatType IAFinf, const SP_FloatType IAFsup);

#endif // MBT_COMPUTEIAFCALIBRATION_H_INCLUDED

