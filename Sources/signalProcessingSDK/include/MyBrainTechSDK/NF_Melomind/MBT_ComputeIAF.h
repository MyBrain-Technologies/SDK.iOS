/**
 * @file MBT_ComputeIAF.h
 * 
 * @author Fanny Grosselin
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 * 
 * @brief Compute the IAF in a specific frequency band
 * 
 */

#ifndef MBT_COMPUTEIAF_H_INCLUDED
#define MBT_COMPUTEIAF_H_INCLUDED

#include <stdio.h>
#include <iostream>
#include <vector>
#include <iterator>
#include <algorithm>
#include <errno.h>
#include <limits>
#include <map>
#include "MBT_ComputeNoise.h"

#include "DataManipulation/MBT_Matrix.h"
#include "Transformations/MBT_PWelchComputer.h"
#include "Transformations/MBT_FindPeak.h"
#include "Algebra/MBT_FindClosest.h"
#include "Algebra/MBT_Operations.h"
#include "Algebra/MBT_Interpolation.h"
#include "PreProcessing/MBT_PreProcessing.h"
#include "PreProcessing/MBT_BandPass_fftw3.h"
#include "DataManipulation/MBT_ReadInputOrWriteOutput.h"

/**
 * @brief Check a vector contains only NaN, if so, set values of others vectors at index channel to contain a NaN
 * 
 * @param vect The vector to test
 * @param channel The index to add values if needed
 * @param IAF IAF values by channel
 * @param QF Quality values by channel
 * @return true The vector contains only NaN values
 * @return false The vector does not contains only NaN values
 */
bool checkHasOnlyNanAndSetResults(const SP_Vector& vect, int channel, SP_Vector& IAF, SP_Vector& QF);

/**
 * @brief Return number of peaks for no zero-crossing detected
 * 
 * @param peakBin peak bin
 * @return int Number of peaks, equals to zero
 */
int reportNan(SP_Vector& peakBin);

/**
 * @brief Return number of peaks for singular crossing
 * 
 * @param bin_index bin index
 * @param zero_cross_freq  zero cross frequency
 * @param peakBin peak bin
 * @param histFreq Vector containing the previous frequencies.
 * @return int Number of peaks, equals to one
 */
int singularCrossing(const std::vector<int>& bin_index, const SP_Vector& zero_cross_freq, SP_Vector& peakBin, SP_FloatVector &histFreq);

/**
 * @brief Find the peaks whose frequency is in the range ([mu_peakF-sigma_peakF : mu_peakF+sigma_peakF]) = condition D
 * 
 * @param zero_cross_freq  zero cross frequency
 * @param mu_peakF my peak f
 * @param sigma_peakF signa peak f
 * @param histFreq Vector containing the previous frequencies.
 * @return std::vector<int> Peaks indexes corresponding to the condition
 */
std::vector<int> findPeaksInRange(const SP_Vector& zero_cross_freq, const SP_RealType mu_peakF, const SP_RealType sigma_peakF, SP_FloatVector &histFreq);

/**
 * @brief ???
 * 
 * @param bin_index bin index
 * @param amp_difference amp difference
 * @param usualIdxPeak usual index peak
 * @param peakBin peak bin
 * @return int Number of peaks detected
 */
// TODO : possibility to merge findWithSeveralPeaks and findWithNoPeaks ?
int findWithSeveralPeaks(const std::vector<int>& bin_index, const SP_Vector& amp_difference, const std::vector<int>& usualIdxPeak, SP_Vector& peakBin);

/**
 * @brief ???
 * 
 * @param bin_index binary index
 * @param amp_difference amp difference
 * @param histFreq Vector containing the previous frequencies.
 * @param peakBin peak bin
 * @return int Number of peaks detected
 */
int findWithNoPeaks(const std::vector<int>& bin_index, const SP_Vector& amp_difference, SP_FloatVector &histFreq, SP_Vector& peakBin);

/**
 * @brief Find peaks
 * 
 * @param bin_index bin index
 * @param zero_cross_freq zero cross frequency
 * @param amp_difference amp difference
 * @param mu_peakF mu peak f
 * @param sigma_peakF sigma peak f
 * @param histFreq Vector containing the previous frequencies.
 * @param peakBin peak bin
 * @return int Number of peaks detected
 */
int findPeaks(const std::vector<int>& bin_index, const SP_Vector& zero_cross_freq, const SP_Vector& amp_difference,
                const SP_RealType mu_peakF, const SP_RealType sigma_peakF, SP_FloatVector &histFreq, SP_Vector& peakBin);

/**
 * @brief Sort out appropriate estimates for output
 * 
 * @param bin_index binary index
 * @param zero_cross_freq zero cross frequency
 * @param amp_difference amp difference
 * @param histFreq Temporary vector containing the previous frequencies.
 * @param peakBin peak bin
 * @return int 
 */
int sortoutEstimates(const std::vector<int>& bin_index, const SP_Vector& zero_cross_freq, const SP_Vector& amp_difference,
                        SP_FloatVector &histFreq, SP_Vector& peakBin);

/**
 * @brief Linear interpolation of NaN values of a vector
 * 
 * @param signal_ch The vector to replace NaN values by interpolated ones
 */
void linearInterpolationOfNan(SP_Vector& signal_ch);

/**
 * @brief Remove NaN from a vector and affect values to a matrix 
 * 
 * @param dataWithoutOutliers data with outliers
 * @return SP_Matrix 
 */
SP_Matrix removeNaNFromDataWithoutOutliersAndCreateAssociatedMatrix(SP_Vector& dataWithoutOutliers);

/**
 * @brief Compute the difference between the observed spectrum and the estimated one
 * 
 * @param logPSD Observed spectrum
 * @param noisePow Estimate spectrum
 * @return SP_Vector Difference between both spectrum
 */
SP_Vector computeDifferenceBetweenSpectrums(const SP_Vector& logPSD, const SP_Vector& noisePow);

/**
 * @brief Look for switch from positive to negative derivative values
 * 
 * @param trunc_frequencies trunc frequencies
 * @param d1 d1
 * @param difference Difference between observed and estimated spectrum
 * @param IAFinf Lower bound of the frequency range which will be used to compute IAF. For example IAFinf = 7.
 * @param IAFsup Upper bound of the frequency range which will be used to compute IAF. For example IAFsup = 13.
 * @param bin_index bin index
 * @param zero_cross_freq zero cross freq
 * @param amp_difference amp difference
 */
void downwardZeroCrossing(const SP_Vector& trunc_frequencies, const SP_Vector& d1, const SP_Vector& difference, const SP_RealType IAFinf, const SP_RealType IAFsup,
            std::vector<int>& bin_index, SP_Vector& zero_cross_freq, SP_Vector& amp_difference);

/**
 * @brief Find the closest point from the crossPoint_before
 * 
 * @param logPSD Observed spectrum
 * @param noisePow noise pow
 * @param tmp_crossPoint_before tmp cross point before
 * @param threshold_crossNoisePow_before threshold cross noise pow before
 * @param BinBeg bin beg
 * @return int Closest point from the crossPoint_before
 */
int computeMin1(const SP_Vector& logPSD, const SP_Vector& noisePow, const std::vector<int>& tmp_crossPoint_before, int threshold_crossNoisePow_before, int BinBeg);

/**
 * @brief Find the closest point from the crossPoint_after
 * 
 * @param logPSD Observed spectrum
 * @param noisePow noise pow
 * @param tmp_crossPoint_after tmp_crossPoint_after
 * @param threshold_crossNoisePow_after threshold_crossNoisePow_after
 * @param BinEnd BinEnd
 * @return int Closest point from the crossPoint_after
 */
int computeMin2(const SP_Vector& logPSD, const SP_Vector& noisePow, const std::vector<int>& tmp_crossPoint_after, int threshold_crossNoisePow_after, int BinEnd);

/**
 * @brief Compute alpha center of gravity
 * 
 * @param logPSD Observed spectrum
 * @param trunc_frequencies trunc_frequencies
 * @param bound_frequencies bound_frequencies
 * @param min1 Closest point from the crossPoint_before
 * @param min2 Closest point from the crossPoint_after
 * @param peakBin peakBin
 */
void alphaCenterGravity(const SP_Vector& logPSD, const SP_Vector& trunc_frequencies, const SP_Vector& bound_frequencies, int min1, int min2, SP_Vector& peakBin);

/**
 * @brief ???
 * 
 * @param difference difference
 * @param logPSD Observed spectrum
 * @param d1 d1
 * @param trunc_frequencies trunc_frequencies
 * @param noisePow noisePow
 * @param channel channel
 * @param IAFinf Lower bound of the frequency range which will be used to compute IAF. For example IAFinf = 7.
 * @param IAFsup Upper bound of the frequency range which will be used to compute IAF. For example IAFsup = 13.
 * @param nbPeak nbPeak
 * @param peakBin peakBin
 * @param IAF IAF
 * @param QF QF
 */
void computeIAFAndQF(const SP_Vector& difference, const SP_Vector& logPSD, const SP_Vector& d1,
                        const SP_Vector& trunc_frequencies, const SP_Vector& noisePow,
                        const int channel, const SP_RealType IAFinf, const SP_RealType IAFsup, const int nbPeak,
                        SP_Vector& peakBin, SP_Vector& IAF, SP_Vector& QF);

/**
 * @brief ???
 * 
 * @param dataWithoutOutliers dataWithoutOutliers
 * @param IAF IAF values by channel
 * @param QF Quality values by channel
 * @param freqBoundsBandPass freqBoundsBandPass
 * @param histFreq Vector containing the previous frequencies.
 * @param channel Signal channel we are currently working on
 * @param sampRate The sample rate.
 * @param IAFinf Lower bound of the frequency range which will be used to compute IAF. For example IAFinf = 7.
 * @param IAFsup Upper bound of the frequency range which will be used to compute IAF. For example IAFsup = 13.
 */
void computeWithoutOutliers(SP_Vector& dataWithoutOutliers, SP_Vector& IAF, SP_Vector& QF, SP_Vector& freqBoundsBandPass, SP_FloatVector &histFreq, const int channel, const SP_RealType sampRate, const SP_RealType IAFinf, const SP_RealType IAFsup);

/**
 * @brief Compute the IAF values
 * 
 * @param signal The matrix holding the EEG values. These signals should be preprocessed before using (DC removal, notch, bandpass, outliers removal).
 * @param IAF IAF values by channel
 * @param QF Quality values by channel
 * @param sampRate The sample rate.
 * @param IAFinf Lower bound of the frequency range which will be used to compute IAF. For example IAFinf = 7.
 * @param IAFsup Upper bound of the frequency range which will be used to compute IAF. For example IAFsup = 13.
 * @param histFreq Vector containing the previous frequencies.
 */
void computeIAFValues(SP_Matrix& signal, SP_Vector& IAF, SP_Vector& QF, const SP_RealType sampRate, const SP_RealType IAFinf, const SP_RealType IAFsup, SP_FloatVector &histFreq);

class IafOutputKeys {
    public:
        static const std::string IAF;
        static const std::string QUALITY;
};

/*
 * @brief Compute the IAF in a specific frequency band thanks to a linear interpolation of the noise.
 *        The IAF is computed each second with segments of n seconds with a sliding window of 1s.
 * @param signal The matrix holding the EEG values. These signals should be preprocessed before using (DC removal, notch, bandpass, outliers removal).
 * @param sampRate The sample rate.
 * @param IAFinf Lower bound of the frequency range which will be used to compute IAF. For example IAFinf = 7.
 * @param IAFsup Upper bound of the frequency range which will be used to compute IAF. For example IAFsup = 13.
 * @param histFreq Vector containing the previous frequencies.
 * @return A dictionnary containing one IAF value by channel and the updated vector histFreq.
 */
std::map<std::string, SP_Vector >  MBT_ComputeIAF(SP_Matrix const signal, const SP_RealType sampRate, const SP_RealType IAFinf, const SP_RealType IAFsup, SP_FloatVector &histFreq);

#endif // MBT_COMPUTEIAF_H_INCLUDED
