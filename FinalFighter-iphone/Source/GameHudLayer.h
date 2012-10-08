
#import <GameKit/GameKit.h>

#define LEADERBOARD_CATEGORY @"score"

@class WorldLayer;
@class GameArmory;
@class GamePlayer;
@class GameWeapon;
@class SneakyJoystickSkinnedBase;
@class SneakyJoystick;

@interface GameHudLayer : CCLayer <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>
{
    CCSprite *weaponSprite;
    CCSprite *healthSprite;
    CCSprite *fragSprite;
    CCSprite *pauseSprite;
    CCLabelBMFont *healthLabel;
    CCLabelBMFont *fragLabel;
    CCLabelBMFont *ammoLabel;
    CCLabelBMFont *ammoLabel2;
    CCLabelBMFont *timeLabel;
    CCLabelBMFont *playersLabel;
    NSArray *playersList;
    CGSize screenSize;

    CCSprite *gameOverSprite;
    CCSprite *adSprite;
    CCMenu *restartButtonMenu;
    CCMenu *tutorialButtonMenu;
    CCMenu *gcButtonMenu;
    BOOL adActive;
    BOOL restartOnContinue;
    
	SneakyJoystickSkinnedBase *leftJoy;
    SneakyJoystick *leftJoystick;
	SneakyJoystickSkinnedBase *rightJoy;
    SneakyJoystick *rightJoystick;
}

- (void)setWeapon:(GameWeapon *)aWeapon;
- (void)setHealth:(int)aHealth;
- (void)setFrags:(int)aFrags;
- (void)setTime:(int)aSeconds;
- (void)setPlayersList:(NSArray *)aList;
- (void)updatePlayersList;
- (void)showPause;
- (void)showGameOver;
- (void)saveScore;

@property (nonatomic, strong) GamePlayer *player;
@property (nonatomic, strong) WorldLayer *world;
@property (nonatomic, strong) CCLabelBMFont *instructionLabel;
@property (nonatomic, strong) CCLabelBMFont *instructionLabel2;
@property (nonatomic, strong) CCLabelBMFont *scoreLabel;

@property (nonatomic, readwrite, setter = setScore:) int score;

@end
