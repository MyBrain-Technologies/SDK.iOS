/**
 * @file MBT_ComputeRMS.h
 *
 * @author Xavier Navarro
 * @author Fanny Grosselin
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 *
 * @brief Compute RMS
 *
 */

#ifndef MBT_COMPUTERMS_H_INCLUDED
#define MBT_COMPUTERMS_H_INCLUDED

#include <sp-global.h>

#include <DataManipulation/MBT_Matrix.h>

#include <map>
#include <string>

// TODO : Move it to MBT_Operations ?
/**
 * @brief Compute squared sum of a signal
 * 
 * @param signal A signal
 * @return std::pair<SP_RealType, SP_RealType> Squared sum of the signal samples and number of NaN samples
 */
std::pair<SP_RealType, SP_RealType> computeSquaredSum(SP_Vector signal);

/**
 * @brief Compute RMS of a signal, if freqBounds are specified, compute it after filtering
 * 
 * @param signal A signal
 * @param freqBounds Frequency bounds to apply for filtering
 * @return SP_RealType RMS value of the signal
 */
SP_RealType computeRMS(SP_Vector signal, SP_Vector freqBounds = {});

class RmsOutputKeys {
    public:
        static const std::string ABSOLUTE;
        static const std::string RELATIVE;
        static const std::string QUALITY;
};

/**
 * @brief Compute RMS of a signal and the quality of the computation
 * 
 * @param signal The signal to compute the RMS.
 * @param sampRate The signal sampling rate.
 * @param IAFinf Lower bound of the frequency range which will be used to compute RMS. For example IAFinf = 7 to compute RMS alpha.
 * @param IAFsup Upper bound of the frequency range which will be used to compute RMS. For example IAFsup = 13 to compute RMS alpha.
 * @return std::map<std::string, SP_Vector > A dictionnary with rms and qualityRms
 */
std::map<std::string, SP_Vector >  MBT_ComputeRMS(SP_Matrix const signal, const SP_RealType sampRate,
                                                    const SP_RealType IAFinf, const SP_RealType IAFsup);


#endif // MBT_COMPUTERMS_H_INCLUDED
