// MBT_Contour.h
// Created by Katerina Pandremmenou on 2017/01/09.
// Copyright (c) 2017 Katerina Pandremmenou. All rights reserved.
// 
// Update on 03/04/2017 by Katerina Pandremmenou (convert everything from float to double)
// Update on 5/07/2017 by Katerina Pandremmenou (fix all the warnings, put all static functions in the corresponding .cpp file)

#ifndef _MBT_Contour_
#define _MBT_Contour_

#include "TimeFrequency/MBT_TF_map.h"

#include "DataManipulation/MBT_Matrix.h"
#include "Algebra/MBT_Operations.h"

#include <iomanip>

using namespace std;

// This is the quanta in which we increase this_contour.
#define CONTOUR_QUANT 50

const SP_RealType Threshold = 0.1; 
const int isolines = 1;

// Calculates the isoline value
SP_RealType ContourThresholds(SP_Matrix TFMap);

// Calls all the necessary functions for drawing contours
SP_Matrix Contourc(SP_Matrix TFMap, SP_RealType threshold);

// Returns the bounds of each submatrix of contour
MBT_Matrix<int> C2xyz(SP_Matrix ContourResults);

#endif
