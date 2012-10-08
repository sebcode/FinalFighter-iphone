
static NSString *GameSoundTutorialNext = @"bling";
static NSString *GameSoundItem = @"item";
static NSString *GameSoundExplosion = @"explosion";
static NSString *GameSoundWeaponChangeEmpty = @"weapon_change_empty";
static NSString *GameSoundWeaponChange = @"weapon_change";
static NSString *GameSoundWeaponFlame = @"weapon_flame";
static NSString *GameSoundWeaponGrenade = @"weapon_grenade";
static NSString *GameSoundWeaponMinigun = @"weapon_m";
static NSString *GameSoundWeaponMinigun1 = @"weapon_m1";
static NSString *GameSoundWeaponMinigun2 = @"weapon_m2";
static NSString *GameSoundWeaponMinigun3 = @"weapon_m3";
static NSString *GameSoundWeaponRocket = @"weapon_rocket";
static NSString *GameSoundMenuHover = @"menu_hover";
static NSString *GameSoundFrag = @"frag_sound";
static NSString *GameSoundLocked = @"weapon_change_empty";

@interface GameSoundPlayer : NSObject
{
    NSMutableDictionary *sounds;
}

- (void)preload;
- (BOOL)play:(NSString *)name;
+ (GameSoundPlayer *)getInstance;

@property (getter = isOn, setter = setIsOn:) BOOL isOn;
@property (getter = volume, setter = setVolume:) NSInteger volume;

@end
