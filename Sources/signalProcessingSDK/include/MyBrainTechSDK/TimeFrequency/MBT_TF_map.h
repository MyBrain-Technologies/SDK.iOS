// MBT_TF_map.h
// Created by Katerina Pandremmenou on 06/06/2016.
// Copyright (c) 2016 Katerina Pandremmenou. All rights reserved.
//
// Update on 09/12/2016 by Katerina Pandremmenou (no Armadillo, double-->float)
// Update on 03/04/2017 by Katerina Pandremmenou (convert everything from float to double)
// Update on 05/04/2017 by Katerina Pandremmenou (Fix all the warnings)

#ifndef _MBT_TF_map_
#define _MBT_TF_map_

#include "TimeFrequency/MBT_TF_map.h"

#include "DataManipulation/MBT_Matrix.h"
#include "Algebra/MBT_Operations.h"

#include <vector>
#include <complex>
#include <iomanip>

using namespace std;

typedef SP_Complex ComplexDouble;
typedef SP_ComplexVector CDVector;

// Edge points at the beginning that correspond to frequencies 5 Hz - 15 Hz (7Hz-2, 13Hz+2)
const vector<int> AllEdgePoints = {76, 63, 54, 47, 42, 38, 35, 32, 29, 27, 26}; 
	
// this function calculates the TF map
SP_Matrix TF(SP_Vector signal, const SP_RealType fs, SP_Vector powers, SP_Vector frequencies);
// this function calculates the TF mask
MBT_Matrix<int> TF_mask(int, int);
// this function calculates the frequency peak based on the maximum power in the range of [7Hz ~ 13Hz]
int get_freqPeak(SP_Vector, SP_Vector);
// this function calculates the minimum (after zero) and maximum values of the TF map
SP_Vector MinMaxTFMap(SP_Matrix);
bool great(SP_RealType value);

class TF_map {
public:
    TF_map();
    ~TF_map();
    
protected:
    const SP_RealType fc = 1;
    const SP_RealType FWHM_tc = 3;
    const SP_RealType sigma_tc = FWHM_tc / sqrt(8*log(2));
    int precision = 3;
    ComplexDouble i = -1;
};

#endif
