/**
 * @file MBT_ComputeRelaxIndex.h
 * 
 * @author Fanny Grosselin
 * @author Katerina Pandremmenou
 * @author Etienne Garin
 * @author Xavier Navarro
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 * 
 * @brief Computes the relaxation index of a signal
 * 
 */

#ifndef MBT_COMPUTERELAXINDEX_H_INCLUDED
#define MBT_COMPUTERELAXINDEX_H_INCLUDED

#include <sp-global.h>

#include <DataManipulation/MBT_Matrix.h>

#include <map>
#include <string>

/**
 * @brief Convert a SP_FloatMatrix to a SP_Matrix
 * 
 * @param sessionPacket MBT_Matrix holding the signal.
 * @return SP_Matrix Converted MBT_Matrix holding the signal.
 */
SP_Matrix convertFloatMatrixToMatrix(SP_FloatMatrix& sessionPacket);

/**
 * @brief Combine RMS from both channel and compute general RMS
 * 
 * @param computeRMSSession 
 * @return std::pair<SP_FloatType, SP_FloatType> Absolute and relative combined RMS
 */
std::pair<SP_FloatType, SP_FloatType> combineRMS(std::map<std::string, SP_Vector > computeRMSSession);

/**
 * @brief Compute RMS if at least one channel has qualityRMS=NaN
 * 
 * @param RMSSessionPacket 
 * @param goodPeak 
 * @return SP_FloatType RMS computed
 */
SP_FloatType computeRMSForNaNQuality(const SP_Vector& RMSSessionPacket, const std::vector<int>& goodPeak);

/*
 * @brief Computes the relaxation index of the signal of the channel which had the best quality during the calibration. For now, only takes the first two channels into account.
          The relaxation index is computed each second with segments of 4s with a sliding window of 1s.
 * @param sessionPacket MBT_Matrix holding the signal.
 * @param errorHandle A vector holding error messages.
 * @param sampRate The signal sampling rate.
 * @param IAFinf Lower bound of the frequency range which will be used to compute SNR. For example IAFinf = 7 to compute SNR alpha.
 * @param IAFsup Upper bound of the frequency range which will be used to compute SNR. For example IAFsup = 13 to compute SNR alpha.
 * @param histFreq Vector containing the previous frequencies.
* @return std::pair<SP_FloatType, SP_FloatType> Absolute and relative RMS computed
 */
std::pair<SP_FloatType, SP_FloatType> MBT_ComputeRelaxIndex(SP_FloatMatrix sessionPacket, SP_FloatVector errorMsg, const SP_FloatType sampRate, SP_RealType IAFinf, SP_RealType IAFsup, SP_FloatVector &histFreq);


#endif // MBT_COMPUTERELAXINDEX_H_INCLUDED

