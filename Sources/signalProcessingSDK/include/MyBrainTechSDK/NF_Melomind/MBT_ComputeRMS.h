//
//  MBT_ComputeRMS.h
//
//  Created by Xavier Navarro on 14/09/2018.
//  Based in Fanny Grosselin's MBT_ComputeSNR.h
//  Copyright (c) 2018 myBrain Technologies. All rights reserved.
//

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

/**
 * @brief Compute Sqno sum ?
 * 
 * @param band A bandpassed signal
 * @return SP_RealType Sqno sum
 */
SP_RealType computeBandSqnoSum(SP_Vector band);

/**
 * @brief Compute RMS of a signal
 * 
 * @param signal 
 * @param sampRate The signal sampling rate.
 * @param IAFinf Lower bound of the frequency range which will be used to compute SNR. For example IAFinf = 7 to compute SNR alpha.
 * @param IAFsup Upper bound of the frequency range which will be used to compute SNR. For example IAFsup = 13 to compute SNR alpha.
 * @param histFreq 
 * @return std::map<std::string, SP_Vector > A dictionnary with rms and qualityRms
 */
std::map<std::string, SP_Vector >  MBT_ComputeRMS(SP_Matrix const signal, const SP_RealType sampRate,
                                                    const SP_RealType IAFinf, const SP_RealType IAFsup, SP_FloatVector &histFreq);


#endif // MBT_COMPUTERMS_H_INCLUDED
