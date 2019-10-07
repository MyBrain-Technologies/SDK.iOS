/**
 * @file MBT_RelaxIndexToVolum.h
 *
 * @author Katerina Pandremmenou
 * @author Fanny Grosselin
 * @author Xavier Navarro
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 *
 * @brief Transform normalized smooth relax index to volum value
 *
 */

#ifndef MBT_RELAXINDEXTOVOLUM_H_INCLUDED
#define MBT_RELAXINDEXTOVOLUM_H_INCLUDED

#include <sp-global.h>

/*
 * @brief Transform the normalized smoothed relaxation index of the signal into volum value. For now, only takes only one value by one value into account.
 *        Only one volum value by second but this is computed on a signal of 4s with a sliding window of 1s.
 * @param smoothedRelaxIndex Float holding the normalized smoothed relaxation index.
 * @param SNRCalib A vector holding the relax index from calibration.
 * @return The volum value which corresponds to the normalized smoothed relaxation index value.
 */
SP_FloatType MBT_RelaxIndexToVolum(const SP_FloatType smoothedRelaxIndex, const SP_FloatType min_val, const SP_FloatType max_val);


#endif // MBT_RELAXINDEXTOVOLUM_H_INCLUDED
