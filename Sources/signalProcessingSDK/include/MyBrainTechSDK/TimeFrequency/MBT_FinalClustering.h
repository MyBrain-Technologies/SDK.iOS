//
// MBT_FinalClustering.h
//
// Created by Katerina Pandremmenou on 16/03/2017
// Copyright (c) 2017 myBrain Technologies. All rights reserved.
// Update on 03/04/2017 by Katerina Pandremmenou (Convert everything from double to double)

#ifndef MBT_FINAL_CLUSTERING_H
#define MBT_FINAL_CLUSTERING_H

#include "Algebra/MBT_Operations.h"

#include <vector>
#include <iostream>
#include <algorithm>
#include <assert.h>

using namespace std;

// this functions handles all the functions in this file. It creates an object of this class and operates on the statistics update
// the output is an MBT_Matrix of size: 3xlength_of_the_updated_vectors
// the first row includes the updated areas
// the second row the updated timelengths
// the third row the updated distances
SP_Matrix FurtherGroupStatistics(SP_Vector, SP_Matrix, vector<int>, const SP_RealType);

class GROUP_STATISTICS
{
	public:
		GROUP_STATISTICS();
		~GROUP_STATISTICS();

		// this function updates all the statistics (areas, timelengths, distances) after the k-means clustering
		SP_Matrix FinalClustering(SP_Vector, SP_Matrix, vector<int>, const SP_RealType);
		// this function indicates where we have a transition from one cluster to another
		vector<int> FindClusterTransition(vector<int>);
};


#endif // MBT_FINAL_CLUSTERING_H