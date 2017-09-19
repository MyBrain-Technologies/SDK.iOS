//
//  MBTSignalProcessingBridge.m
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 15/09/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

#import "MBTSignalProcessingBridge.h"


#include "MBT_Matrix.h" // use of the class MBT_Matrix
#include "MBT_MainQC.h" // use of the class MBT_Matrix
#include "MBT_ReadInputOrWriteOutput.h" // use of the class MBT_ReadInputOrWriteOutput

#include "MBT_PWelchComputer.h" // use of the class MBT_PWelchComputer
#include "MBT_Operations.h"

#include "MBT_BandPass_fftw3.h"


@interface MBTQualityCheckerBridge: NSObject

+ (MBT_MainQC)initializeMainQualityChecker;

@end



@implementation MBTQualityCheckerBridge

+ (MBT_MainQC)initializeMainQualityChecker {
    float sampRate = 250;
    
    // Construction de trainingFeatures
    MBT_Matrix<float> trainingFeatures = MBT_readMatrix("C:/Users/Fanny/Documents/Melomind.Algorithms/QualityChecker/Files/trainingFeatures_BrainAmp.txt");
    
    // Construction de trainingClasses
    std::vector<std::complex<float> > tmp_trainingClasses = MBT_readVector("C:/Users/Fanny/Documents/Melomind.Algorithms/QualityChecker/Files/trainingClasses_BrainAmp.txt");
    std::vector<float> trainingClasses;
    trainingClasses.assign(tmp_trainingClasses.size(),0);
    for (unsigned int t=0;t<tmp_trainingClasses.size();t++)
    {
        trainingClasses[t] = tmp_trainingClasses[t].real();
    }
    
    // Construction de w
    std::vector<std::complex<float> > tmp_w = MBT_readVector("C:/Users/Fanny/Documents/Melomind.Algorithms/QualityChecker/Files/trainingW_BrainAmp.txt");
    std::vector<float> w;
    w.assign(tmp_w.size(),0);
    for (unsigned int t=0;t<tmp_w.size();t++)
    {
        w[t] = tmp_w[t].real();
    }
    
    // Construction de mu
    std::vector<std::complex<float> > tmp_mu = MBT_readVector("C:/Users/Fanny/Documents/Melomind.Algorithms/QualityChecker/Files/trainingMu_BrainAmp.txt");
    std::vector<float> mu;
    mu.assign(tmp_mu.size(),0);
    for (unsigned int t=0;t<tmp_mu.size();t++)
    {
        mu[t] = tmp_mu[t].real();
    }
    
    // Construction de sigma
    std::vector<std::complex<float> > tmp_sigma = MBT_readVector("C:/Users/Fanny/Documents/Melomind.Algorithms/QualityChecker/Files/trainingSigma_BrainAmp.txt");
    std::vector<float> sigma;
    sigma.assign(tmp_sigma.size(),0);
    for (unsigned int t=0;t<tmp_sigma.size();t++)
    {
        sigma[t] = tmp_sigma[t].real();
    }
    
    // Construction de kppv
    unsigned int kppv = 7;
    
    // Construction de costClass
    MBT_Matrix<float> costClass(3,3);
    for (int t=0;t<costClass.size().first;t++)
    {
        for (int t1=0;t1<costClass.size().second;t1++)
        {
            if (t == t1)
            {
                costClass(t,t1) = 0;
            }
            else
            {
                costClass(t,t1) = 1;
            }
        }
    }
    
    // Construction de potTrainingFeatures
    std::vector< std::vector<float> > potTrainingFeatures;
    
    // Construction de dataClean
    std::vector< std::vector<float> > dataClean;
    
    // Construction de spectrumClean
    std::vector<std::complex<float> > tmp_spectrumClean = MBT_readVector("C:/Users/Fanny/Documents/Melomind.Algorithms/QualityChecker/Files/spectrumClean.txt");
    std::vector<float> spectrumClean;
    spectrumClean.assign(tmp_spectrumClean.size(),0);
    for (unsigned int t=0;t<tmp_spectrumClean.size();t++)
    {
        spectrumClean[t] = tmp_spectrumClean[t].real();
    }
    
    // Construction de cleanItakuraDistance
    std::vector<std::complex<float> > tmp_cleanItakuraDistance = MBT_readVector("C:/Users/Fanny/Documents/Melomind.Algorithms/QualityChecker/Files/cleanItakuraDistance.txt");
    std::vector<float> cleanItakuraDistance;
    cleanItakuraDistance.assign(tmp_cleanItakuraDistance.size(),0);
    for (unsigned int t=0;t<tmp_cleanItakuraDistance.size();t++)
    {
        cleanItakuraDistance[t] = tmp_cleanItakuraDistance[t].real();
    }
    
    
    // Construction de accuracy
    float accuracy = (float)0.85;
    
    
    return MBT_MainQC(sampRate, trainingFeatures, trainingClasses, w, mu, sigma, kppv, costClass, potTrainingFeatures, dataClean, spectrumClean, cleanItakuraDistance, accuracy);
}

@end
