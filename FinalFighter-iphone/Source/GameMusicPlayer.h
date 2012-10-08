
@interface GameMusicPlayer : NSObject
{
    NSMutableArray *tracks;
    NSUInteger nextIndex;
    BOOL isMenuMusicPlaying;
    BOOL switchingTrack;
}

+ (GameMusicPlayer *)getInstance;
- (void)playNext;
- (void)playMenuMusic;

@property (getter = isOn, setter = setIsOn:) BOOL isOn;
@property (getter = volume, setter = setVolume:) NSInteger volume;

@end
