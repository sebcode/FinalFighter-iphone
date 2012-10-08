
@interface GameMusicPlayer : NSObject
{
    NSMutableArray *tracks;
    NSUInteger nextIndex;
    BOOL switchingTrack;
}

+ (GameMusicPlayer *)getInstance;
- (void)playNext;

@property (getter = isOn, setter = setIsOn:) BOOL isOn;
@property (getter = volume, setter = setVolume:) NSInteger volume;

@end
