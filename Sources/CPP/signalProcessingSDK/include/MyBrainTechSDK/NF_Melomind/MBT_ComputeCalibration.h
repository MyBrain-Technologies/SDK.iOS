/**
 * @file MBT_ComputeCalibration.h
 * 
 * @author Fanny Grosselin
 * @author Katerina Pandremmenou
 * @author Etienne Garin
 * @author Xavier Navarro
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 *
 * @brief Calibration process generating the parameters necessary for the computation of the relaxation index.
 * For now, the calibration is only taking the first two channels into account.
 *
 */

#ifndef MBT_COMPUTECALIBRATION_H_INCLUDED
#define MBT_COMPUTECALIBRATION_H_INCLUDED

#include <sp-global.h>

#include "DataManipulation/MBT_Matrix.h"

#include <map>
#include <string>

/**
 * @brief Format dictionnary output for wrong inputs
 * Wrong inputs are input that do not respect @ref checkCalibrationParameters(const SP_FloatMatrix&, const SP_FloatMatrix&, const int)
 * or if all the channels don't have an average quality higher than 0.5 or if one channel don't have an average quality higher than 0.75
 * 
 * @param errorValue Error value
 * @return std::map<std::string, SP_FloatVector > A dictionnary with the value for the various parameters.
 */
std::map<std::string, SP_FloatVector > formatCalibrationParametersForWrongInput(int errorValue);

/**
 * @brief Format dictionnary output
 * 
 * @param RMSCalib Absolute RMS calibration value
 * @param relativeRMSCalib Relative RMS calibration value
 * @param histFreq 
 * @param SmoothedRMSCalib 
 * @param errorValue 
 * @return std::map<std::string, SP_FloatVector > A dictionnary with the value for the various parameters.
 */
std::map<std::string, SP_FloatVector > formatCalibrationParameters(const SP_FloatVector& RMSCalib, const SP_FloatVector& relativeRMSCalib, const SP_FloatVector& histFreq,
                                                                    const SP_FloatVector& SmoothedRMSCalib, int errorValue);

/**
 * @brief Creating a new matrix with only the data values for the packets
 * with a good quality value of the channel with the best mean quality value.
 * 
 * @param calibrationRecordings A matrix holding the concatenation of the calibration recordings, one channel per row. (No GPIOs)
 * @param packetsToKeepIndex 
 * @param sampRate The signal sampling rate.
 * @return SP_Matrix A matrix with only data values of good qualities
 */
SP_Matrix createGoodCalibrationRecording(SP_FloatMatrix calibrationRecordings, const std::vector<int>& packetsToKeepIndex,
                                            const SP_FloatType sampRate);

/**
 * @brief Compute RMS for calibration
 * 
 * @param goodCalibrationRecordings 
 * @param entireGoodCalibrationRecordings 
 * @param histFreq Vector containing the previous frequencies.
 * @param IAFinf Lower bound of the frequency range which will be used to compute SNR. For example IAFinf = 7 to compute SNR alpha.
 * @param IAFsup Upper bound of the frequency range which will be used to compute SNR. For example IAFsup = 13 to compute SNR alpha.
 * @param sampRate The signal sampling rate.
 * @param k Current index
 * @return std::map<std::string, SP_Vector > RMS
 */
std::map<std::string, SP_Vector > computeRMSForCalib(SP_Matrix& goodCalibrationRecordings, SP_Matrix& entireGoodCalibrationRecordings,
                                            SP_FloatVector& histFreq, SP_FloatType IAFminf, SP_FloatType IAFmsup,
                                            const SP_FloatType sampRate, int k);

/**
 * @brief Weight RMS depending on NaN RMS qualities, good peaks and RMS qualities sum
 * 
 * @param RMSCalibPacket Computed RMS
 * @param qualityRMS Computed RMS quality
 * @param QFNaN Indexes of NaN qualities into qualityRMS
 * @param goodPeak Indexes of good peaks into computed RMS
 * @param sumQf Sum of good RMS qualities
 * @return SP_FloatVector Weighted RMS
 */
SP_FloatVector weightRMS(const SP_Vector& RMSCalibPacket, const SP_Vector& qualityRMS,
                            const std::vector<int>& QFNaN, const std::vector<int>& goodPeak, SP_RealType sumQf);

/**
 * @brief Compute RMS calibration
 * 
 * @param calibrationRecordings A matrix holding the concatenation of the calibration recordings, one channel per row. (No GPIOs)
 * @param entireGoodCalibrationRecordings 
 * @param packetsToKeepIndex 
 * @param histFreq Vector containing the previous frequencies.
 * @param IAFinf Lower bound of the frequency range which will be used to compute SNR. For example IAFinf = 7 to compute SNR alpha.
 * @param IAFsup Upper bound of the frequency range which will be used to compute SNR. For example IAFsup = 13 to compute SNR alpha.
 * @param sampRate The signal sampling rate.
 * @param smoothingDuration Integer that gives the number of relaxation indexes we have to take into account to
          smooth the current one. For instance smoothingDuration=2 means we average the current relaxationIndex
          with the previous one.
 * @return std::pair<SP_FloatVector, SP_FloatVector> Absolute and relative RMS calibration
 */
std::pair<SP_FloatVector, SP_FloatVector> computeRMSCalib(SP_FloatMatrix& calibrationRecordings, SP_Matrix& entireGoodCalibrationRecordings,
                                const std::vector<int>& packetsToKeepIndex, SP_FloatVector& histFreq, SP_FloatType IAFminf, SP_FloatType IAFmsup,
                                const SP_FloatType sampRate,int smoothingDuration);

/**
 * @brief Compute smoothed RMS calibration
 * 
 * @param RMSCalib RMS calibration
 * @param smoothingDuration Integer that gives the number of relaxation indexes we have to take into account to
          smooth the current one. For instance smoothingDuration=2 means we average the current relaxationIndex
          with the previous one.
 * @return SP_FloatVector Smoothen RMS calibration
 */
SP_FloatVector computeSmoothedRMSCalib(const SP_FloatVector& RMSCalib, int smoothingDuration);

class CalibrationOutputKeys {
    public:
        static const std::string RMS;
        static const std::string RELATIVE_RMS;
        static const std::string SMOOTHED_RMS;
        static const std::string HIST_FREQ;
        static const std::string ERROR_MSG;
};

/*
 * @brief Takes the data from the calibration recordings and compute the necessary parameters that is to say the channel
          with the best quality (in a vector named calibrationParameters["BestChannel"]) and a vector containing the Smoothed SNR values from
          the best channel of the calibration, stored in a vector named calibrationParameters["SNRCalib_ofBestChannel"]. The Smoothed SNR values
          are computed each second with segments of 4s with a sliding window of 1s.
 * @param calibrationRecordings A matrix holding the concatenation of the calibration recordings, one channel per row. (No GPIOs)
 * @param calibrationRecordingsQuality A matrix holding the quality values, one channel per row, in the same order as in the matrix. (No GPIOs) Each quality value is between 0 and 1, and is the quality for a packet.
 * @param sampRate The signal sampling rate.
 * @param packetLength The number of data points in a packet.
 * @param IAFinf Lower bound of the frequency range which will be used to compute SNR. For example IAFinf = 7 to compute SNR alpha.
 * @param IAFsup Upper bound of the frequency range which will be used to compute SNR. For example IAFsup = 13 to compute SNR alpha.
 * @param histFreq Vector containing the previous frequencies.
 * @param smoothingDuration Integer that gives the number of relaxation indexes we have to take into account to
          smooth the current one. For instance smoothingDuration=2 means we average the current relaxationIndex
          with the previous one.
 * @return A dictionnary with the value for the various parameters.
 * @todo Use an enum for the output parameters?
 * @warning Works with any number of channels, but only keeps the best channel.
 */
std::map<std::string, SP_FloatVector > MBT_ComputeCalibration(SP_FloatMatrix calibrationRecordings, SP_FloatMatrix calibrationRecordingsQuality, const SP_FloatType sampRate, const int packetLength, const SP_FloatType IAFinf, const SP_FloatType IAFsup, int smoothingDuration);


#endif // MBT_COMPUTECALIBRATION_H_INCLUDED
