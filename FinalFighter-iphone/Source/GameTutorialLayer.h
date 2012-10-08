
#import "cocos2d.h"

@class WorldLayer;
@class GameItem;
@class GameEnemy;

@interface GameTutorialLayer : CCLayer
{
    WorldLayer *worldLayer;
    CCLabelBMFont *label;
    CCLabelBMFont *plabel;
    
    GameItem *healthPack1;
    GameItem *healthPack2;
    GameItem *weaponItem;
    GameEnemy *enemy;
    
    int step;
    BOOL waitForReturn;
    BOOL wellDone;
    NSString *otext;
    NSString *text;
}

- (void)next;
- (void)update;
- (void)playerReturn;
- (void)secondTick:(ccTime)dt;
- (void)checkObjectivesTick:(ccTime)dt;

@property (nonatomic, strong) WorldLayer *worldLayer;

@end
