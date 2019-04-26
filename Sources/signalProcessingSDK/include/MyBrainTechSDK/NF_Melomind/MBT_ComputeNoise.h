/**
 * @file MBT_ComputeNoise.h
 *
 * @author Fanny Grosselin
 * @author Xavier Navarro
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 *
 * @brief Calibration process generating the parameters necessary for the computation of the relaxation index.
 *          For now, the calibration is only taking the first two channels into account.
 *
 */

#ifndef MBT_COMPUTENOISE_H_INCLUDED
#define MBT_COMPUTENOISE_H_INCLUDED

#include <sp-global.h>

#define ARBITRARY_BACKGROUND_ESTIMATION_LOOP_COUNT 49

/**
 * @brief Format vector by applying 10*log10 to vector values
 * 
 * @param vector Vector to format
 * @return SP_Vector The resulting vector formatted
 */
SP_Vector formatVectorForNoiseComputation(const SP_Vector& vector);

/**
 * @brief Do fitting
 * 
 * @param t Copy of the vector that contains the frequency values of the spectrum.
 * @param y Copy of the vector containing the power value of the spectrum (not in log scale).
 * @return SP_Vector Noise power
 */
 SP_Vector doFitting(const SP_Vector& t, const SP_Vector& y);

/**
 * @brief Compute fitting error
 * 
 * @param t Copy of the vector that contains the frequency values of the spectrum.
 * @param tmp_noisePow1 
 * @param tmp_noisePow2 
 * @return SP_RealType Fitting error
 */
SP_RealType computeFittingError(const SP_Vector& t, const SP_Vector& tmp_noisePow1, const SP_Vector& tmp_noisePow2);

/*
 * @brief Estimate the background spectral noise by an iterative regression.
 * @param trunc_frequencies The vector that contains the frequency values of the spectrum.
 * @param trunc_channelPSD Te vector containing the power value of the spectrum (not in log scale).
 * @return The vector containing the estimated power values in log scale of the background estimated noise.
 */
SP_Vector MBT_ComputeNoise(SP_Vector trunc_frequencies, SP_Vector trunc_channelPSD);


#endif // MBT_COMPUTENOISE_H_INCLUDED
