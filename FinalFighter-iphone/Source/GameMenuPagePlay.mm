
#import "GameMenuPagePlay.h"
#import "GameMenuItemImage.h"
#import "GamePlayer.h"
#import "GameFont.h"
#import "GameMenuItemLabel.h"
#import "GameTank.h"
#import "GameLevelTutorial.h"
#import "GameLevelFragtemple.h"
#import "GameLevelYerLethalMetal.h"
#import "GameLevelOverkillz.h"
#import "GameLevelHauntedHalls.h"
#import "GameStats.h"
#import "GameChallenge.h"
#import "GameChallengeManager.h"
#import "GameSoundPlayer.h"

static int GameTankTypeOrder[] = {
    GameTankTypeEnforcerBlue,
    GameTankTypeEnforcerRed,
    GameTankTypeEnforcerGreen,
    GameTankTypeEnforcerGrey,
    GameTankTypeEnforcerYellow,
    GameTankTypeEnforcerBlack,
    GameTankTypePirateBlue,
    GameTankTypePirateGreen1,
    GameTankTypePirateGreen2,
    GameTankTypePirateGrey,
    GameTankTypePirateRed,
    GameTankTypeEnforcerPunisher,
    GameTankTypePirateBlack,
    GameTankTypeBurning,
    GameTankTypeChromicBlue,
    GameTankTypeChromicRed,
    GameTankTypeDragster,
    GameTankTypeRush,
    GameTankTypeCapcom
};

@implementation GameMenuPagePlay

- (id)init
{
    self = [super init];
    if (!self) {
        return self;
    }

    /* menu background image */
    
    CCSprite *sprite;
    sprite = [CCSprite spriteWithSpriteFrameName:@"menu_layer_play.png"];
    sprite.anchorPoint = ccp(0, 0);
    [self addChild:sprite];

    /* level preview image */

    sprite = [CCSprite spriteWithSpriteFrameName:@"menu_level_0.png"];
    sprite.position = ccp(78.0f, 88.0f);
    sprite.anchorPoint = ccp(0, 0);
    sprite.visible = NO;
    [self addChild:sprite z:10];
    levelSprite = sprite;

    sprite = [CCSprite spriteWithSpriteFrameName:@"menu_level_locked.png"];
    sprite.position = ccp(78.0f, 88.0f);
    sprite.anchorPoint = ccp(0, 0);
    sprite.visible = NO;
    [self addChild:sprite z:20];
    lockedSprite = sprite;

    /* menu item: select level */

    CCMenu *menu;
    GameMenuItemImage *i;

    i = [self createItemWithImage:@"menu_level_selected_none.png"
                         selected:@"menu_level_selected.png"
                         selector:@selector(onClickLevel:)];
    i.tooltip = @"Select Challenge";
    i.noAnimateOnTouch = YES;
    
    menu = [CCMenu menuWithItems: i, nil];
    menu.anchorPoint = ccp(0, 0);
    [self addChild:menu z:20];
    selectLevelMenu = menu;

    /* menu item: go left */

    i = [self createItemWithImage:@"menu_arrow_left_inactive.png"
                         selected:@"menu_arrow_left.png"
                         selector:@selector(onClickPrev:)];
    i.tooltip = @"Previous";
    menuNextItem = i;

    menu = [CCMenu menuWithItems: i, nil];
    menu.position = ccp(18.0f, 109.0f);
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
    menu.position = ccp(258.0f, 109.0f);
    menu.anchorPoint = ccp(0, 0);
    [self addChild:menu];
    menuNext = menu;

    /* labels */

    title = [CCLabelBMFont labelWithString:@"" fntFile:GameFontMenuDefault];
    [self addChild:title z:100];
    title.position = ccp(155.0f, 250.0f);
    title.alignment = kCCTextAlignmentCenter;

    topLabel = [CCLabelBMFont labelWithString:@"" fntFile:GameFontMenuSmall];
    [self addChild:topLabel];
    topLabel.position = ccp(150.0f, 217.0f);
    topLabel.alignment = kCCTextAlignmentCenter;

    label = [CCLabelBMFont labelWithString:@"" fntFile:GameFontMenuSmall];
    [self addChild:label];
    label.position = ccp(150.0f, 57.0f);
    label.alignment = kCCTextAlignmentCenter;

    status = [CCLabelBMFont labelWithString:@"" fntFile:GameFontMenuDefault];
    status.alignment = kCCTextAlignmentCenter;
    status.position = ccp(155.0f, 110.0f);
    status.visible = NO;
    [self addChild:status z:100];

    /* GO-button */

    CCLabelBMFont *start;
    start = [CCLabelBMFont labelWithString:@"[GO]" fntFile:GameFontBig];
    start.alignment = kCCTextAlignmentCenter;
    start.color = ccc3(150.0f, 150.0f, 150.0f);
    start.scale = 0.8f;
    
    GameMenuItemLabel *startItem = [GameMenuItemLabel itemWithLabel:start block:^(id sender) {
        [self start];
    }];
    
    menu = [CCMenu menuWithItems:startItem, nil];
    menu.visible = NO;
    [self addChild:menu];
    startMenu = menu;

    /* BACK-button */

    CCLabelBMFont *back;
    back = [CCLabelBMFont labelWithString:@"[ BACK ]" fntFile:GameFontSmall];
    back.alignment = kCCTextAlignmentCenter;
    back.color = ccc3(150.0f, 150.0f, 150.0f);

    GameMenuItemLabel *backItem = [GameMenuItemLabel itemWithLabel:back block:^(id sender) {
        selectMode = kSelectModeLevel;
        [self updatePreview];
    }];

    menu = [CCMenu menuWithItems:backItem, nil];
    menu.position = ccp(150.0f, 5.0f);
    menu.visible = NO;
    [self addChild:menu];
    backMenu = menu;

    /* Tank selector */
    
    sprite = [CCSprite spriteWithSpriteFrameName:@"tanks_0.png"];
    sprite.visible = NO;
    sprite.position = ccp(155.0f, 150.0f);
    sprite.rotation = 45.0f;
    [self addChild:sprite z:20];
    tankSprite = sprite;

    sprite = [CCSprite spriteWithSpriteFrameName:@"turrets_0.png"];
    sprite.visible = NO;
    sprite.position = ccp(155.0f, 150.0f);
    [self addChild:sprite z:20];
    turretSprite = sprite;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    GameChallengeManager *cm = [GameChallengeManager getInstance];
    if (cm.allDone) {
        NSString *lastSelectedChallengeID = [defaults valueForKey:@"selectedChallengeID"];
        selectedChallenge = [cm getById:lastSelectedChallengeID];
    } else {
        selectedChallenge = cm.bestChallenge;
    }
    
    lastVictoryCount = [[GameStats getInstance] getInt:@"victoryCount"];
    
    long lastTank = [defaults integerForKey:@"selectedTank"];
    if (lastTank <= numTanks) {
        tank = lastTank;
    }
    
    [self updatePreview];

    return self;
}

- (void)start
{
    if (selectMode == kSelectModeLevel) {
        [self onClickLevel:nil];
        return;
    }

    if ([self checkLocked]) {
        return;
    }
        
    selectMode = kSelectModeLevel;
    [self updatePreview];

    int tankIndex = GameTankTypeOrder[tank];
    CCScene *scene = [WorldLayer sceneWithChallenge:selectedChallenge tank:tankIndex];
    [[CCDirector sharedDirector] runWithScene:scene];
}

- (void)onClickLevel:(id)aSender
{
    if ([self checkLocked]) {
        return;
    }
    
    selectMode = kSelectModeTank;

    [self updatePreview];
}

- (BOOL)checkLocked
{
    if ([[GameChallengeManager getInstance] isLocked:selectedChallenge]) {
        [[GameSoundPlayer getInstance] play:GameSoundLocked];
        return YES;
    }
    
    return NO;
}

- (void)onClickNext:(id)aSender
{
    if (selectMode == kSelectModeTank) {
        if (tank == numTanks - 1) {
            return;
        }
        
        tank++;
    } else {
        GameChallengeManager *challenges = [GameChallengeManager getInstance];
        
        if (selectedChallenge.index >= [challenges count]) {
            return;
        }
        
        selectedChallenge = [challenges getByIndex:selectedChallenge.index + 1];
    }
    
    [self updatePreview];
}

- (void)onClickPrev:(id)aSender
{
    if (selectMode == kSelectModeTank) {
        if (tank == 0) {
            return;
        }
        
        tank--;    
    } else {
        GameChallengeManager *challenges = [GameChallengeManager getInstance];
        
        if (selectedChallenge.index <= 0) {
            return;
        }
        
        selectedChallenge = [challenges getByIndex:selectedChallenge.index - 1];
    }
    
    [self updatePreview];
}

- (void)updatePreview
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (selectMode == kSelectModeTank) {
        int tankIndex = GameTankTypeOrder[tank];
        NSString *tankName = GameTankLabels[tankIndex];
        label.string = [NSString stringWithFormat:@"%li/%i\n%@", tank + 1, numTanks, tankName];
        
        [tankSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"tanks_%d.png", tankIndex]]];
        [turretSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"turrets_%d.png", tankIndex]]];
        
        tankSprite.visible = YES;
        turretSprite.visible = YES;
        levelSprite.visible = NO;
        lockedSprite.visible = NO;
        topLabel.visible = NO;
        status.visible = NO;
        
        menuPrev.visible = tank > 0;
        if (!menuPrev.visible) {
            [menuNextItem unselected];
        }
        
        menuNext.visible = tank < numTanks - 1;
        if (!menuNext.visible) {
            [menuPrevItem unselected];
        }

        selectLevelMenu.visible = YES;
        selectLevelMenu.position = ccp(-1000.0f, -1000.0f);
        
        title.string = @"SELECT TANK";
        backMenu.visible = YES;
        startMenu.visible = YES;
        
        [defaults setInteger:tank forKey:@"selectedTank"];

        return;
    }

    topLabel.string = [NSString stringWithFormat:@"Challenge %ld/%ld", (unsigned long)selectedChallenge.index + 1, (unsigned long)[[GameChallengeManager getInstance] count]];
    topLabel.visible = YES;
    topLabel.scale = 0.6f;
    
    label.string = [NSString stringWithFormat:@"%@", selectedChallenge.menuLabel];
    tankSprite.visible = NO;
    turretSprite.visible = NO;

    [levelSprite runAction:[CCSequence actions:
                            [CCFadeOut actionWithDuration:0.1f],
                            [CCCallBlock actionWithBlock:^{
                                [levelSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"menu_level_%d.png", selectedChallenge.menuImageIndex]]];
                                levelSprite.visible = YES;
                            }],
                            [CCFadeIn actionWithDuration:0.1f],
                            nil]];

    if ([[GameChallengeManager getInstance] isLocked:selectedChallenge]) {
        status.visible = NO;
        lockedSprite.visible = YES;
    } else if (selectedChallenge.isDone) {
        status.string = selectedChallenge.doneMessage;
        status.visible = YES;
        status.color = ccc3(255, 255, 255);
        lockedSprite.visible = NO;
    } else {
        status.string = @"";
        status.visible = NO;
        lockedSprite.visible = NO;
    }

    menuPrev.visible = selectedChallenge.index > 0;
    if (!menuPrev.visible) {
        [menuNextItem unselected];
    }
    
    menuNext.visible = selectedChallenge.index < [[GameChallengeManager getInstance] count] - 1;
    if (!menuNext.visible) {
        [menuPrevItem unselected];
    }

    selectLevelMenu.visible = YES;
    selectLevelMenu.position = ccp(78.0f, 88.0f);
    
    title.string = @"SELECT CHALLENGE";
    backMenu.visible = NO;
    startMenu.visible = NO;
    
    [defaults setValue:selectedChallenge.id forKey:@"selectedChallengeID"];
}

- (void)onSceneEnter
{
    long vc = [[GameStats getInstance] getInt:@"victoryCount"];

    if (vc != lastVictoryCount) {
        selectedChallenge = [GameChallengeManager getInstance].bestChallenge;
        [self updatePreview];
        lastVictoryCount = [[GameStats getInstance] getInt:@"victoryCount"];
    }
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if (screenSize.width >= 568.0f) {
        startMenu.position = ccp(344.0f, 15.0f);
    } else {
        startMenu.position = ccp(300.0f, 15.0f);
    }
}

@end
