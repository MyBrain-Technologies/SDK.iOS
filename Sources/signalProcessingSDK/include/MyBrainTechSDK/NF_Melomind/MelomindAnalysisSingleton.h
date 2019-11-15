/**
 * @file MelomindAnalysisSingleton.h
 * 
 * @author Ludovic Bailly
 * @copyright Copyright (c) 2019 myBrain Technologies. All rights reserved.
 *
 * @brief Singleton class to get session mean power alpha and confidence depending on quality
 * This singleton pattern is temporary, and only due to lack of design of NF_Melomind module
 * which is currently not programmed as an OOP framework
 *
 */
#ifndef SESSION_MEAN_ALPHA_POWER_H
#define SESSION_MEAN_ALPHA_POWER_H

#include <sp-global.h>

/**
 * @brief Manage cumulation of alpha power computations of a session.
 * Not supposed to be instanciated, please use @ref getInstance
 * 
 */
class MelomindAnalysisSingleton
{
    public:
        /**
         * @brief Construct a MelomindAnalysisSingleton
         * 
         */
        MelomindAnalysisSingleton();

        /**
         * @brief Get the Instance object
         * 
         * @return MelomindAnalysisSingleton& 
         */
        static inline MelomindAnalysisSingleton& getInstance() noexcept { return singleton; };

        /**
         * @brief Add a new alpha power value to the current session.
         * 
         * @param alphaPower The alpha power value to add
         * @param alphaPowerRelative The relative alpha power value to add
         * @param qualities Current qualities for each channel for the current alpha power
         */
        void addAlphaPower(SP_RealType alphaPower, SP_RealType alphaPowerRelative, SP_Vector qualities);

        /**
         * @brief Reset current session
         * 
         */
        void resetSession();

        /**
         * @brief Get the mean alpha power of the current session
         * Also populates getSessionConfidence() data
         * 
         * @return SP_RealType Mean alpha power
         */
        SP_RealType getSessionMeanAlphaPower();

        /**
         * @brief Get the mean relative alpha power of the current session
         * Also populates getSessionConfidence() data
         * 
         * @return SP_RealType Mean alpha power
         */
        SP_RealType getSessionMeanRelativeAlphaPower();

        /**
         * @brief Get the alpha powers of the current session
         * 
         * @return SP_FloatVector Alpha powers of the session for each second
         */
        SP_FloatVector getSessionAlphaPowers();

        /**
         * @brief Get the relative alpha powers of the current session
         * 
         * @return SP_FloatVector Alpha powers of the session for each second
         */
        SP_FloatVector getSessionRelativeAlphaPowers();

        /**
         * @brief Get qualities of the current session
         * Qualities are multiplexed by channels ([q1c1, q1c2, q2c1, q2c2, q3c1, ...])
         * 
         * @return SP_RealType Qualities of each channel of the session for each second
         */
        SP_FloatVector getSessionQualities();

        /**
         * @brief Get the confidence rate of the current session
         * 
         * @return SP_RealType Confidence rate
         */
        SP_RealType getSessionConfidence();

    private:

        /**
         * @brief Compute mean power of a signal depending on channels qualities
         * A power value is used only if one channel quality equals to one
         * Also sets up getSessionConfidence() values
         * 
         * @param powerVector Power vector to use
         * @return SP_RealType Mean power of the signal
         */

        SP_RealType computePowerMean(const SP_Vector& powerVector);

        /**
         * @brief Singleton of the class
         * 
         */
        static MelomindAnalysisSingleton singleton;
        
        /**
         * @brief Cumulation of current session power alpha values
         * 
         */
        SP_Vector alphaPowerCumul;

        /**
         * @brief Cumulation of current session power alpha values
         * 
         */
        SP_Vector relativeAlphaPowerCumul;

        /**
         * @brief Cumulation of current session power alpha values
         * 
         */
        SP_Vector qualitiesCumul;

        /**
         * @brief Number of alpha values cumulated for the current session
         * 
         */
        unsigned int cumulCount;

        /**
         * @brief Number of calls of addAlphaPower for the current session
         * 
         */
        unsigned int callCount;
};

#endif // SESSION_MEAN_ALPHA_POWER_H