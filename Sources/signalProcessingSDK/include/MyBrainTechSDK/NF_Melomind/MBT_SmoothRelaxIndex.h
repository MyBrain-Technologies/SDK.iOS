/**
 * @file MBT_SmoothRelaxIndex.h
 * 
 * @author Fanny Grosselin
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 * 
 * @brief Compute the IAF in a specific frequency band
 * 
 */

#ifndef MBT_SMOOTHRELAXINDEX_H_INCLUDED
#define MBT_SMOOTHRELAXINDEX_H_INCLUDED

#include <sp-global.h>

/*
 * @brief Smooth the last relaxation index which is holded by pastRelaxIndexes. Only one smoothed relaxation
 *        index by second but this is computed on a signal of 4s with a sliding window of 1s.
 * @param tmp_pastRelaxIndexes Vector holding the relaxation indexes.
 * @param smoothingDuration Integer that gives the number of relaxation indexes we have to take into account to
          smooth the current one. For instance smoothingDuration=2 means we average the current relaxationIndex
          with the previous one.
 * @return The smoothed last relaxation index value.
 */
SP_FloatType MBT_SmoothRelaxIndex(SP_FloatVector tmp_pastRelaxIndexes, int smoothingDuration);

#endif // MBT_SMOOTHRELAXINDEX_H_INCLUDED
