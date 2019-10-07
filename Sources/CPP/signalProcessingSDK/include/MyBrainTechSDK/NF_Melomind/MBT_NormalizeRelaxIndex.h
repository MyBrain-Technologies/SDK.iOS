/**
 * @file MBT_NormalizeRelaxIndex.h
 *
 * @author Fanny Grosselin
 * @author Ludovic Bailly
 * @author Xavier Navarro
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 *
 * @brief Configuration structure for Neurofeedback computations
 *
 */

#ifndef MBT_NORMALIZERELAXINDEX_H_INCLUDED
#define MBT_NORMALIZERELAXINDEX_H_INCLUDED

#include <vector>
#include <errno.h>
#include <limits>
#include "Algebra/MBT_Operations.h"

/**
 * @brief Takes a smoothed SNR value from the session recordings and normalize it with the mean and the standard deviation
 *        of the smoothed SNR values from the calibration. Only one normalized smoothed relaxation index by second but this is
 *        computed on a signal of 4s with a sliding window of 1s.
 * 
 * @param relaxIndexSession A float holding a smoothed SNR value from the session.
 * @param relaxIndexCalibration A vector holding the smoothed SNR values from the calibration.
 * @return SP_FloatType The smoothed SNR value from the session.
 */
SP_FloatType MBT_NormalizeRelaxIndex(SP_FloatType relaxIndexSession, SP_FloatVector relaxIndexCalibration);

#endif // MBT_NORMALIZERELAXINDEX_H_INCLUDED
