
#import "GameArmory.h"

@implementation GameArmory
@synthesize selectedWeapon;

- (id)init
{
    self = [super init];
    if (!self) {
        return self;
    }
    
    weapons = [NSArray arrayWithObjects:
               [[GameWeapon alloc] initWithType:kWeaponMachinegun],
               [[GameWeapon alloc] initWithType:kWeaponGrenade],
               [[GameWeapon alloc] initWithType:kWeaponFlame],
               [[GameWeapon alloc] initWithType:kWeaponRocket],
               [[GameWeapon alloc] initWithType:kWeaponMine],
               nil];
    
    [self reset];

    return self;
}

- (void)reset
{
    for (GameWeapon *weapon in weapons) {
        [weapon reset];
    }
    
    selectedWeapon = [weapons objectAtIndex:0];
}

- (void)cheat
{
    for (GameWeapon *weapon in weapons) {
        [weapon cheat];
    }
}

- (GameWeapon *)getWeapon:(GameWeaponType)aType
{
    if (aType < 0 || aType >= numWeapons) {
        return nil;
    }
    
    return [weapons objectAtIndex:aType];
}

- (BOOL)selectWeapon:(GameWeapon *)aWeapon
{
    if (![aWeapon hasInfiniteAmmo] && !aWeapon.ammo) {
        return NO;
    }
    
    selectedWeapon = aWeapon;
    
    return YES;
}

- (BOOL)consumeItem:(GameItemType)aItemType
{
    GameWeapon *weapon = [self getWeapon:(GameWeaponType)aItemType];
    
    if (weapon == nil) {
        return NO;
    }
    
    return [weapon consumeItem];
}

- (BOOL)next
{
    int i = selectedWeapon.type;
    GameWeapon *w;
    
    do {
        i++;
        
        if (i > numWeapons) {
            i = 0;
        } else if (i < 0) {
            i = numWeapons;
        }
        
        w = [self getWeapon:(GameWeaponType)i];
    } while (![self selectWeapon:w]);
    
    return YES;
}

- (BOOL)prev
{
    int i = selectedWeapon.type;
    GameWeapon *w;
    
    do {
        i--;
        
        if (i > numWeapons) {
            i = 0;
        } else if (i < 0) {
            i = numWeapons;
        }
        
        w = [self getWeapon:(GameWeaponType)i];
    } while (![self selectWeapon:w]);
    
    return YES;
}

/* never choose mines, because they need extra intelligence */
- (GameWeapon *)getBestLoadedWeapon
{
    GameWeapon *w;
    
    w = [self getWeapon:kWeaponRocket];
    if (w.hasAmmo) {
        return w;
    }
    
    w = [self getWeapon:kWeaponFlame];
    if (w.hasAmmo) {
        return w;
    }
    
    w = [self getWeapon:kWeaponGrenade];
    if (w.hasAmmo) {
        return w;
    }
    
    w = [self getWeapon:kWeaponMachinegun];
    return w;
}

- (void)selectBestLoadedWeapon
{
    GameWeapon *w = [self getBestLoadedWeapon];
    [self selectWeapon:w];
}

@end
