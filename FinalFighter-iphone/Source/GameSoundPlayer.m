
#import "GameConstants.h"
#import "GameSoundPlayer.h"
#import "SimpleAudioEngine.h"

@implementation GameSoundPlayer
@synthesize isOn;
@synthesize volume;

static GameSoundPlayer *sharedGameSoundPlayer = nil;

+ (GameSoundPlayer *)getInstance
{
    if (!sharedGameSoundPlayer) {
        sharedGameSoundPlayer = [[GameSoundPlayer alloc] init];
    }
    
    return sharedGameSoundPlayer;
}

- (id)init
{
    self = [super init];
    if (self) {
        sounds = [[NSMutableDictionary alloc] init];
        [self preload];
        
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:self.volume / 100.0f];
    }
    
    return self;
}

- (void)preload
{
    [sounds removeAllObjects];
    
    NSString *resourcesPath = [[NSBundle mainBundle] resourcePath];
    
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcesPath error:nil]) {
        if (![file hasSuffix:@".caf"]) {
            continue;
        }

        NSString *absFile = [resourcesPath stringByAppendingFormat:@"/%@", file];
        NSString *name = [file stringByDeletingPathExtension];
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:absFile];
        [sounds setObject:absFile forKey:name];
    }
}

- (BOOL)play:(NSString *)name
{
#ifdef NO_SOUNDS
    return NO;
#endif

    NSString *absFile = [sounds valueForKey:name];

    if (!absFile) {
        NSLog(@"SoundEngine: Sound not found: %@ (%@)", name, absFile);
        return false;
    }

    [[SimpleAudioEngine sharedEngine] playEffect:absFile];

    return YES;
}

- (void)setVolume:(NSInteger)aVolume
{
    if (aVolume < 0) {
        aVolume = 0;
    } else if (aVolume > 100) {
        aVolume = 100;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:aVolume / 100.0f];
    [defaults setInteger:aVolume forKey:@"SoundVolume"];
}

- (NSInteger)volume
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"SoundVolume"];
}

- (void)setIsOn:(BOOL)on
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:!on forKey:@"SoundOff"];
}

- (BOOL)isOn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL off = [defaults boolForKey:@"SoundOff"];
    return off == NO;
}

@end
