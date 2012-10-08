
#import "GameMusicPlayer.h"
#import "SimpleAudioEngine.h"
#import "GameConstants.h"
#import "CDAudioManager.h"

@implementation GameMusicPlayer
@synthesize isOn;
@synthesize volume;

NSString *GameMusicMenuSong = @"blade_of_fire";

static GameMusicPlayer *sharedMusicPlayer = nil;

+ (GameMusicPlayer *)getInstance
{
    if (!sharedMusicPlayer) {
        sharedMusicPlayer = [[GameMusicPlayer alloc] init];
    }
    
    return sharedMusicPlayer;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return self;
    }

    [CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio];
    tracks = [[NSMutableArray alloc] init];
    [self preload];
    
    [[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:self selector:@selector(backgroundMusicFinished)];
    
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:self.volume / 100.0f];

    return self;
}

- (void)preload
{
    [tracks removeAllObjects];
    
    NSString *resourcesPath = [[NSBundle mainBundle] resourcePath];
    
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcesPath error:nil]) {
        if (![file hasSuffix: @".mp3"]) {
            continue;
        }

        if ([file hasPrefix:@"test_"]) { // DEBUG
            continue;
        }
        
        NSString *name = [file stringByDeletingPathExtension];
        if ([name isEqualToString:GameMusicMenuSong]) {
            continue;
        }
        
        NSString *absFile = [resourcesPath stringByAppendingFormat:@"/%@", file];
        [tracks addObject:absFile];
    }
    
    [self shuffle];
}

- (void)shuffle
{
    NSUInteger count = [tracks count];
    if (!count) {
        return;
    }
    
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger nElements = count - i;
        NSUInteger n = (random() % nElements) + i;
        [tracks exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

- (void)stop
{
    CDAudioManager *am = [CDAudioManager sharedManager];
    
    if (!am.isBackgroundMusicPlaying) {
        return;
    }
    
    [am stopBackgroundMusic];
}

- (void)setVolume:(NSInteger)aVolume
{
    if (aVolume < 0) {
        aVolume = 0;
    } else if (aVolume > 100) {
        aVolume = 100;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:aVolume / 100.0f];
    [defaults setInteger:aVolume forKey:@"MusicVolume"];
}

- (NSInteger)volume
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"MusicVolume"];
}

- (void)setIsOn:(BOOL)on
{
    BOOL isNowOn = self.isOn;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:!on forKey:@"MusicOff"];
    
    if (isNowOn && self.isOn) {
        [self stop];
    }
}

- (BOOL)isOn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL off = [defaults boolForKey:@"MusicOff"];
    return off == NO;
}

- (void)playMenuMusic
{
    if (!self.isOn) {
        return;
    }

#ifdef NO_MUSIC
    return;
#endif

    if (isMenuMusicPlaying) {
        return;
    }
    
    isMenuMusicPlaying = YES;
    switchingTrack = YES;
    
    CDAudioManager *am = [CDAudioManager sharedManager];
    [am stopBackgroundMusic];
    [am rewindBackgroundMusic];
    [am playBackgroundMusic:[NSString stringWithFormat:@"%@.mp3", GameMusicMenuSong] loop:NO];
    
    switchingTrack = NO;
}

- (void)backgroundMusicFinished
{
    if (switchingTrack) {
        return;
    }

    if (isMenuMusicPlaying) {
        return;
    }
    
    [self playNext];
}

- (void)playNext
{
    if (!self.isOn) {
        return;
    }
    
#ifdef NO_MUSIC
    return;
#endif

    if (!tracks.count) {
        return;
    }

    NSString *absFile = [tracks objectAtIndex:nextIndex];

    switchingTrack = YES;
    
    CDAudioManager *am = [CDAudioManager sharedManager];
    [am stopBackgroundMusic];
    [am rewindBackgroundMusic];
    [am playBackgroundMusic:absFile loop:NO];
    //NSLog(@"%ld %@", nextIndex, absFile);
    
    if (++nextIndex >= [tracks count]) {
        nextIndex = 0;
    }
    
    isMenuMusicPlaying = NO;
    switchingTrack = NO;
}

@end
