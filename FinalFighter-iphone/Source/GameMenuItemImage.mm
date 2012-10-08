
#import "GameMenuItemImage.h"
#import "GameSoundPlayer.h"

@implementation GameMenuItemImage
@synthesize onSelectSelector;
@synthesize onUnselectSelector;
@synthesize selectorTarget;
@synthesize tooltip;

- (void)selected
{
	[super selected];

    if (onSelectSelector && selectorTarget) {
        [[GameSoundPlayer getInstance] play:@"menu_hover"];
        
        if (!self.noAnimateOnTouch) {
            [self runAction:[CCSequence actions:
                             [CCScaleTo actionWithDuration:0.05 scale:1.2f],
                             [CCScaleTo actionWithDuration:0.05 scale:1.0f],
                             [CCScaleTo actionWithDuration:0.05 scale:1.2f],
                             [CCScaleTo actionWithDuration:0.05 scale:1.0f],
                             nil]];
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [selectorTarget performSelector:onSelectSelector withObject:self];
#pragma clang diagnostic pop
    }
}

- (void)unselected
{
	[super unselected];
    
    if (onUnselectSelector && selectorTarget) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [selectorTarget performSelector:onUnselectSelector withObject:self];
#pragma clang diagnostic pop
    }
}

@end
