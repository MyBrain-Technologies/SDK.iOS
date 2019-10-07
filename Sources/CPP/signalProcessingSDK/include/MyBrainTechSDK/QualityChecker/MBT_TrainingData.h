/**
 * @file MBT_TrainingData.h
 *
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 *
 * @brief Training data for quality checker computations
 *
 */

#ifndef MBT_TRAININGDATA_H
#define MBT_TRAININGDATA_H

#include <sp-global.h>

#include <DataManipulation/MBT_Matrix.h>

/**
 * @brief Compute average features values across training features data
 * 
 * @param featuresMatrix A matrix containing features (columns) for a dataset of signal (rows)
 * @return SP_FloatVector Average features values accross training data
 */
SP_FloatVector averageFeatures(const SP_FloatMatrix& featuresMatrix);

/**
 * @brief Compute standard deviation features values across training features data
 * 
 * @param featuresMatrix A matrix containing features (columns) for a dataset of signal (rows)
 * @return SP_FloatVector Standard deviation of features values
 */
SP_FloatVector standardDeviationFeatures(const SP_FloatMatrix& featuresMatrix);

/**
 * @brief Get the number Of unique values from a vector
 * 
 * @param vec The vector to analyze
 * @return unsigned int Number of unique occurences
 */
unsigned int getNumberOfUniqueValues(const SP_FloatVector& vec);

/**
 * @brief Build a costClass matrix from a trainingClasses vector
 * 
 * @param trainingClasses The vector of training classes
 * @return SP_FloatMatrix The result costClass matrix
 */
SP_FloatMatrix buildCostClass(const SP_FloatVector& trainingClasses);

/**
 * @brief Quality Checker training data container
 */
class MBT_TrainingData
{
    public:
    /**
     * @brief Construct a new MBT_TrainingData object
     * @deprecated
     * 
     * @param trainingFeatures 
     * @param trainingClasses 
     * @param w 
     * @param mu 
     * @param sigma 
     * @param costClassSize 
     */
    MBT_TrainingData(const SP_FloatMatrix& trainingFeatures, const SP_FloatVector& trainingClasses,
                        const SP_FloatVector& w, const SP_FloatVector& mu,
                        const SP_FloatVector& sigma, const unsigned int costClassSize);
    
    /**
     * @brief Construct a new MBT_TrainingData object
     * 
     * @param trainingFeatures 
     * @param trainingClasses 
     * @param wFile 
     */
    MBT_TrainingData(const SP_FloatMatrix& trainingFeatures, const SP_FloatVector& trainingClasses,
                        const SP_FloatVector& wFile);

    /**
     * @brief Training features
     */
    SP_FloatMatrix m_trainingFeatures;
    /**
     * @brief Quality labels of each features
     */
    SP_FloatVector m_trainingClasses;
    /**
     * @brief Weights
     */
    SP_FloatVector m_w;
    /**
     * @brief Average features values accross training data
     */
    SP_FloatVector m_mu;
    /**
     * @brief Standard deviation of features values
     */
    SP_FloatVector m_sigma;
    /**
     * @brief Cost class matrix, size is equals to trainingClasses unique values count
     * 
     */
    SP_FloatMatrix m_costClass;
    
};

#endif // MBT_TRAININGDATA_H
