
#import "GameMenuPage.h"

@class GameChallenge;

enum GamePlayTypeSelectMode {
    kSelectModeLevel,
    kSelectModeTank
};

@interface GameMenuPagePlay : GameMenuPage
{
    CCLabelBMFont *title;
    CCLabelBMFont *label;
    CCLabelBMFont *status;
    CCLabelBMFont *topLabel;
    GameChallenge *selectedChallenge;
    long tank;
    CCSprite *levelSprite;
    CCSprite *tankSprite;
    CCSprite *turretSprite;
    CCSprite *lockedSprite;
    CCMenu *menuPrev;
    CCMenu *menuNext;
    CCMenu *startMenu;
    CCMenu *backMenu;
    GameMenuItemImage *menuPrevItem;
    GameMenuItemImage *menuNextItem;
    GamePlayTypeSelectMode selectMode;
    CCMenu *selectLevelMenu;
    long lastVictoryCount;
}

- (void)onSceneEnter;

@end
