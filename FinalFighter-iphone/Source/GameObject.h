
#import <cocos2d.h>
#import <Box2D.h>

@class WorldLayer;

enum {
    catNone = 0,
    catWall = 1,
    catTank = 2,
    catAmmo = 4,
    catItem = 8,
    catTankSensor = 16,
    catAll = 0xffff
};

@interface GameObject : NSObject
{
    WorldLayer *_layer;
    b2Body *body;
    b2Fixture *fixture;
    CCSprite *_sprite;
    uint16 _category;
    
    BOOL destroying;
    
    GameObject *_ignoreCollisionWith;
    
    int changeBodyStateTo;
}

@property (nonatomic, strong) WorldLayer *layer;
@property (assign) b2World *world;
@property (readonly) uint16 category;
@property (readonly) CCSprite *sprite;
@property (readwrite) BOOL active;
@property (readonly) GameObject *ignoreCollisionWith;

- (id)initWithLayer:(WorldLayer *)aLayer;
- (void)destroy;
- (void)doDestroy;
- (void)doChangeBodyState;
- (void)activateBody;
- (void)deactivateBody;
- (void)tick:(ccTime)dt;
- (void)contact:(GameObject *)object;

@end
