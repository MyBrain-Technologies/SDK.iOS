//
// MBT_PreProcess.h
//
// Created by Katerina Pandremmenou on 2016/09/29
// Copyright (c) 2016 myBrain Technologies. All rights reserved.
//
// Update: 08/12/2016 - Inclusion of detrend, calculateGain
//         03/02/2017 by Fanny Grosselin : Add a method to interpolate outliers
// 		   23/03/2017 by Fanny Grosselin : Change float by double for the functions not directly used by Androïd. For the others, keep inputs and outputs in float, but do the steps with double or create two functions : one with only float, another one with only double.
// Update on 31/03/2017 by Katerina Pandremmenou (Inclusion of RemoveDCF2D function)
// Update on 03/04/2017 by Katerina Pandremmenou (Inclusion of CalculateBounds function for doubles)


#ifndef MBT_PREPROCESSING_H
#define MBT_PREPROCESSING_H


#include <vector>
#include <algorithm>
#include <functional>
#include <iostream>
#include "math.h" // for nan()

#include "../../Algebra/Headers/MBT_Interpolation.h"

using namespace std;

// Method which removes the DC offset
vector<float>  RemoveDC(vector<float> Data);
vector<double> RemoveDC(vector<double> Data);
// takes float in input and returns double in output
vector<double> RemoveDCF2D(vector<float> Data);

// Methods for caculating the lower and upper bound
// for floats
vector<float> CalculateBounds(vector<float> DataNoDC);
// for doubles
vector<double> CalculateBounds(vector<double> DataNoDC);

// Method that removes the outliers
vector<double> RemoveOutliers(vector<double> DataNoDC, vector<double> Bounds);

// Method that interpolate the outliers  // Fanny Grosselin 2017/02/03
/*
 * Interpolate the outliers detected by Bounds from DataNoDC
 * @params: DataNoDC Vector of double which holds the data
 * @params: Bounds Vector of double which holds the low bound and the up bound to detect outliers
 * @return: the signal with the interpolated outliers
*/
vector<double> InterpolateOutliers(vector<double> DataNoDC, vector<double> Bounds);

// Method that finds the quantiles
vector<double> Quantile(vector<double>& CalibNoDC);

// Quantile's helping function
double Lerp(double v0, double v1, double t);

/*
 * Removes the best straight-line fit from vector x and returns it in y
 * @params: the original signal and the sampling frequency
 * @return: the detrended signal
*/
vector<double> detrend(vector<double> original, const double fs);

/*
 * Compute the gain of a signal of double after amplification
 * @params: the original signal, the amplified signal
 * @return: the amplification gain
*/
double calculateGain(vector<double> const& original, vector<double> const& amplified);

// Method which replaces EEG values by nan values
vector<double> MBT_remove(vector<double> signalToRemove);

// Method which corrects artifacts
vector<double> MBT_correctArtifact(vector<double> signalToCorrect);

#endif // MBT_PREPROCESSING_H
