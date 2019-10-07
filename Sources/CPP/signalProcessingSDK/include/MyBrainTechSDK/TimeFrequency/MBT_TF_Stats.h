//
// MBT_TF_Stats.h
//
// Created by Katerina Pandremmenou on 30/01/2017
// Copyright (c) 2017 myBrain Technologies. All rights reserved.
//
// Update on 03/04/2017 by Katerina Pandremmenou: Convert everything from float to double

#ifndef MBT_TF_STATS_H
#define MBT_TF_STATS_H

#include "TimeFrequency/MBT_TF_map.h"

#include "DataManipulation/MBT_Matrix.h"
#include "PreProcessing/MBT_BandPass_fftw3.h"

using namespace std;

typedef vector<SP_Vector> VVDouble;
pair<VVDouble, vector<VVDouble>> CalculateStatistics(SP_Matrix, MBT_Matrix<int>, SP_Matrix);

class TF_Statistics
{
	public: 
		TF_Statistics();
		~TF_Statistics();
		
		// this function sorts the clusters from MinX to MaxX. Actually it reorders the clusters based on the one that is found first in time (x-axis)
	    pair<SP_Matrix, MBT_Matrix<int>> SortClustersFromMinXToMaxX(SP_Matrix, MBT_Matrix<int>);
	    
	    // finds the edge points and removes them from the clusters
	    // also, updates the bounds of the new clusters, after the removal of some points
	    pair<SP_Matrix, MBT_Matrix<int>> FindEdgePoints(SP_Matrix&, SP_Matrix, MBT_Matrix<int>);
	    
	    // calculates the area and the gravity center ofeach cluster
	    pair<SP_Vector, SP_Matrix> CalculateAreaAndGC(SP_Matrix, MBT_Matrix<int>);
	    pair<SP_Vector, SP_Matrix> CalculateAreaAndGC(VVDouble, VVDouble);
	    
	    // calculates the min and max values in x and y axis
	    pair<SP_Matrix, SP_Matrix> CalculateMinMax(SP_Matrix, MBT_Matrix<int>);
	    pair<SP_Matrix, SP_Matrix> CalculateMinMax(VVDouble, VVDouble);
	    
	    // calculates the timelengths of the clusters
	    SP_Vector CalculateTimeLength(SP_Matrix);
	    
	    // finds the indices of the clusters that do not close
	    vector<int> findOpenClusters(SP_Matrix);
	    	    
	    // updates the bounds to merge the clusters that do not close
	    pair<MBT_Matrix<int>, SP_Matrix> UpdateBoundsToMergeClusters(vector<int>, MBT_Matrix<int>, SP_Matrix);

	    // assigns the full array values to two 2d vectors, one for the xcoord and one for the ycoord
	    pair<VVDouble,VVDouble> AssignClusterValuesToVectors(MBT_Matrix<int>, SP_Matrix);

	    // joins the clusters that do not close and performs fliplr if needed
	    pair<VVDouble, VVDouble> JoinOpenClusters(vector<int>, VVDouble, VVDouble);
	    
	    // we check for continuously (or not) fully overlapping clusters and update the statistics accordingly
	    pair<VVDouble, vector<VVDouble>> FixFullyOverlappingClusters(VVDouble, VVDouble, SP_Matrix, SP_Matrix, SP_Vector, SP_Matrix, SP_Vector);

	    // we check for continuously (or not) partially overlapping clusters and update the statistics accordingly
	    pair<VVDouble, vector<VVDouble>> FixPartiallyOverlappingClusters(VVDouble, vector<VVDouble>);

	    
	private:
		// calculates the last edge effect from the beginning and the first edge effect from the end, for all the frequencies
	    MBT_Matrix<int> FindEdgeBounds(SP_Matrix);
	    
	    // updates the bounds after removing the edge points
	    MBT_Matrix<int> UpdateBounds(MBT_Matrix<int>, vector<int>);
	    const int constant = 6;
	   
	    // calculates the distances between the clusters
	    SP_Vector CalculateDistances(VVDouble);
	    
};

#endif // MBT_TF_STATS_H
