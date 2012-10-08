
#import "GameObject.h"

enum GameItemType {
    kItemWeaponMachinegun,
    kItemWeaponGrenade,
    kItemWeaponFlame,
    kItemWeaponRocket,
    kItemWeaponMine,
    kItemRepair,
    numItems
};
typedef enum GameItemType GameItemType;

static NSString *GameItemNames[] = {
    @"machine gun ammo",
    @"grenade launcher ammo",
    @"flame thrower ammo",
    @"rocket launcher ammo",
    @"mines ammo",
    @"health pack",
};

@interface GameItem : GameObject
{
    CGPoint originalPos;
    float respawnTime;
    BOOL fadingAway;
}

- (id)initWithPosition:(CGPoint)pos type:(GameItemType)aType layer:(WorldLayer *)aLayer;
- (void)tick: (ccTime) dt;
- (void)reset;

@property (readonly) GameItemType type;
@property (readonly) int collectCount;

@end
