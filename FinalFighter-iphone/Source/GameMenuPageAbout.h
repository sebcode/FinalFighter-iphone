
#import "GameMenuPage.h"

@interface GameMenuPageAbout : GameMenuPage
{
    CCLabelBMFont *title;
    CCLabelBMFont *label;
    CCMenu *menuPrev;
    CCMenu *menuNext;
    GameMenuItemImage *menuPrevItem;
    GameMenuItemImage *menuNextItem;
    NSUInteger page;
}

@end
