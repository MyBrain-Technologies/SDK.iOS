/**
 * @file SessionMeanAlphaPower.h
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
 * Can't be instanciated, please use @ref getInstance
 * 
 */
class SessionMeanAlphaPower
{
    public:
        /**
         * @brief Get the Instance object
         * 
         * @return SessionMeanAlphaPower& 
         */
        static inline SessionMeanAlphaPower& getInstance() noexcept { return singleton; };

        /**
         * @brief Add a new alpha power value to the current session.
         * A new alpha power value is pushed if one of the qualities equals to 1
         * 
         * @param alphaPower The alpha power value to add
         * @param qualities Current qualities for each channel for the current alpha power
         */
        void addAlphaPower(SP_RealType alphaPower, SP_Vector qualities);

        /**
         * @brief Reset current session
         * 
         */
        void resetSession();

        /**
         * @brief Get the mean alpha power of the current session
         * 
         * @return SP_RealType Mean alpha power
         */
        SP_RealType getSessionMeanAlphaPower();

        /**
         * @brief Get the confidence rate of the current session
         * 
         * @return SP_RealType Confidence rate
         */
        SP_RealType getSessionConfidence();

    private:
        /**
         * @brief Singleton of the class
         * 
         */
        static SessionMeanAlphaPower singleton;

        /**
         * @brief Privately construct a SessionMeanAlphaPower
         * 
         */
        SessionMeanAlphaPower();
        
        /**
         * @brief Cumulation of current session power alpha values
         * 
         */
        SP_RealType alphaPowerCumul;

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