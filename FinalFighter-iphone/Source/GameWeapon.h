
enum GameWeaponType {
    kWeaponMachinegun,
    kWeaponGrenade,
    kWeaponFlame,
    kWeaponRocket,
    kWeaponMine,
    numWeapons
};
typedef enum GameWeaponType GameWeaponType;

static NSString *GameWeaponLabels[] = {
    @"Machine gun",
    @"Grenades",
    @"Flame thrower",
    @"Rockets",
    @"Mines"
};

@interface GameWeapon : NSObject

- (id)initWithType:(GameWeaponType)aType;
- (BOOL)consumeItem;
- (BOOL)consumeBullet;
- (void)cheat;
- (void)reset;

@property (readonly) GameWeaponType type;
@property (readonly) int ammo;
@property (readonly) NSString *label;
@property (readonly) BOOL hasInfiniteAmmo;
@property (readonly) BOOL isRelentless;
@property (readonly) BOOL hasAmmo;

@end
