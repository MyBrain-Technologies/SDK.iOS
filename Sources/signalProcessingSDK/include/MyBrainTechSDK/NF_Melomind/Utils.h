/**
 * @file Utils.h
 * 
 * @author Xavier Navarro
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 * 
 * @brief Utilitaries functions for Neurofeedback
 * 
 */

#ifndef NF_MELOMIND_UTILS_H
#define NF_MELOMIND_UTILS_H

#include <sp-global.h>

#include "NF_Melomind/MBT_NFConfig.h"

#include <DataManipulation/MBT_Matrix.h>

#include <map>

#define GENERAL_QUALITY_THRESHOLD 0.5
#define CHANNEL_QUALITY_THRESHOLD 0.5

//Here are defined the alpha band limits
const SP_FloatType IAFinf = 6; // warning: it's 6 and not 7
const SP_FloatType IAFsup = 13;

/**
 * @brief Compute the calibration parameters
 * @deprecated
 * 
 * @param sampRate The sampling rate
 * @param packetLength The number of eeg data per eegPacket
 * @param calibrationRecordings The EEG signals as it's returned by the QualityChecker (number of rows = number of channels)
 * @param calibrationRecordingsQuality The quality of each EEG signal as it's returned by the QualityChecker (number of rows = number of channels)
 * @param smoothingDuration Integer that gives the number of relaxation indexes we have to take into account to smooth the current one.
 *                          For instance smoothingDuration=2 means we average the current relaxationIndex with the previous one.
 * @return std::map<std::string, SP_FloatVector> The calibration map
 */
std::map<std::string, SP_FloatVector> main_calibration(SP_FloatType sampRate, unsigned int packetLength, SP_FloatMatrix calibrationRecordings,
                                                    SP_FloatMatrix calibrationRecordingsQuality, int smoothingDuration);

/**
 * @brief Compute the calibration parameters
 * 
 * @param configuration Neurofeedback configuration
 * @param calibrationRecordings The EEG signals as it's returned by the QualityChecker (number of rows = number of channels)
 * @param calibrationRecordingsQuality The quality of each EEG signal as it's returned by the QualityChecker (number of rows = number of channels)
 * @return std::map<std::string, SP_FloatVector> The calibration map
 */
std::map<std::string, SP_FloatVector> main_calibration(MBT_NFConfig configuration,
                                                    SP_FloatMatrix calibrationRecordings,
                                                    SP_FloatMatrix calibrationRecordingsQuality);

/**
 * @brief Play the session
 * @deprecated
 * 
 * @param sampRate The sampling rate
 * @param paramCalib The calibration map
 * @param sessionPacket The EEG signals on real-time during session as it's returned by the QualityChecker (number of rows = number of channels)
 * @param histFreq Containing the frequency of the alpha peak detected previously (previously means during calibration and the previous packets of the session)
 *                  If it's the first packet of the session: get histFreq from paramCalib --> histFreq = paramCalib["HistFrequencies"];
 *                  else: get histFreq from session -->  histFreq = paramSession["HistFrequencies"];
 * @param pastRelaxIndex Containing the previous relax index computed during the session (not smoothed).
 * @param resultSmoothedRMS 
 * @param resultVolum 
 * @param smoothingDuration Integer that gives the number of relaxation indexes we have to take into account to smooth the current one.
 *                          For instance smoothingDuration=2 means we average the current relaxationIndex with the previous one.
 * @param min_val 
 * @param max_val 
 * @return SP_FloatType Current session volume computed
 */
SP_FloatType main_relaxIndex(const SP_FloatType sampRate, std::map<std::string, SP_FloatVector > paramCalib,
                                const SP_FloatMatrix &sessionPacket, SP_FloatVector &histFreq, SP_FloatVector &pastRelaxIndex,
                                SP_FloatVector &resultSmoothedRMS, SP_FloatVector &resultVolum, int smoothingDuration,
                                const SP_FloatType min_val, const SP_FloatType max_val);

/**
 * @brief Play the session
 * 
 * @param configuration Neurofeedback configuration
 * @param paramCalib The calibration map
 * @param sessionPacket The EEG signals on real-time during session as it's returned by the QualityChecker (number of rows = number of channels)
 * @param histFreq Containing the frequency of the alpha peak detected previously (previously means during calibration and the previous packets of the session)
 *                  If it's the first packet of the session: get histFreq from paramCalib --> histFreq = paramCalib["HistFrequencies"];
 *                  else: get histFreq from session -->  histFreq = paramSession["HistFrequencies"];
 * @param pastRelaxIndex Containing the previous relax index computed during the session (not smoothed).
 * @param resultSmoothedRMS 
 * @param resultVolum 
 * @param min_val 
 * @param max_val 
 * @return SP_FloatType Current session volume computed
 */
SP_FloatType main_relaxIndex(MBT_NFConfig configuration, std::map<std::string, SP_FloatVector > paramCalib,
                                const SP_FloatMatrix &sessionPacket, SP_FloatVector &pastRelaxIndex,
                                SP_FloatVector &resultSmoothedRMS, SP_FloatVector &resultVolum,
                                const std::pair<SP_FloatType, SP_FloatType>& minMax);

/**
 * @brief Get minmax values of an RMS calibration
 * 
 * @param tmp_RMSCalib 
 * @param minFactor 
 * @param maxFactor 
 * @return std::pair<SP_FloatType, SP_FloatType> 
 */
std::pair<SP_FloatType, SP_FloatType> computeMinMax(SP_FloatVector &tmp_RMSCalib, SP_FloatType minFactor, SP_FloatType maxFactor);

void computeSessionRelaxIndex(const MBT_NFConfig& configuration, const std::map<std::string, SP_FloatVector >& paramCalib,
                                SP_FloatMatrix& sessionRecordings, SP_FloatVector& pastRelaxIndex, SP_FloatVector& smoothedRelaxIndex,
                                SP_FloatVector& volum, const std::pair<SP_FloatType, SP_FloatType>& minMax);

/**
 * @brief Count mean qualities above fixed thresholds 
 * 
 * @param meanQualities Mean qualities between channels of each packet
 * @param channelQualityThreshold Channel quality threshold
 * @param generalQualityThreshold general quality threshold
 * @return int Number of mean qualities above GENERAL_QUALITY_THRESHOLD, if a mean quality is above CHANNEL_QUALITY_THRESHOLD, returns meanQualities size
 */
int countQualitiesAboveThreshold(const SP_Vector& meanQualities, SP_RealType channelQualityThreshold = CHANNEL_QUALITY_THRESHOLD,
                                    SP_RealType generalQualityThreshold = GENERAL_QUALITY_THRESHOLD);

/**
 * @brief Compute mean quality of a calibration recording
 * 
 * @param calibrationRecordingsQuality A matrix holding the quality values, one channel per row, in the same order as in the matrix. (No GPIOs) Each quality value is between 0 and 1, and is the quality for a packet.
 * @param packetsToKeepIndex A vector containing packets of good quality indexes
 * @return SP_Vector A vector containing mean qualities between channels of each packet
 */
SP_Vector computeMeanQualities(SP_FloatMatrix calibrationRecordingsQuality, std::vector<int>& packetsToKeepIndex);

/**
 * @brief Verifies Calibration inputs
 * 
 * @param calibrationRecordings A matrix holding the concatenation of the calibration recordings, one channel per row. (No GPIOs)
 * @param calibrationRecordingsQuality A matrix holding the quality values, one channel per row, in the same order as in the matrix. (No GPIOs) Each quality value is between 0 and 1, and is the quality for a packet.
 * @param packetLength The number of data points in a packet.
 * @return true Inputs are correct
 * @return false Inputs are incorrect
 */
bool checkCalibrationParameters(const SP_FloatMatrix& calibrationRecordings,
                                const SP_FloatMatrix& calibrationRecordingsQuality, const int packetLength);

#endif // NF_MELOMIND_UTILS_H