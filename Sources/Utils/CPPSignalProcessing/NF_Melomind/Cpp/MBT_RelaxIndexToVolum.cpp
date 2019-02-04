//
//  MBT_SmoothRelaxIndex.cpp
//
//  Created by Fanny Grosselin on 06/01/2017.
//  Copyright (c) 2017 myBrain Technologies. All rights reserved.
//
//  Update : Katerina Pandremmenou on 20/09/2017 --> Change all implicit type castings to explicit ones
//           Fanny Grosselin on 27/09/2017 --> Change the volum to 1 when smoothRelaxIndex is nan instead of 0.5.
//           Fanny Grosselin on 10/10/2017 --> Change the way we map the values between 0 and 1.
//           Fanny Grosselin on 11/10/2017 --> Change the value of the volum to 1 when smoothedRelaxIndex=infinity.
//           Fanny Grosselin on 14/12/2017 --> Change one of the call of the map parametersFromCalibration.
//           Fanny Grosselin on 18/12/2017 --> Change one input by another (the map of parameters from calibration to the vector of relax index from calibration).
//           Xavier Navarro on 23/08/2018  --> Change on inputs: two values (min_val, max_val) instead of the whole vector of SNRs. To optimize, scale values are computed in main function

#include "../Headers/MBT_RelaxIndexToVolum.h"

float MBT_RelaxIndexToVolum(const float smoothedRelaxIndex, const float min_val, const float max_val)
{
    float volum;
    float rescale=0;
    
    if (smoothedRelaxIndex == std::numeric_limits<float>::infinity())
    {
        // Store values to be handled in case of problem into MBT_RelaxIndexToVolum
        volum = 1.0;
        errno = EINVAL;
        perror("ERROR: MBT_RelaxIndexToVolum CANNOT PROCESS WITHOUT SMOOTHEDRELAXINDEX IN INPUT");
    }
    else if (isnan(smoothedRelaxIndex))
    {
        // if 4 eeg packets have a bad quality, its eeg values are set to NaN. So we put a volum which is the middle of the scale that is to say 0.5.
        volum = 1.0;
        std::cout<<"At least four consecutive EEG packets have bad quality."<<std::endl;
    }
    else
    {
        rescale = (smoothedRelaxIndex - min_val) / (max_val - min_val);
        if (rescale > 1)
        {
            rescale = 1;
        }
        if (rescale < 0)
        {
            rescale = 0;
        }
        volum = 1 - rescale;
        std::cout << "vol : " << volum << '\n';
    }
    return volum;
}

