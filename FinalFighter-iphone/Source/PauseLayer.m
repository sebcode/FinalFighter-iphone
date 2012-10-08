
#import "PauseLayer.h"
#import "MenuLayer.h"
#import "GameMenuItemLabel.h"
#import "GameFont.h"
#import "GameStats.h"

@implementation PauseLayer

+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];
    
    PauseLayer *layer = [PauseLayer node];
    [scene addChild:layer];
    
	return scene;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return self;
    }
    
    self.isTouchEnabled = YES;
    
    CCLabelBMFont *label;
    
    label = [CCLabelBMFont labelWithString:@"GAME PAUSED\n" fntFile:GameFontDefault];
    label.opacity = 100.0f;
    [self addChild:label];
    label1 = label;

    label = [CCLabelBMFont labelWithString:@"CONTINUE" fntFile:GameFontDefault];
    label.color = ccc3(150.0f, 150.0f, 150.0f);
    GameMenuItemLabel *item1 = [GameMenuItemLabel itemWithLabel:label block:^(id sender) {
        [[CCDirector sharedDirector] popScene];
    }];
//    label = [CCLabelBMFont labelWithString:@"SETTINGS" fntFile:GameFontDefault];
//    label.color = ccc3(150.0f, 150.0f, 150.0f);
//    GameMenuItemLabel *item2 = [GameMenuItemLabel itemWithLabel:label block:^(id sender) {
//        [[CCDirector sharedDirector] pushScene:[MenuLayer scene:YES]];
//    }];
    label = [CCLabelBMFont labelWithString:@"QUIT TO MENU" fntFile:GameFontDefault];
    label.color = ccc3(150.0f, 150.0f, 150.0f);
    GameMenuItemLabel *item3 = [GameMenuItemLabel itemWithLabel:label block:^(id sender) {
        [[CCDirector sharedDirector] popScene];
        [[CCDirector sharedDirector] popScene];
    }];
    
    menu = [CCMenu menuWithItems: item1, item3, nil];
    [self addChild:menu];
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [[GameStats getInstance] synchronize];

    CGSize screenSize = [CCDirector sharedDirector].winSize;

    label1.position = ccp(screenSize.width / 2.0f, screenSize.height - 80.0f);
    
    menu.position = ccp(screenSize.width / 2.0f, screenSize.height / 2.0f);
    [menu alignItemsVerticallyWithPadding:10.0f];
}

@end
