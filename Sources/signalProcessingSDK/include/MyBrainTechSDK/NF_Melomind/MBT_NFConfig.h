/**
 * @file MBT_NFConfig.h
 *
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 *
 * @brief Configuration structure for Neurofeedback computations
 *
 */

#ifndef MBT_NFCONFIG_H
#define MBT_NFCONFIG_H

/**
 * @brief Configuration parameters for Neurofeedback
 * 
 */
struct MBT_NFConfig {
    /**
     * @brief Sample rate of the signals used for the QualityChecker
     * 
     */
    const float sampRate;
    /**
     * @brief Number of EEG data per EEGPacket
     * 
     */
    const unsigned int packetLength;
    /**
     * @brief Number of relaxation indexes we have to take into account to smooth the current one.
     *      For instance smoothingDuration=2 means we average the current relaxationIndex with the previous one.
     * 
     */
    const int smoothingDuration;
    /**
     * @brief Size of the buffer
     * 
     */
    const float bufferSize;
};

#endif // MBT_NFCONFIG_H