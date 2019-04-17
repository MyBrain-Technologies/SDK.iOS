/**
 * @file MBT_TrainingDataReader.h
 *
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 *
 * @brief Read a training data with provided datasets
 *
 */

#ifndef MBT_TRAININGDATAREADER_H
#define MBT_TRAININGDATAREADER_H

#include "QualityChecker/MBT_TrainingData.h"

#include <sp-global.h>

#include <string>

/**
 * @brief Read a real vector from a complex vector file
 * 
 * @param filename 
 * @return SP_FloatVector 
 */
SP_FloatVector readComplexVectorToRealVector(const std::string &filename);

/**
 * @brief Quality Checker training data reader
 */
class MBT_TrainingDataReader
{
    public:
    /**
     * @brief Read a training data from all needed training files
     * 
     * @param trainingFeaturesFile 
     * @param trainingClassesFile 
     * @param wFile 
     * @param muFile 
     * @param sigmaFile 
     * @param costClassSize 
     * @return MBT_TrainingData 
     */
    static MBT_TrainingData read(const std::string& trainingFeaturesFile, const std::string& trainingClassesFile,
                        const std::string& wFile, const std::string& muFile,
                        const std::string& sigmaFile, const unsigned int costClassSize);
};

#endif // MBT_TRAININGDATAREADER_H
