
#import "MenuLayer.h"
#import "WorldLayer.h"
#import "GameMenuItemImage.h"
#import "GameMenuPagePlay.h"
#import "GameMenuPageAchieve.h"
#import "GameMenuPageSettings.h"
#import "GameMenuPageAbout.h"
#import "GameFont.h"
#import "GameMusicPlayer.h"
#import "GameStats.h"
#import "GameCenterManager.h"
#import "AppDelegate.h"
#import "LandscapeNavigationController.h"

@implementation MenuLayer

+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];
    scene.anchorPoint = ccp(0, 0);
    
	MenuLayer *layer = [[MenuLayer alloc] init];
	[scene addChild: layer];
    
	return scene;
}

- (void)onEnter
{
    [super onEnter];
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    [[GameStats getInstance] synchronize];
    
    [[GameMusicPlayer getInstance] playMenuMusic];
    
    if (menuTabPages.count) {
        GameMenuPagePlay *p = [menuTabPages objectAtIndex:0];
        [p onSceneEnter];
    }
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;

    if (screenSize.width >= 568.0f) {
        menuPagePosition = ccp(174.0f, 25.0f);
    } else {
        menuPagePosition = ccp(130.0f, 25.0f);
    }
    
    activePage.position = menuPagePosition;
    
	if (GameCenterManager.isGameCenterAvailable && !gameCenterManager) {
		gameCenterManager = [GameCenterManager sharedInstance];
		[gameCenterManager authenticateLocalUser];
	}
    
    menu.position = ccp(-70, 128.0f);
    [menu runAction:[CCMoveTo actionWithDuration:0.5f position:ccp(25, 128)]];
}

- (id)init
{
	self = [super init];
    if (!self) {
        return self;
    }

    self.isTouchEnabled = YES;

    CCSprite *normalSprite;
    CCSprite *selSprite;

    /* vier menu icons */
    
    normalSprite = [CCSprite spriteWithSpriteFrameName:@"menu_icon_0.png"];
    selSprite = [CCSprite spriteWithSpriteFrameName:@"menu_icon_0.png"];
    GameMenuItemImage *i1 = [self createItemWithSprite:normalSprite selected:selSprite selector:@selector(onClickTabItem:)];
    i1.tag = GameMenuTabItemGame;
    [self onClickTabItem:i1];

    normalSprite = [CCSprite spriteWithSpriteFrameName:@"menu_icon_1.png"];
    selSprite = [CCSprite spriteWithSpriteFrameName:@"menu_icon_1.png"];
    GameMenuItemImage *i2 = [self createItemWithSprite:normalSprite selected:selSprite selector:@selector(onClickTabItem:)];
    i2.tag = GameMenuTabItemAchievements;

    normalSprite = [CCSprite spriteWithSpriteFrameName:@"menu_icon_2.png"];
    selSprite = [CCSprite spriteWithSpriteFrameName:@"menu_icon_2.png"];
    GameMenuItemImage *i3 = [self createItemWithSprite:normalSprite selected:selSprite selector:@selector(onClickTabItem:)];
    i3.tag = GameMenuTabItemSettings;

    normalSprite = [CCSprite spriteWithSpriteFrameName:@"menu_icon_3.png"];
    selSprite = [CCSprite spriteWithSpriteFrameName:@"menu_icon_3.png"];
    GameMenuItemImage *i4 = [self createItemWithSprite:normalSprite selected:selSprite selector:@selector(onClickTabItem:)];
    i4.tag = GameMenuTabItemAbout;

    menu = [CCMenu menuWithItems: i1, i2, i3, i4, nil];
    menu.anchorPoint = ccp(0, 0);
    menu.position = ccp(25.0, 128.0f);
    [self addChild:menu];
    [menu alignItemsVerticallyWithPadding:10.0f];
    
    menuTabPages = [NSArray arrayWithObjects:
                     [GameMenuPagePlay node],
                     [GameMenuPageAchieve node],
                     [GameMenuPageSettings node],
                     [GameMenuPageAbout node],
                     nil];
    [self onClickTabItem:i1];
    
    GameMenuPage *page;
    for (page in menuTabPages) {
        page.visible = NO;
        page.position = ccp(-1000.0f, -1000.0f);
        page.delegate = self;
        [self addChild:page];
    }

    page = [menuTabPages objectAtIndex:0];
    page.anchorPoint = ccp(0, 0);
    page.visible = YES;
    activePage = page;

    return self;
}

- (GameMenuItemImage *)createItemWithImage:(NSString *)aImage selected:(NSString *)aImageSelected selector:(SEL)aSelector
{
    GameMenuItemImage *i;
    i = [GameMenuItemImage itemWithNormalImage:aImage selectedImage:aImageSelected target:self selector:aSelector];
    i.anchorPoint = ccp(0, 0);
    i.position = ccp(0, 0);
    i.onSelectSelector = @selector(onSelectItem:);
    i.onUnselectSelector = @selector(onUnselectItem:);
    i.selectorTarget = self;
    i.opacity = 150.0f;
    
    return i;    
}

- (GameMenuItemImage *)createItemWithImage:(NSString *)aImage selector:(SEL)aSelector
{
    return [self createItemWithImage:aImage selected:aImage selector:aSelector];
}

- (GameMenuItemImage *)createItemWithSprite:(CCSprite *)aSprite selected:(CCSprite *)aSpriteSelected selector:(SEL)aSelector
{
    GameMenuItemImage *i;
    i = [GameMenuItemImage itemWithNormalSprite:aSprite selectedSprite:aSpriteSelected target:self selector:aSelector];
    i.anchorPoint = ccp(0, 0);
    i.position = ccp(0, 0);
    i.onSelectSelector = @selector(onSelectItem:);
    i.onUnselectSelector = @selector(onUnselectItem:);
    i.selectorTarget = self;
    i.opacity = 150.0f;
    
    return i;
}

- (void)onClickTabItem:(id)aSender
{
    GameMenuItemImage *item = (GameMenuItemImage *)aSender;

    if (selectedTabItem == item) {
        return;
    }
    
    selectedTabItem.color = ccc3(255, 255, 255);
    selectedTabItem.opacity = 150.0f;
    
    item.color = ccc3(69, 240, 48);
    item.opacity = 255.0f;
    selectedTabItem = item;

    GameMenuPage *page;

    for (page in menuTabPages) {
        page.delegate = self;
        page.visible = NO;
        page.position = menuPagePosition;
        page.position = ccp(-1000, -1000);
    }
    
    page = [menuTabPages objectAtIndex:item.tag];
    page.visible = YES;
    page.position = menuPagePosition;
    
    if (activePage) {
        [activePage hide];
    }
    
    activePage = page;
    
    [page update];
}

- (void)onSelectItem:(id)aSender
{
    GameMenuItemImage *item = (GameMenuItemImage *)aSender;
    item.opacity = 255.0f;
}

- (void)onUnselectItem:(id)aSender
{
    GameMenuItemImage *item = (GameMenuItemImage *)aSender;

    if (selectedTabItem != aSender) {
        item.opacity = 150.0f;
    }
}

- (void)onClickStart
{
    if (selectedTabItem.tag != GameMenuTabItemGame) {
        id i = [menu getChildByTag:GameMenuTabItemGame];
        [self onClickTabItem:i];
        return;
    }

    GameMenuPage *page = [menuTabPages objectAtIndex:selectedTabItem.tag];
    [page start];
}

#pragma mark - GameCenter

- (void)showAchievements
{
    AppController *appController = (AppController *)([UIApplication sharedApplication].delegate);
    
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
	if (achievements != NULL) {
		achievements.achievementDelegate = self;
		[appController.navController presentModalViewController:achievements animated:YES];
	}
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;
{
    AppController *appController = (AppController *)([UIApplication sharedApplication].delegate);
	[appController.navController dismissModalViewControllerAnimated:YES];
}

@end
