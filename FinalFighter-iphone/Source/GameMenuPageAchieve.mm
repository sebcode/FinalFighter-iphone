
#import "GameMenuPageAchieve.h"
#import "GameMenuItemImage.h"
#import "GameFont.h"
#import "GameAchievement.h"
#import "GameAchievements.h"
#import "GameMenuItemLabel.h"
#import <UIKit/UIGeometry.h>
#import "MenuLayer.h"

@implementation GameMenuPageAchieve

- (id)init
{
    self = [super init];
    if (!self) {
        return self;
    }

    CCLabelBMFont *label;

    label = [CCLabelBMFont labelWithString:@"OPEN GAME CENTER\nACHIEVEMENTS" fntFile:GameFontDefault];
    label.color = ccc3(150.0f, 150.0f, 150.0f);
    GameMenuItemLabel *item1 = [GameMenuItemLabel itemWithLabel:label block:^(id sender) {
        [self.delegate showAchievements];
    }];
    label1 = label;
    
    menu = [CCMenu menuWithItems: item1, nil];
    [self addChild:menu];

    return self;
}

- (void)update
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;

    label1.position = ccp(0, 0);
    label1.alignment = kCCTextAlignmentCenter;
    if (screenSize.width >= 568.0f) {
        menu.position = ccp((screenSize.width / 2.0) - 130.0f, (screenSize.height / 2.0));
    } else {
        menu.position = ccp((screenSize.width / 2.0) - 90.0f, (screenSize.height / 2.0));
    }
}

@end
