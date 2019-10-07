//
//  MBTBridgeConstants.h
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 02/10/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

#ifndef MBTBridgeConstants_h
#define MBTBridgeConstants_h

#include <DataManipulation/MBT_Matrix.h>

extern const std::vector<float> trainingFeatureList;

extern const MBT_Matrix<float> trainingFeatures;

extern const std::vector<float> trainingClasses;

extern const std::vector<float> cleanItakuraDistance;

extern const std::vector<float> spectrumClean;

extern const std::vector<float> sigma;

extern const std::vector<float> mu;

extern const std::vector<float> w;

extern const std::vector<float> tmp_trainingFeaturesBad;

extern const MBT_Matrix<float> trainingFeaturesBad;

extern const std::vector<float> trainingClassesBad;

extern const std::vector<float> sigmaBad;

extern const std::vector<float> muBad;

extern const std::vector<float> wBad;


#endif /* MBTBridgeConstants_h */
