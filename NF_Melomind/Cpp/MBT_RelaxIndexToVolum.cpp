//
//  MBT_SmoothRelaxIndex.cpp
//
//  Created by Fanny Grosselin on 06/01/2017.
//  Copyright (c) 2017 myBrain Technologies. All rights reserved.
//

#include "../Headers/MBT_RelaxIndexToVolum.h"

float MBT_RelaxIndexToVolum(const float smoothedRelaxIndex)
{
    float volum;
    if (smoothedRelaxIndex == std::numeric_limits<float>::infinity())
    {
        // Store values to be handled in case of problem into MBT_RelaxIndexToVolum
        volum = -1;
        errno = EINVAL;
        perror("ERROR: MBT_RELAXINDEXTOVOLUM CANNOT PROCESS WITHOUT SMOOTHEDRELAXINDEX IN INPUT");
    }
    else if (isnan(smoothedRelaxIndex))
    {
        // if 4 eeg packets have a bad quality, its eeg values are set to NaN. So we put a volum which is the middle of the scale that is to say 0.5.
        volum = 0.5;
        std::cout<<"At least four consecutive EEG packets have bad quality."<<std::endl;
    }
    else
    {
        float rescale = tanh(smoothedRelaxIndex); // rescale between -1 and 1
        rescale = rescale + 1; // rescale between 0 and 2
        rescale = rescale/2; // rescale between 0 and 1
        volum = 1 - rescale;
    }
    return volum;
}

