
#import "GameTank.h"

@class GameHudLayer;

@class GameLevel;

@interface GamePlayer : GameTank
{
    CCSprite *pointerSprite;
    GameLevel *level;
    CGSize levelSize;
    GameHudLayer *hudLayer;
    NSUInteger fragsSinceDeath;
}

- (void)tick:(ccTime)dt;
- (BOOL)switchWeapon:(GameWeaponType)aWeaponType;
- (void)nextWeapon;
- (void)prevWeapon;
- (BOOL)doFire;
- (void)moveTurretAngle:(float)aAngle;
- (void)moveAngle:(float)aAngle;
- (void)resetStats;

@property (readwrite) BOOL collectStats;
@property (readwrite) BOOL canFire;
@property (readonly) float statMoveLeft;
@property (readonly) float statMoveRight;
@property (readonly) float statMoveUp;
@property (readonly) float statMoveDown;
@property (readonly) float statMoveTurret;
@property (readonly) float statFire;
@property (readonly) NSUInteger statCollectGrenade;
@property (readonly) NSUInteger statCollectFlame;
@property (readonly) NSUInteger statCollectRocket;
@property (readonly) NSUInteger statCollectMine;
@property (readonly) NSUInteger statCollectRepair;
@property (readonly) NSUInteger statKillWithRockets;
@property (readwrite) BOOL aiming;

@end
