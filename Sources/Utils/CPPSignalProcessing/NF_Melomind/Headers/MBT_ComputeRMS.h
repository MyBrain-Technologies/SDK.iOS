//
//  MBT_ComputeRMS.h
//
//  Created by Xavier Navarro on 14/09/2018.
//  Based in Fanny Grosselin's MBT_ComputeSNR.h
//  Copyright (c) 2018 myBrain Technologies. All rights reserved.
//


#ifndef MBT_COMPUTERMS_H_INCLUDED
#define MBT_COMPUTERMS_H_INCLUDED

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


std::map<std::string, std::vector<double> >  MBT_ComputeRMS(MBT_Matrix<double> const signal, const double sampRate, const double IAFinf, const double IAFsup, std::vector<float> &histFreq);


#endif // MBT_COMPUTERMS_H_INCLUDED
