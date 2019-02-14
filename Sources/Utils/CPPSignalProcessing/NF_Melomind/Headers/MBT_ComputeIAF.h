#ifndef MBT_COMPUTEIAF_H_INCLUDED
#define MBT_COMPUTEIAF_H_INCLUDED

//
//  MBT_ComputeIAF.h
//
//  Created by Fanny Grosselin on 14/09/2018.
//  Copyright (c) 2018 myBrain Technologies. All rights reserved.
//



#include <stdio.h>
#include <iostream>
#include <vector>
#include <iterator>
#include <algorithm>
#include <errno.h>
#include <limits>
#include <map>
#include "MBT_ComputeNoise.h"
#include "../../SignalProcessing.Cpp/DataManipulation/Headers/MBT_Matrix.h"
#include "../../SignalProcessing.Cpp/Transformations/Headers/MBT_PWelchComputer.h"
#include "../../SignalProcessing.Cpp/Transformations/Headers/MBT_FindPeak.h"
#include "../../SignalProcessing.Cpp/Algebra/Headers/MBT_FindClosest.h"
#include "../../SignalProcessing.Cpp/Algebra/Headers/MBT_Operations.h"
#include "../../SignalProcessing.Cpp/Algebra/Headers/MBT_Interpolation.h"
#include "../../SignalProcessing.Cpp/PreProcessing/Headers/MBT_PreProcessing.h"
#include "../../SignalProcessing.Cpp/PreProcessing/Headers/MBT_BandPass_fftw3.h"
#include "../../SignalProcessing.Cpp/DataManipulation/Headers/MBT_ReadInputOrWriteOutput.h"



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
std::map<std::string, std::vector<double> >  MBT_ComputeIAF(MBT_Matrix<double> const signal, const double sampRate, const double IAFinf, const double IAFsup, std::vector<float> &histFreq);

#endif // MBT_COMPUTEIAF_H_INCLUDED
