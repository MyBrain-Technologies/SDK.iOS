/**
 * @file MBT_MainQCItakura.h
 *
 * @author Fanny Grosselin
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 *
 * @brief Itakura distance computations for quality checker
 *
 */

#ifndef __MBT_QCITAKURA__
#define __MBT_QCITAKURA__

#include <sp-global.h>

#include <Transformations/MBT_PWelchComputer.h>

/**
 * @brief Format data and intialize a PWelchComputer
 * 
 * @param input 
 * @param sampRate 
 * @return MBT_PWelchComputer 
 */
MBT_PWelchComputer computePWelch(SP_FloatVector const& input, SP_FloatType sampRate);

/**
 * @brief Take values with frequency < 40Hz
 * 
 * @param f 
 * @param pf2 
 */
void lowPass40Hz(SP_Vector f, SP_Vector pf2);

/**
 * @brief Compute Itakura distance
 * 
 * @param spectrumClean 
 * @param pf2 
 * @return SP_RealType 
 */
SP_RealType computeItakuraDistance(SP_FloatVector spectrumClean, SP_Vector pf2);

#endif // __MBT_QCITAKURA__