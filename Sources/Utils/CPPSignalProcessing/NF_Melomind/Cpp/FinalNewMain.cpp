//
//  FinalNewMain.cpp
//
//  Created by Fanny Grosselin on 10/10/17.
//  Modified by Xavier Navarro & Fanny Grosselin on 14/09/18 to integrate improvements in the neurofeedback algorithm
//  Inspired by NewMain.cpp of the same folder
//  Copyright (c) 2018 myBrain Technologies. All rights reserved.
//
//  The purpose of this file is to test the final pipeline that integrate the new way i) to detect the alpha peak, ii) to compute the signal background noise
//  and iii) so to compute a combined RMS from both channels.
//  This pipeline used the preprocessing of the v2.1.0 versionning but ignoring the step concerning the choice of values from the other channel when the EEG values of the
//  best channel are NaN. Indeed, we have not anymore the notion of best channel because we compute RMS on both channel and not only on the best channel.


#include <iostream>
#include <stdio.h>
#include <vector>
#include <map>
#include <algorithm> // std::min_element
#include <iterator>  // std::begin, std::end
#include <string>
#include "../../SignalProcessing.Cpp/DataManipulation/Headers/MBT_ReadInputOrWriteOutput.h"
#include "../../SignalProcessing.Cpp/DataManipulation/Headers/MBT_ReadInputOrWriteOutput.h"
#include "../../SignalProcessing.Cpp/Algebra/Headers/MBT_FindClosest.h"
#include "../Headers/MBT_ComputeRMS.h"
#include "../Headers/MBT_ComputeIAFCalibration.h"
#include "../Headers/MBT_ComputeCalibration.h"
#include "../Headers/MBT_ComputeRelaxIndex.h"
#include "../Headers/MBT_SmoothRelaxIndex.h"
#include "../Headers/MBT_NormalizeRelaxIndex.h"
#include "../Headers/MBT_RelaxIndexToVolum.h"
#include "../../SignalProcessing.Cpp/PreProcessing/Headers/MBT_PreProcessing.h"
#include "../../SignalProcessing.Cpp/PreProcessing/Headers/MBT_BandPass_fftw3.h"
#include "../../version.h" // version.h of NF_Melomind

using namespace std;

//Here are defined the alpha band limits
#define IAFinf 6 // warning: it's 6 and not 7
#define IAFsup 13


// COMPUTE THE CALIBRATION PARAMETERS

// INPUTS:
// ------
// sampRate: [float] the sampling rate
// packetLength: [int] the number of eeg data per eegPacket
// calibrationRecordings: [MBT_Matrix<float>] the EEG signals as it's returned by the QualityChecker (number of rows = number of channels)
// calibrationRecordingsQualities: [MBT_Matrix<float>] the quality of each EEG signal as it's returned by the QualityChecker (number of rows = number of channels)
// smoothingDuration: Integer that gives the number of relaxation indexes we have to take into account to
//                    smooth the current one. For instance smoothingDuration=2 means we average the current relaxationIndex
//                    with the previous one.
//
// OUTPUTS:
// -------
// the calibration map

std::map<string, std::vector<float>> main_calibration(float sampRate, unsigned int packetLength, MBT_Matrix<float> calibrationRecordings, MBT_Matrix<float> calibrationRecordingsQuality, int smoothingDuration)
{
    std::vector<float> histFreq;

    // Calibration-----------------------------------
    // Find the frequencies of the alpha band
    std::vector<float> iafMedian = MBT_ComputeIAFCalibration(calibrationRecordings,calibrationRecordingsQuality, sampRate, packetLength, IAFinf, IAFsup);
    std::map<std::string, std::vector<float> > paramCalib = MBT_ComputeCalibration(calibrationRecordings,calibrationRecordingsQuality, sampRate, packetLength, iafMedian[0], iafMedian[1], smoothingDuration);
    paramCalib["iafCalib"] = iafMedian;
    return paramCalib;
}


// PLAY THE SESSION

// INPUTS:
// ------
// sampRate: [float] the sampling rate
// paramCalib: the calibration map
// sessionPacket: [MBT_Matrix<float>] the EEG signals on real-time during session as it's returned by the QualityChecker (number of rows = number of channels)
// histFreq: [vector of float] containing the frequency of the alpha peak detected previously (previously means during calibration and the previous packets of the session)
//            If it's the first packet of the session: get histFreq from paramCalib --> histFreq = paramCalib["HistFrequencies"];
//            else: get histFreq from session -->  histFreq = paramSession["HistFrequencies"];
// pastRelaxIndex: [vector of float] containing the previous relax index computed during the session (not smoothed).
// smoothingDuration: Integer that gives the number of relaxation indexes we have to take into account to
//                    smooth the current one. For instance smoothingDuration=2 means we average the current relaxationIndex
//                    with the previous one.
//
// OUTPUT:
// ------
// a map containing some measures during the session (RMS, smoothed RMS, history of frequency, volum)
//TODO maybe pass a map in input that is filled each time this is called instead of recreating temp vectors
//TODO paramCalib could also be a reference
float main_relaxIndex(const float sampRate, std::map<std::string, std::vector<float> > paramCalib,
                                                     const MBT_Matrix<float> &sessionPacket, std::vector<float> &histFreq, std::vector<float> &pastRelaxIndex, std::vector<float> &resultSmoothedRMS, std::vector<float> &resultVolum, int smoothingDuration, const float min_val, const float max_val)
{

    std::vector<float> errorMsg = paramCalib["errorMsg"];
    std::vector<float> iafMedian = paramCalib["iafCalib"];
    // Session-----------------------------------
    float rmsValue = MBT_ComputeRelaxIndex(sessionPacket, errorMsg, sampRate, iafMedian[0], iafMedian[1], histFreq);

    //TODO pastRelaxIndex could also be passed as reference in MBT_ComputeRelaxIndex. See if it is relevant to do so
    pastRelaxIndex.push_back(rmsValue); // incrementation of pastRelaxIndex
    float smoothedRelaxIndex = MBT_SmoothRelaxIndex(pastRelaxIndex,smoothingDuration);
    float volum = MBT_RelaxIndexToVolum(smoothedRelaxIndex, min_val, max_val); // warning it's not the same inputs than previously

    //resultSmoothedRMS.assign(1,smoothedRelaxIndex);
    resultSmoothedRMS.push_back(smoothedRelaxIndex);

    //resultVolum.assign(1,volum);
    resultVolum.push_back(volum);
    // WARNING: If it's possible, I would like to save in the .json file, pastRelaxIndex and smoothedRelaxIndex (both)

    return volum;
}


int main()
{
    // Calibration
    // ----------------------------------------------------------------------------------------------------------------------------------------------
    std::cout<<"CALIBRATION"<<std::endl;
    float sampRate = 250;
    unsigned int packetLength = 250;
    int smoothingDuration = 2;
    float bufferSize = 1;

    std::cout<<"Reading file..."<<std::endl;

     MBT_Matrix<float> calibrationRecordings = MBT_readMatrix("/Users/xnavarro/matlab/melomind/files/CalibrationRecordings.txt"); // absolute path for calling the executable
     MBT_Matrix<float> calibrationRecordingsQuality = MBT_readMatrix("/Users/xnavarro/matlab/melomind/files/CalibrationRecordingsQuality.txt"); // absolute path for calling the executable

    std::cout<<"End of reading"<<std::endl;

    std::map<string, std::vector<float>> paramCalib = main_calibration(sampRate, packetLength, calibrationRecordings, calibrationRecordingsQuality, smoothingDuration);


    std::vector<float> histFreq = paramCalib["histFrequencies"]; // update histFreq
    std::vector<float> tmp_errorMsg = paramCalib["errorMsg"];
    std::vector<float> tmp_RMSCalib = paramCalib["snrCalib"];
    std::vector<float> tmp_RawRMSCalib = paramCalib["rawSnrCalib"];

    // just to get them in text files
    std::vector<std::complex<float> > w_histFreq;
    for (unsigned int ki=0;ki<histFreq.size();ki++)
    {
        w_histFreq.push_back(std::complex<float>(histFreq[ki], 0));
    }


    std::vector<std::complex<float> > errorMsg;
    for (unsigned int ki=0;ki<tmp_errorMsg.size();ki++)
    {
        errorMsg.push_back(std::complex<float>(tmp_errorMsg[ki], 0));
    }


    std::vector<std::complex<float> > RMSCalib;
    for (unsigned int ki=0;ki<tmp_RMSCalib.size();ki++)
    {
        RMSCalib.push_back(std::complex<float>(tmp_RMSCalib[ki], 0));
    }

    MBT_writeVector (RMSCalib, "/Users/xnavarro/matlab/melomind/results/rmsCalib_x.txt"); // absolute path for calling the executable with matlab


    std::vector<std::complex<float> > RawRMSCalib;
    for (unsigned int ki=0;ki<tmp_RawRMSCalib.size();ki++)
    {
        RawRMSCalib.push_back(std::complex<float>(tmp_RawRMSCalib[ki], 0));
    }

    MBT_writeVector (RawRMSCalib, "/Users/xnavarro/matlab/melomind/results/rawRmsCalib_x.txt"); // absolute path for calling the executable with matlab

    // Computation of normalisation factor to rescale volume
    int ind_max;
    int ind_min;
    float min_val;
    float max_val;
    float avg;
    float sum;
    
    std::vector<float>::iterator result;
    result = std::max_element(tmp_RMSCalib.begin(), tmp_RMSCalib.end());
    ind_max = std::distance(tmp_RMSCalib.begin(), result);
    result = std::min_element(tmp_RMSCalib.begin(), tmp_RMSCalib.end());
    ind_min = std::distance(tmp_RMSCalib.begin(), result);
    
    for(int i = 1; i < tmp_RMSCalib.size(); i++){
        sum += tmp_RMSCalib[i];
    }
    avg = sum / tmp_RMSCalib.size();
    
    max_val = avg*1.5;
    min_val = tmp_RMSCalib[ind_min]*0.9;
    std::cout << "max val : " << tmp_RMSCalib[ind_max] << " min val " << tmp_RMSCalib[ind_min] << '\n';
    
    
    


    // Session
    // ----------------------------------------------------------------------------------------------------------------------------------------------
    std::cout<<"SESSION"<<std::endl;

    //TODO these vectors might be transformed into one single map to reduce the number of input. Better readability but less understandability
    std::vector<float> pastRelaxIndex;
    std::vector<float> smoothedRelaxIndex;
    std::vector<float> volum;

    std::cout<<"Reading file..."<<std::endl;
    MBT_Matrix<float> sessionRecordings = MBT_readMatrix("/Users/xnavarro/matlab/melomind/files/SessionRecordings.txt"); // absolute path for calling the executable with
    std::cout<<"End of reading"<<std::endl;

    unsigned int nbPacket = (unsigned int) (sessionRecordings.size().second/(sampRate)-1);
    for (unsigned int indPacket = 0; indPacket < nbPacket; indPacket++)
    {
        clock_t msecs;
        msecs = clock();

        MBT_Matrix<float> sessionPacket(2, bufferSize*(int)sampRate);;
        for (unsigned int sample=0; sample<bufferSize*sampRate; sample++)
        {
            sessionPacket(0,sample) = sessionRecordings(0,indPacket*(int)sampRate+sample);
            sessionPacket(1,sample) = sessionRecordings(1,indPacket*(int)sampRate+sample);
        }
        //Volum value to return to the application
        float newVolum = main_relaxIndex(sampRate, paramCalib, sessionPacket, histFreq, pastRelaxIndex, smoothedRelaxIndex, volum, smoothingDuration, min_val, max_val);

     //   std::cout << "Execution time = "<< ((float((clock()-msecs))) / CLOCKS_PER_SEC) << std::endl;
    }

    
    // -------------------------------------------------- writing txt files to disk -------------------------------------------------------------------
    std::vector<std::complex<float> > w2_histFreq;
    for (unsigned int ki=0;ki<histFreq.size();ki++)
    {
        w2_histFreq.push_back(std::complex<float>(histFreq[ki], 0));
    }

    std::vector<std::complex<float> > RawRMSSession;
    for (unsigned int ki=0;ki<pastRelaxIndex.size();ki++)
    {
        RawRMSSession.push_back(std::complex<float>(pastRelaxIndex[ki], 0));
    }
    MBT_writeVector (RawRMSSession, "/Users/xnavarro/matlab/melomind/results/rawRmsSession_x.txt");// absolute path for calling the executable with matlab


    std::vector<std::complex<float> > SmoothedRMSSession;
    for (unsigned int ki=0;ki<smoothedRelaxIndex.size();ki++)
    {
        SmoothedRMSSession.push_back(std::complex<float>(smoothedRelaxIndex[ki], 0));
    }
    MBT_writeVector (SmoothedRMSSession, "/Users/xnavarro/matlab/melomind/results/smoothedRmsSession_x.txt"); // absolute path for calling the executable with matlab

    std::vector<std::complex<float> > VolumSmoothedRMSSession;
    for (unsigned int ki=0;ki<volum.size();ki++)
    {
        VolumSmoothedRMSSession.push_back(std::complex<float>(volum[ki], 0));
    }
    MBT_writeVector (VolumSmoothedRMSSession, "/Users/xnavarro/matlab/melomind/results/volumSmoothedRmsSession_x.txt"); // absolute path for calling the executable with matlab
    
    std::cout<<"VERSION = "<<VERSION<<std::endl;
    
    return 0;
}
