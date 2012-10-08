
#import "GameMenuPage.h"

@class GameMusicPlayer;
@class GameSoundPlayer;

@interface GameMenuPageSettings : GameMenuPage
{
    GameMusicPlayer *musicPlayer;
    GameSoundPlayer *soundPlayer;
    
    UISlider *soundVolSlider;
    UISlider *musicVolSlider;
}

@end
