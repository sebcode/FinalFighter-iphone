
#import "Box2D.h"
#import "GLES-Render.h"
#import "GameContactListener.h"
#import "GameHudLayer.h"
#import "GameConstants.h"

@class GameLevel;
@class GamePlayer;
@class GameTank;
@class GameObject;
@class GameTutorialLayer;
@class GameChallenge;

@interface WorldLayer : CCLayer
{
	GLESDebugDraw *m_debugDraw;
    GameContactListener *contactListener;
    
    BOOL fragLimitReached;
    
    CGPoint mouseLoc;
    NSMutableArray *players;
    
    CGPoint touchBeginPoint;
    
    NSMutableArray *items;
    CCSprite *tutSprite;
    int levelNum;
    int nextFragGoal;
    int fragTicker;
    
    BOOL isPaused;
    
    int roundCountdown;
}

- (id)initWithHUD:(GameHudLayer *)aHudLayer challenge:(GameChallenge *)aChallange tank:(int)aTankIndex;
- (void)incTotalFrags;
- (void)checkFragLimit:(GameTank *)aTank;
- (id)createUserDataWithObject:(GameObject *)aObject doTick:(BOOL)aDoTick;
- (id)createUserDataWithObject:(GameObject *)aObject;
- (void)pause;
- (void)unpause;

+ (CCScene *)scene;
+ (CCScene *)sceneWithChallenge:(GameChallenge *)aChallenge tank:(int)aTankIndex;

@property (readonly) NSMutableArray *destroyQueue;
@property (readonly) NSMutableArray *changeBodyStateQueue;
@property (readonly) NSMutableArray *userDataRetain;
@property (readonly) b2World *world;
@property (nonatomic, strong) GameLevel *level;
@property (readonly) GameHudLayer *hudLayer;
@property (nonatomic, strong) GameTutorialLayer *tutorialLayer;
@property (readonly) GamePlayer *player;
@property (readonly) int totalFrags;
@property (readonly) int secondCounter;
@property (nonatomic, strong) GameChallenge *challenge;

@end
