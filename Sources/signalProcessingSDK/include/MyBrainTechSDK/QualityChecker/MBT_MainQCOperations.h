/**
 * @file MBT_MainQCOperations.h
 *
 * @author Fanny Grosselin
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 *
 * @brief Features computations for quality checker
 *
 */

#ifndef __MBT_QCOperations__
#define __MBT_QCOperations__

#include <sp-global.h>

/**
 * @brief Check wether a signal contains only NaN values
 * 
 * @param input 
 * @return true 
 * @return false 
 */
bool hasOnlyNan(SP_FloatVector const& input);

/**
 * @brief Check wether a signal contains only NaN values
 * 
 * @param input 
 * @return true 
 * @return false 
 */
bool hasOnlyNan(SP_Vector const& input);

/**
 * @brief Prepare a signal for features computations by powing it to 10^6
 * 
 * @param inputSignal 
 * @param bandpassProcess 
 * @param firstBound 
 * @param secondBound 
 * @return SP_Vector 
 */
SP_Vector prepareSignalForFeaturesComputations(SP_FloatVector const& inputSignal, bool bandpassProcess, SP_FloatType firstBound, SP_FloatType secondBound);

/**
 * @brief Compute the power of two of a signal, without DC
 * 
 * @param input
 * @return SP_Vector
 */
SP_Vector powerOfTwoWithoutDC(SP_Vector const& input);

/**
 * @brief Compute the sum of absolute values of a vector of double
 * 
 * @param input
 * @return SP_RealType
 */
SP_RealType absoluteSum(SP_Vector const& input);

/**
 * @brief Compute simple square integral of a signal
 * 
 * @param input 
 * @return SP_RealType 
 */
SP_RealType simpleSquareIntegral(SP_Vector const& input);

/**
 * @brief Compute V2-order of a signal
 * 
 * @param input 
 * @return SP_RealType 
 */
SP_RealType computeV2(SP_Vector const& input);

/**
 * @brief Compute V3-order of a signal
 * 
 * @param input 
 * @return SP_RealType 
 */
SP_RealType computeV3(SP_Vector const& input);

/**
 * @brief Compute log detector of a signal
 * 
 * @param input 
 * @return SP_RealType 
 */
SP_RealType computeLogDetector(SP_Vector const& input);

/**
 * @brief Compute average amplitude change of a signal
 * 
 * @param input 
 * @return SP_RealType 
 */
SP_RealType averageAmplitudeChange(SP_Vector const& input);

/**
 * @brief Compute the difference absolute standard deviation of a signal
 * 
 * @param input 
 * @return SP_RealType 
 */
SP_RealType differenceAbsoluteStandardDeviation(SP_Vector const& input);

/**
 * @brief Compute first derivative of a signal
 * 
 * @param input 
 * @param sampRate 
 * @return SP_Vector 
 */
SP_Vector timeFirstDerivative(SP_Vector const& input, SP_FloatType sampRate);

/**
 * @brief Compute second derivative of a signal, with its first derivative
 * 
 * @param input 
 * @param derivativeInput 
 * @param sampRate 
 * @return SP_Vector 
 */
SP_Vector timeSecondDerivative(SP_Vector const& input, SP_Vector const& derivativeInput, SP_FloatType sampRate);

/**
 * @brief Compute occurences of min/max values from derivative
 * A min/max counter is added everytime the derivative is < 0.01
 * 
 * @param derivativeInput 
 * @return int 
 */
int nbMaxMinFromTimeDerivative(SP_Vector const& derivativeInput);

/**
 * @brief Compute mobility of a signal from it's first derivative
 * 
 * @param input 
 * @param derivativeInput 
 * @return SP_RealType 
 */
SP_RealType computeMobilityFromTimeDerivative(SP_Vector const& input, SP_Vector const& derivativeInput);

/**
 * @brief Compute complexity of a signal
 * 
 * @param derivativeInput 
 * @param secondDerivativeInput 
 * @param mobility 
 * @return SP_RealType 
 */
SP_RealType computeComplexity(SP_Vector const& derivativeInput, SP_Vector const& secondDerivativeInput, SP_RealType mobility);

/**
 * @brief Compute zero crossing rate of a signal
 * 
 * @param input 
 * @return SP_RealType 
 */
SP_RealType zeroCrossingRate(SP_Vector const& input);

/**
 * @brief Compute non linear energy of a signal
 * 
 * @param input 
 * @return SP_Vector 
 */
SP_Vector nonLinearEnergy(SP_Vector const& input);

SP_Vector getDeltaBand(SP_Vector const& input);
SP_Vector getThetaBand(SP_Vector const& input);
SP_Vector getAlphaBand(SP_Vector const& input);
SP_Vector getBetaBand(SP_Vector const& input);
SP_Vector getGammaBand(SP_Vector const& input);

/**
 * @brief Perform zero padding on a signal
 * 
 * @param input Input signal
 * @param int New size of the signal
 * @param int Computed number of zero to add to the signal
 * @param int Number of zero added to the signal
 */
void zeroPadding(SP_Vector& input, unsigned int& N, unsigned int& nfft, unsigned int& nb_zero_added);

/**
 * @brief Compute one sided spectrum
 * 
 * @param input input signal
 * @param nfft Computed number of zero to add to the signal
 * @param sampRate Sample rate of the signal
 * @param EEG_power 
 * @param freqVector
 */
SP_RealType oneSidedSpectrum(SP_Vector const& input, unsigned int nfft, SP_FloatType sampRate, SP_Vector& EEG_power, SP_Vector& freqVector);

/**
 * @brief Compute delta ratio of a signal
 * 
 * @param freqVector 
 * @param EEG_power 
 * @param AUC_EEG_power 
 * @param delta_power 
 * @return SP_RealType 
 */
SP_RealType deltaRatio(SP_Vector const& freqVector, SP_Vector const& EEG_power, SP_RealType AUC_EEG_power, SP_Vector& delta_power);

/**
 * @brief Compute theta ratio of a signal
 * 
 * @param freqVector 
 * @param EEG_power 
 * @param AUC_EEG_power 
 * @param theta_power 
 * @return SP_RealType 
 */
SP_RealType thetaRatio(SP_Vector const& freqVector, SP_Vector const& EEG_power, SP_RealType AUC_EEG_power, SP_Vector& theta_power);

/**
 * @brief Compute alpha ratio of a signal
 * 
 * @param freqVector 
 * @param EEG_power 
 * @param AUC_EEG_power 
 * @param alpha_power 
 * @return SP_RealType 
 */
SP_RealType alphaRatio(SP_Vector const& freqVector, SP_Vector const& EEG_power, SP_RealType AUC_EEG_power, SP_Vector& alpha_power);

/**
 * @brief Compute beta ratio of a signal
 * 
 * @param freqVector 
 * @param EEG_power 
 * @param AUC_EEG_power 
 * @param beta_power 
 * @return SP_RealType 
 */
SP_RealType betaRatio(SP_Vector const& freqVector, SP_Vector const& EEG_power, SP_RealType AUC_EEG_power, SP_Vector& beta_power);

/**
 * @brief Compute gamma ratio of a signal
 * 
 * @param freqVector 
 * @param EEG_power 
 * @param AUC_EEG_power 
 * @param gamma_power 
 * @return SP_RealType 
 */
SP_RealType gammaRatio(SP_Vector const& freqVector, SP_Vector const& EEG_power, SP_RealType AUC_EEG_power, SP_Vector& gamma_power);

/**
 * @brief Compute band power of a signal
 * 
 * @param band_power 
 * @return SP_RealType 
 */
SP_RealType bandPow(SP_Vector const& band_power);

/**
 * @brief Compute logarithmic band power of a signal
 * 
 * @param band_pow 
 * @return SP_RealType 
 */
SP_RealType logBandPow(SP_RealType const &band_pow);

/**
 * @brief Compute normalized band power of a signal
 * 
 * @param band_pow 
 * @param ttp 
 * @return SP_RealType 
 */
SP_RealType normBandPow(SP_RealType const& band_pow, SP_RealType const& ttp);

/**
 * @brief Compute normalize EEG power
 * 
 * @param EEG_power 
 * @param sum_EEG_power 
 * @return SP_Vector 
 */
SP_Vector computeEEGPowerNorm(SP_Vector const& EEG_power, SP_RealType sum_EEG_power);

/**
 * @brief Compute cumulative EEG power ?
 * 
 * @param EEG_power_norm 
 * @return SP_Vector 
 */
SP_Vector computeEEGPowerCum(SP_Vector const& EEG_power_norm);

/**
 * @brief Compute spectral edge frequency
 * 
 * @param freqVector 
 * @param EEG_power 
 * @param EEG_power_cum 
 * @param sum_EEG_power 
 * @param percentage 
 * @return SP_RealType 
 */
SP_RealType spectralEdgeFrequency(SP_Vector const& freqVector, SP_Vector const& EEG_power, SP_Vector const& EEG_power_cum, SP_RealType sum_EEG_power, double percentage);

/**
 * @brief Compute relative spectral difference between a signal's band and its neighbours
 * 
 * @param left_pow Left band power
 * @param current_pow Current band power
 * @param right_pow Right band power
 * @return SP_RealType 
 */
SP_RealType relativeSpectralDifference(SP_RealType left_pow, SP_RealType current_pow, SP_RealType right_pow);

/**
 * @brief Compute signal to noise ratio (SNR) of a signal
 * 
 * @param freqVector 
 * @param EEG_power 
 * @param ttp 
 * @return SP_RealType 
 */
SP_RealType signalToNoiseRatio(SP_Vector const& freqVector, SP_Vector const& EEG_power, SP_RealType const& ttp);

/**
 * @brief Compute power spectrum moment
 * 
 * @param EEG_power 
 * @return SP_RealType 
 */
SP_RealType powerSpectrumMoment(SP_Vector const& EEG_power, SP_Vector const& freqVector, int pow);

/**
 * @brief Compute power spectrum center frequency
 * 
 * @param m0 
 * @param m1 
 * @return SP_RealType 
 */
SP_RealType powerSpectrumCenterFreq(SP_RealType m0, SP_RealType m1);

/**
 * @brief Compute spectral RMS
 * 
 * @param m0 
 * @param int 
 * @param int 
 * @return SP_RealType 
 */
SP_RealType spectralRMS(SP_RealType m0, unsigned int& N, unsigned int& nb_zero_added);

/**
 * @brief Compute index of spectral deformation
 * 
 * @param m0 
 * @param m1 
 * @param m2 
 * @param center_freq 
 * @return SP_RealType 
 */
SP_RealType spectralDeformationIndex(SP_RealType m0, SP_RealType m1, SP_RealType m2, SP_RealType center_freq);

/**
 * @brief Compute modified median frequency
 * 
 * @param freqVector 
 * @param EEG_power 
 * @param sampRate 
 * @return SP_RealType The value of the smallest found index
 */
SP_RealType modifiedMedianFrequency(SP_Vector const& freqVector, SP_Vector const& EEG_power, SP_FloatType sampRate);

/**
 * @brief Compute modified mean frequency
 * 
 * @param freqVector 
 * @param EEG_power 
 * @param sum_EEG_power 
 * @return SP_RealType 
 */
SP_RealType modifiedMeanFrequency(SP_Vector const& freqVector, SP_Vector const& EEG_power, SP_RealType sum_EEG_power);

/**
 * @brief Compute spectral entropy
 * 
 * @param freqVector 
 * @param EEG_power 
 * @return SP_RealType 
 */
SP_RealType spectralEntropy(SP_Vector const& freqVector, SP_Vector const& EEG_power);

#endif // __MBT_QCOperations__