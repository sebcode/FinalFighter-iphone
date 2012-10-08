
#import "GameConstants.h"

#ifndef FinalFighter_GameDebug_h
#define FinalFighter_GameDebug_h

//@class GameLevelTutorial;
//@class GameLevelFragtemple;
//@class GameLevelOverkillz;
//@class GameLevelHauntedHalls;
@class GameLevelYerLethalMetal;

#ifdef PRODUCTION_BUILD
    #define START_SCENE [MenuLayer scene]
#else
    #define START_SCENE [MenuLayer scene]
    //#define START_SCENE [WorldLayer sceneWithLevel:[GameLevelTutorial class] tank:1]
    //#define START_SCENE [WorldLayer sceneWithLevel:[GameLevelFragtemple class] tank:1]
    //#define START_SCENE [WorldLayer sceneWithLevel:[GameLevelYerLethalMetal class] tank:1]
#endif

#endif
