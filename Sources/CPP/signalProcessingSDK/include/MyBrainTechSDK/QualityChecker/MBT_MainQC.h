/**
 * @file MBT_MainQC.h
 *
 * @author Fanny Grosselin
 * @author Aeiocha Li
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 *
 * @brief Compute quality of a signal, depending on training features
 *
 */

#ifndef MBT_MAINQC_H
#define MBT_MAINQC_H

#include <sp-global.h>

#include "QualityChecker/MBT_TrainingData.h"

#include <DataManipulation/MBT_Matrix.h>

#include <vector>

/**
 * @brief Configuration parameters for Quality Checker
 * 
 */
struct MBT_QCConfig {
    /**
     * @brief Sample rate of the signals used for the QualityChecker
     * 
     */
    const float sampRate;
    /**
     * @brief Number of closest nearest neighbours to get
     * 
     */
    const unsigned int kppv;
};

class MBT_MainQC
{
    public:
        /**
         * @brief Construct a new MBT_MainQC object
         * @deprecated
         */
        MBT_MainQC(const SP_FloatType sampRate,SP_FloatMatrix trainingFeatures, SP_FloatVector trainingClasses, SP_FloatVector w,
                    SP_FloatVector mu, SP_FloatVector sigma, unsigned int const& kppv, SP_FloatMatrix const& costClass,
                    std::vector< SP_FloatVector > potTrainingFeatures, std::vector< SP_FloatVector > dataClean,
                    SP_FloatVector spectrumClean, SP_FloatVector cleanItakuraDistance, SP_FloatType accuracy,
                    SP_FloatMatrix trainingFeaturesBad, SP_FloatVector trainingClassesBad, SP_FloatVector wBad,
                    SP_FloatVector muBad, SP_FloatVector sigmaBad, SP_FloatMatrix const& costClassBad);

        /**
         * @brief Construct a new MBT_MainQC object
         * 
         * @param config 
         * @param goodTrainingData 
         * @param spectrumClean 
         * @param cleanItakuraDistance 
         * @param badTrainingData 
         */
        MBT_MainQC(const MBT_QCConfig& config, const MBT_TrainingData& goodTrainingData, SP_FloatVector spectrumClean,
                    SP_FloatVector cleanItakuraDistance, const MBT_TrainingData& badTrainingData);

        /**
         * @brief Compute the quality of the provided signal
         * 
         * @param inputData 
         * @param bandpassProcess 
         * @param firstBound 
         * @param secondBound 
         */
        void MBT_ComputeQuality(SP_FloatMatrix const& inputData, bool bandpassProcess = false, SP_FloatType firstBound = 2.0, SP_FloatType secondBound = 30.0);

        /**
         * @brief Method to compute a processed data for display purpose
         * The given process is:
         * Get the index where we have NaN
         * Interpolate linearly the NaN
         * Delete the NaN that can't be interpolated
         * Do the processing: RemoveDC and BandPassFilter
         * Put back the NaN to the processed data
         * 
         * @param inputData 
         * @param firstBound 
         * @param secondBound 
         * @return SP_FloatMatrix 
         */
        SP_FloatMatrix MBT_compute_data_to_display(SP_FloatMatrix const& inputData, SP_FloatType firstBound = 2.0, SP_FloatType secondBound = 30.0); // Method to compute a processed data for display purpose

        /** ACCESSORS */
        SP_FloatMatrix MBT_get_m_trainingFeatures();
        SP_FloatVector MBT_get_m_trainingClasses();
        SP_FloatVector MBT_get_m_w();
        SP_FloatVector MBT_get_m_mu();
        SP_FloatVector MBT_get_m_sigma();
        int MBT_get_m_kppv();
        SP_FloatMatrix MBT_get_m_costClass();
        SP_FloatMatrix MBT_get_m_trainingFeaturesBad();
        SP_FloatVector MBT_get_m_trainingClassesBad();
        SP_FloatVector MBT_get_m_wBad();
        SP_FloatVector MBT_get_m_muBad();
        SP_FloatVector MBT_get_m_sigmaBad();
        SP_FloatMatrix MBT_get_m_costClassBad();
        SP_FloatVector MBT_get_m_spectrumClean();
        SP_FloatVector MBT_get_m_cleanItakuraDistance();
        SP_FloatMatrix MBT_get_m_inputData();

        SP_FloatMatrix MBT_get_m_testFeatures();
        SP_FloatVector MBT_get_m_probaClass();
        SP_FloatVector MBT_get_m_predictedClass();
        SP_FloatVector MBT_get_m_quality();

    private:

        /**
         * @brief Initialize m_rawInterpData if needed
         * 
         */
        void initRawInterpData();

        /**
         * @brief Update m_rawInterpData with m_inputData
         * 
         */
        void updateRawInterpData();

        /**
         * @brief Update raw interpolated data with 1s of signal
         * 
         * @return SP_FloatMatrix Updated raw interpolated data
         */
        SP_FloatMatrix updateRawInterp1SecData();

        /**
         * @brief Update raw interpolated data with 2s of signal
         * 
         * @return SP_FloatMatrix Updated raw interpolated data
         */
        SP_FloatMatrix updateRawInterp2SecData();

        /**
         * @brief Check if rawInterpData_row contains NaN
         * 
         * @param rawInterpData_row Updated raw interpolated data
         * @return bool The data contains at least a NaN
         */
        bool hasNaN(const SP_Vector& rawInterpData_row);

        /**
         * @brief Update m_inputData with rawInterpData_row, depending on NaN count
         * 
         * @param ch Channel to update
         * @param rawInterpData_row Updated raw interpolated data
         */
        void updateInputDataAfterInterpolation(unsigned int ch, const SP_Vector& rawInterpData_row);

        /**
         * @brief Interpolate the possible NaN values inside inputData thanks to rawInterpData
         * 
         */
        void MBT_interpBTpacketLost();

        /**
         * @brief Calculates time features of an EEG observation
         * 
         * @param signal Signal of the EEG observation
         */

        /**
         * @brief Calculates time features of an EEG observation
         * 
         * @param signal Signal of the EEG observation
         * @return SP_Vector Vector of computed features
         */
        SP_Vector timeFeaturesQualityChecker(const SP_Vector& signal);

        /**
         * @brief Calculates frequency features of an EEG observation
         * 
         * @param signal Signal of the EEG observation
         * @return SP_Vector Vector of computed features
         */
        SP_Vector frequencyFeaturesQualityChecker(SP_Vector& signal);

        /**
         * @brief Calculates features of each EEG observation
         * 
         * @param bandpassProcess 
         * @param firstBound 
         * @param secondBound 
         */
        void MBT_featuresQualityChecker(bool bandpassProcess = false, SP_FloatType firstBound= 2.0, SP_FloatType secondBound = 30.0);

        /**
         * @brief Recover the different type of classes as specified by MBT_TrainingData::m_trainingClasses
         * 
         * @return SP_Vector Type of classes
         */
        SP_Vector recoverTypeClasses();

        /**
         * @brief Normalization of training dataset
         * 
         * @return SP_Matrix Normalized training dataset
         */
        SP_Matrix normalizeTrainingDataset();

        /**
         * @brief Initialize some MBT_MainQC members for Knn computations
         * 
         */
        void initializeKnnOutputs();

        /**
         * @brief Find distances between features
         * 
         * @param t Current feature row
         * @return SP_Vector Distances between features and their normalizations
         */
        SP_Vector findDistance(unsigned int t);

        /**
         * @brief Sort distances and find indexes
         * 
         * @param distanceNeighbor Distances between features and their normalizations
         * @param sortDistanceNeighbor Sorted distance without duplicate value
         * @param indiceNeighbor Indexes of the neighbors
         */
        void sortDistanceAndFindIndexes(const SP_Vector& distanceNeighbor, SP_Vector& sortDistanceNeighbor, std::vector<int>& indiceNeighbor);

        /**
         * @brief Compute probability class
         * 
         * @param typeClasses Type of classes
         * @param sortDistanceNeighbor Sorted distance without duplicate value
         * @param indiceNeighbor Indexes of the neighbors
         * @param minDist Normalization of distances
         * @return SP_Vector Probability classes
         */
        SP_Vector computeProbaClass(const SP_Vector& typeClasses, const SP_Vector& sortDistanceNeighbor, const std::vector<int>& indiceNeighbor, SP_RealType minDist);

        /**
         * @brief Predicting class labels and affecting results to members
         * 
         * @param typeClasses Type of classes
         * @param tmpProbaClass Probability classes
         * @param t Current feature row
         */
        void predictClassLabel(const SP_Vector& typeClasses, const SP_Vector& tmpProbaClass, unsigned int t);

        /**
         * @brief K-nearest neighbors classifier
         * 
         */
        void MBT_knn();

        /**
         * @brief Convert signal to uV
         * 
         * @param inputDataRow Input data row, corresponding to a signal
         * @return SP_Vector Signal converted to uV
         */
        SP_Vector interpolateSignaltouV(const SP_FloatVector& inputDataRow);

        /**
         * @brief Check if signal is constant
         * 
         * @param signal Signal converted to uV
         * @return int Constance of the signal
         */
        int checkSignalConstant(const SP_Vector& signal);

        /**
         * @brief Test amplitude variation of a signal
         * 
         * @param signal Signal converted to uV
         * @param t Current signal index from input data
         */
        void testAmplitudeVariation(const SP_Vector& signal, unsigned int t);

        /**
         * @brief Classify this to use bad classes
         * 
         * @param t Current signal index from input data
         */
        void classifyBadClasses(unsigned int t);

        /**
         * @brief Remove current signal from input data
         * 
         * @param signal Signal converted to uV
         * @param t Current signal index from input data
         */
        void removeCurrentSignalFromInput(SP_Vector& signal, unsigned int t);

        /**
         * @brief Process a signal with estimated quality equals to 0
         * 
         * @param signal Signal converted to uV
         * @param t Current signal index from input data
         */
        void processBadSignal(SP_Vector& signal, unsigned int t);

        /**
         * @brief Process a signal with estimated quality equals to 0.5
         * 
         * @param signal Signal converted to uV
         * @param signalInit 
         * @param t Current signal index from input data
         */
        void processMediumSignal(const SP_Vector& signal, const SP_Vector& signalInit, unsigned int t);

        /**
         * @brief Process a signal with estimated quality equals to 1
         * 
         * @param signalInit Original signal
         * @param t Current signal index from input data
         */
        void processGoodSignal(const SP_Vector& signalInit, unsigned int t);

        /**
         * @brief Gives the final quality of each observation and prepare each observation
         * (in function of its quality) to the relaxation index module
         * 
         * @param inputData 
         */
        void MBT_qualityChecker(SP_FloatMatrix inputData);

        /**
         * @brief Calculates the Itakura distance
         * between the averaged spectrum of clean data (quality = 1)
         * and the spectrum of each observation of EEG data (between 0 and 40Hz).
         * 
         * @param data 
         * @return SP_FloatType 
         */
        SP_FloatType MBT_itakuraDistance(SP_FloatVector data);

        /**
         * @brief Cast result, check it is not a nan and add a new value to the features
         * 
         * @param result The index of the next feature to add
         * @param channel Channel to add the feature on
         * @param index Index to add the feature on, incremented at each call
         */
        void castCheckAddFeature(SP_RealType result, int channel, int& index);

        /**
         * @brief Process input by interpolating NaN values, removing DC and applying a bandpass
         * 
         * @param tmpInputDataRow Signal data
         * @param freqBounds Frequency bounds to bandpass
         * @param x 
         * @param y 
         * @param xInterp 
         * @return SP_Vector Processed input
         */
        SP_Vector processInputDataRow(const SP_FloatVector& tmpInputDataRow, const SP_Vector& freqBounds, SP_Vector& x, SP_Vector& y, SP_Vector& xInterp);

        /**
         * @brief Process data to display by repushing NaN values as before interpolation
         * 
         * @param inputDataRow Signal data processed
         * @param xInterp 
         * @return SP_FloatVector Filtered data
         */
        SP_FloatVector processDataForDisplay(const SP_Vector& inputDataRow, const SP_Vector& xInterp);

        // Declaration of the attributes
        SP_FloatMatrix m_rawInterpData; // history of at most 2s of data possibly interpolated
        bool m_correctInput;
        SP_FloatType m_sampRate; // the sampling rate
        SP_FloatMatrix m_trainingFeatures; // array which contains the values of each features for the training dataset
        SP_FloatVector m_trainingClasses; // vector which contains the classes of each observation (of the training dataset)
        SP_FloatVector m_w; // vector which contains prior probabilities for each observation in the training dataset.
                                 // In general, the prior probability for each observation = 1
        SP_FloatVector m_mu; // vector which contains mean of each feature (of the training dataset)
        SP_FloatVector m_sigma; // vector which contains standard deviation of each feature (of the training dataset)
        unsigned int m_kppv; // number of nearest neighbors
        SP_FloatMatrix m_costClass; // square matrix with y rows and k columns (number of y = number of k)
                                        // It is the cost of classifying an observation as y when its true class is k.
        /**
         * @brief Row vector which is the averaged spectrum of
         * clean data (quality = 1) between 0 and 40Hz.
         * 
         * TODO : Could be recovered from trainingFeatures, may be computed on the fly
         */
        SP_FloatVector m_spectrumClean;
        /**
         * @brief Contains Itakura distances between each "clean" observations (quality = 1)
         * and the averaged spectrum of "clean" observations (quality = 1).
         * 
         * TODO : Could be recovered from trainingFeatures, may be computed on the fly
         */
        SP_FloatVector m_cleanItakuraDistance;
        SP_FloatMatrix m_trainingFeaturesBad; // array which contains the values of each features for the training dataset of bad data
        SP_FloatVector m_trainingClassesBad; // vector which contains the classes of each observation (of the training dataset of bad data)
        SP_FloatVector m_wBad; // vector which contains prior probabilities for each observation in the training dataset of bad data.
                                 // In general, the prior probability for each observation = 1
        SP_FloatVector m_muBad; // vector which contains mean of each feature (of the training dataset of bad data)
        SP_FloatVector m_sigmaBad; // vector which contains standard deviation of each feature (of the training dataset of bad data)
        SP_FloatMatrix m_costClassBad; // square matrix with y rows and k columns (number of y = number of k) for the training set of bad data.
                                        // It is the cost of classifying an observation as y when its true class is k.
        SP_FloatMatrix m_inputData; // array which contains the EEG values of each observation.

        SP_FloatMatrix m_testFeatures; // array which contains the values of each feature for the test dataset
        SP_FloatVector m_probaClass; // vector which contains for each tested observations the probability of the PredictedClass.
        SP_FloatVector m_predictedClass; // vector which contains the predicted classes of the (test) data to classify
        SP_FloatVector m_quality; // vector which contains the quality (0 for bad, 0.25 for
                                       // muscular artifacts, 0.5 for other artifacts, 1 for clean) of each observation

};

#endif // MBT_MAINQC_H
