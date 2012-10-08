
#import "GameMenuItemLabel.h"
#import "GameSoundPlayer.h"

@implementation GameMenuItemLabel

- (void)selected
{
    if (isEnabled_) {
        self.color = ccc3(69.0f, 240.0f, 48.0f);
        [[GameSoundPlayer getInstance] play:GameSoundMenuHover];
    }
}

- (void)unselected
{
    if (isEnabled_) {
        self.color = ccc3(150.0f, 150.0f, 150.0f);
    }
}

- (void)activate
{
    if (isEnabled_ && block_) {
        [self unselected];
        [super activate];
    }
}

@end
