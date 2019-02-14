//
//  MBT_ComputeRelaxIndex.cpp
//
//  Created by Fanny Grosselin on 06/01/2017.
//  Copyright (c) 2017 myBrain Technologies. All rights reserved.
//
//  Update: Fanny Grosselin 2017/01/16 --> Remove the normalization of SNR because we do that after smoothing and not before.
//          Fanny Grosselin 2017/02/03 --> Get the Bounds (from parametersFromCalibration) to detect the outliers of the signal.
// 		    Fanny Grosselin 2017/03/23 --> Change float by double for the functions not directly used by Andro�d. For the others, keep inputs and outputs in double, but do the steps with double.
//          Fanny Grosselin 2017/03/27 --> Fix all the warnings.
//          Fanny Grosselin 2017/09/18 --> Remove Bounds from the input of MBT_ComputeSNR
//          Katerina Pandremmenou 2017/09/20 --> Change the preprocessing (use the bounds from calibration and set the outliers to NaN
//                                               interpolate the nan values between the channels, interpolate each channel across itself,
//                                               remove possible remaining nan values in the beginning or the end of an MBT_Matrix.
//                                               Change all implicit type castings to explicit ones
//          Katerina Pandremmenou 2017/09/28 --> Put all the block with outliers to nan, interpolatation between and across channels,
//                                               in the case where the calibration is good.
//                                           --> Put outliers of BOTH channels to NaN. Put in comments the function for ignoring remaining nan values. (This is done in MBT_ComputeSNR file).
//          Fanny Grosselin 2017/10/10 --> Remove the preprocessing of the outliers because it will be done in MBT_ComputeSNR.
//          Fanny Grosselin 2017/10/16 --> Compute SNR on the other channel each time we have 4 consecutive seconds with a quality of 0 in the best channel.
//          Fanny Grosselin 2017/12/05 --> Add histFreq (the vector containing the previous frequencies) in input.
//          Fanny Grosselin 2017/12/14 --> Set in input error messages instead of a dictionnary of parameters from calibration.
//          Fanny Grosselin 2017/12/14 --> Change the code to compute SNR from both channels.
//          Fanny Grosselin 2017/12/22 --> Add raw SNR values in the map holding parameters of the session.
//          Fanny Grosselin 2017/12/22 --> Put all the keys of maps in camelcase.
//          Fanny Grosselin 2018/01/24 --> Optimize the way we use histFreq.
//          Etienne GARIN   2018/01/26 --> Fixed input and output as map is no longer required here
//          Xavier Navarro  2018/09/14 --> Adapted to RMS computation (SNR names substituted by RMS)

#include "../Headers/MBT_ComputeRelaxIndex.h"

float MBT_ComputeRelaxIndex(MBT_Matrix<float> sessionPacket, std::vector<float>errorMsg, const float sampRate, double IAFinf, double IAFsup, std::vector<float> &histFreq)
{
    MBT_Matrix<double> sessionPacketdouble(sessionPacket.size().first,sessionPacket.size().second);
    for (int sample = 0; sample < sessionPacket.size().second; sample++)
    {
        for (int ch = 0;ch < sessionPacket.size().first; ch++)
        {
                sessionPacketdouble(ch,sample) = (double) sessionPacket(ch,sample);
        }
    }



    std::map<std::string, std::vector<float> > sessionParameters;

    //std::vector<float> RMSSession;
    float rms = 0;

    if ((sessionPacket.size().first>0) & (sessionPacket.size().second>0) & (errorMsg[0] != -2) & (errorMsg[0] != -1))
    {
        // Compute RMS
        std::map<std::string, std::vector<double> >  computeRMSSession = MBT_ComputeRMS(sessionPacketdouble, double(sampRate), IAFinf, IAFsup, histFreq); // there is only one value but this is a vector
        std::vector<double> RMSSessionPacket = computeRMSSession["rms"];
        std::vector<double> qualityRMS = computeRMSSession["qualityRms"];


        // Combine RMS from both channel, according to the quality of the alpha peak:
        // compute general RMS from both channel, derived by qualityRMS of both
        // channel and the RMSSessionPacket of both channel
        // WARNING : THIS CODE IS CORRECT ONLY IF 2 CHANNELS !!!!!!!
        // -------------------------------------------------------------------
        std::vector<int> QFNaN;
        std::vector<int> goodPeak;
        double sumQf = 0.0;
        for (unsigned int cq = 0; cq<qualityRMS.size(); cq++)
        {
            if (std::isnan(qualityRMS[cq]))
            {
                QFNaN.push_back(cq);
            }
            else
            {
                sumQf = sumQf + qualityRMS[cq];
            }
            if (RMSSessionPacket[cq]>1) // find what are the channels with RMS>1
            {
                goodPeak.push_back(cq);
            }
        }
        if (!QFNaN.empty()) // if at least one channel has qualityRMS=NaN (nb peaks = 0 or >1), we don't weight the average of RMS
        {
            if (goodPeak.empty()) // if all channels have RMS=1 (no peak in both channels)
            {
                // we average the RMS of both channel: = (1+1)/2 = 1
                //RMSSession.push_back((float)1.0);
                rms = 1.0f;
            }
            else if ((!goodPeak.empty()) && (goodPeak.size()==1)) // if one channel has RMS>1 (no peak in 1 channel and 1 dominant peak in the other channel)
            {
                // we keep the RMS value of this channel
                //RMSSession.push_back((float)RMSSessionPacket[goodPeak[0]]);
                rms = (float)RMSSessionPacket[goodPeak[0]];
            }
            else if ((!goodPeak.empty()) && (goodPeak.size()==2)) // if both channel has RMS>1 (1 dominant peak in both channels)
            {
                // we average the RMS values of both channels
                double tmp_s = (RMSSessionPacket[goodPeak[0]] + RMSSessionPacket[goodPeak[1]])/2;
                //RMSSession.push_back((float)tmp_s);
                rms = (float) tmp_s;
            }
        }
        else // both channels have QFNaN~=NaN (1 dominant peak in each channel)
        {
            // we weight the RMS of each channel by its QFNaN
            double tmp_s = RMSSessionPacket[0]*(qualityRMS[0]/sumQf) + RMSSessionPacket[1]*(qualityRMS[1]/sumQf);
            //RMSSession.push_back((float)tmp_s);
            rms = (float) tmp_s;

        }
    }
    else
    {
        // Store values to be handled in case of problem into MBT_ComputeRelaxIndex
        //RMSSession.push_back(std::numeric_limits<float>::infinity());
        rms = std::numeric_limits<float>::infinity();
        errno = EINVAL;
        perror("ERROR: MBT_COMPUTERELAXINDEX CANNOT PROCESS WITHOUT GOOD INPUTS");
    }
    //return sessionParameters;
    return rms;
}
