
#import "GameMenuPageAbout.h"
#import "GameFont.h"
#import "GameMenuItemImage.h"

@implementation GameMenuPageAbout

- (id)init
{
    self = [super init];
    if (!self) {
        return self;
    }
    
    /* menu item: go left */
    
    CCMenu *menu;
    GameMenuItemImage *i;
    
    i = [self createItemWithImage:@"menu_arrow_left_inactive.png"
                         selected:@"menu_arrow_left.png"
                         selector:@selector(onClickPrev:)];
    i.tooltip = @"Previous";
    menuNextItem = i;
    
    menu = [CCMenu menuWithItems: i, nil];
    menu.position = ccp(18.0f, 220.0f);
    menu.anchorPoint = ccp(0, 0);
    [self addChild:menu];
    menuPrev = menu;
    
    /* menu item: go right */
    
    i = [self createItemWithImage:@"menu_arrow_left_inactive.png"
                         selected:@"menu_arrow_left.png"
                         selector:@selector(onClickNext:)];
    i.anchorPoint = ccp(0.5f, 0.5f);
    i.position = ccp(16.0f, 21.0f);
    i.rotation = 180.0f;
    i.tooltip = @"Next";
    menuPrevItem = i;
    
    menu = [CCMenu menuWithItems: i, nil];
    menu.position = ccp(258.0f, 220.0f);
    menu.anchorPoint = ccp(0, 0);
    [self addChild:menu];
    menuNext = menu;
    
    /* title */
    
    title = [CCLabelBMFont labelWithString:@"" fntFile:GameFontMenuDefault];
    title.position = ccp(155.0f, 240.0f);
    title.alignment = kCCTextAlignmentCenter;
    [self addChild:title z:100];

    /* text */
    
    label = [CCLabelBMFont labelWithString:@"" fntFile:GameFontMini];
    label.anchorPoint = ccp(0.5f, 1.0f);
    label.position = ccp(155.0f, 210.0f);
    label.alignment = kCCTextAlignmentCenter;
    label.opacity = 200.0f;
    [self addChild:label];
    
    [self update];

    return self;
}

- (void)onClickNext:(id)aSender
{
    page++;
    
    [self update];
}

- (void)onClickPrev:(id)aSender
{
    page--;
    
    [self update];
}

- (void)update
{
    menuPrev.visible = page > 0;
    if (!menuPrev.visible) {
        [menuNextItem unselected];
    }
    
    menuNext.visible = page < 1;
    if (!menuNext.visible) {
        [menuPrevItem unselected];
    }

    if (page == 0) {
        [self updatePage0];
    } else if (page == 1) {
        [self updatePage1];
    }
}

- (void)updatePage1
{
    title.string = @"CONTACT";
    label.string = @"\
If you have any questions, ideas or suggestions, \n \
please do not hesitate to contact us! \n \
\n \
E-mail: game@finalfighter.de\n \
";
}

- (void)updatePage0
{
    title.string = @"CREDITS";
    label.string = @" \
Copyright (c)2001-2012 Sebastian Volland \n \
www.finalfighter.de\n \
\n \
Programming by Sebastian Volland\n \
Graphics by Matthias Nagler\n \
\n \
In-game music by Pip Malt (pipmalt.bandcamp.com)\n \
Menu music by Zilly Mike \n \
\n \
3rd party libs and resources: \n \
cocos2d (c)2011 - Zynga Inc. and contributors \n \
raphaeljs (c)2008 Dmitry Baranovskiy \n \
";
}

@end
