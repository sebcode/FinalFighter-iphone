
#import "GameWeapon.h"

static int GameWeaponIncrement[] = {
    0, // kWeaponMachinegun
    3, // kWeaponGrenade
    30, // kWeaponFlame
    4, // kWeaponRocket
    4 // kWeaponMine
};

@implementation GameWeapon

- (id)initWithType:(GameWeaponType)aType
{
    self = [super init];
    if (!self) {
        return self;
    }

    _type = aType;
    _hasInfiniteAmmo = _type == kWeaponMachinegun;
    _isRelentless = _type == kWeaponMachinegun || _type == kWeaponFlame;
    
    return self;
}

- (void)reset
{
    _ammo = 0;
}

- (void)cheat
{
    _ammo = 99;
}

- (NSString *)label
{
    return GameWeaponLabels[_type];
}

- (BOOL)hasAmmo
{
    return _hasInfiniteAmmo || _ammo > 0;
}

- (BOOL)consumeItem
{
    _ammo += GameWeaponIncrement[_type];
    
    if (_ammo >= 99) {
        _ammo = 99;
    }
    
    return YES;
}

- (BOOL)consumeBullet
{
    if ([self hasInfiniteAmmo]) {
        return YES;
    }
    
    if (_ammo <= 0) {
        return NO;
    }
    
    _ammo -= 1;
    
    return YES;
}

@end
