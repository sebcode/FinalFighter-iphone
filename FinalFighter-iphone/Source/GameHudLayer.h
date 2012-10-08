
#import "cocos2d.h"

@class GameArmory;
@class GamePlayer;
@class GameWeapon;
@class SneakyJoystickSkinnedBase;
@class SneakyJoystick;

@interface GameHudLayer : CCLayer
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

@property (nonatomic, strong) GamePlayer *player;

@end
