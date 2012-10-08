
#import <GameKit/GameKit.h>
#import <cocos2d.h>
#import "GameCenterManager.h"

@class GameCenterManager;
@class GameMenuPage;
@class GameMenuItemImage;

enum GameMenuTabItem {
    GameMenuTabItemGame,
    GameMenuTabItemAchievements,
    GameMenuTabItemSettings,
    GameMenuTabItemAbout
};

@interface MenuLayer : CCLayer <GameCenterManagerDelegate, GKAchievementViewControllerDelegate>
{
    GameCenterManager *gameCenterManager;
    CGPoint menuPagePosition;
    CCMenu *menu;
    GameMenuItemImage *selectedTabItem;    
    NSArray *menuTabPages;
    GameMenuPage *activePage;
}

+ (CCScene *)scene;

- (void)onSelectItem:(id)aSender;
- (void)onUnselectItem:(id)aSender;

- (void)showAchievements;

@end
