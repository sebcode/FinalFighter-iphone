
#import "WorldLayer.h"
#import "GameLevel.h"
#import "GameItem.h"
#import "GameDecoration.h"
#import "GameConstants.h"
#import "GameUserData.h"
#import "GameStartCoordsManager.h"
#import "GameStartCoords.h"

@implementation GameLevel

- (id)initWithLayer:(WorldLayer *)aLayer
{
	self = [super initWithLayer:aLayer];
    if (!self) {
        return self;
    }
    
    _category = catWall;
    
    NSString *filename = [self getFilename];
    
    _startCoordsManager = [[GameStartCoordsManager alloc] init];
    
    decorations = [NSMutableArray arrayWithCapacity:10];
    items = [NSMutableArray arrayWithCapacity:50];

    _sprite = [CCSprite spriteWithFile:filename];
    _sprite.anchorPoint = ccp(0, 0);
    _sprite.position = ccp(0, 0);
    _sprite.scale = [self getScale];
    [_layer addChild:_sprite];

#ifdef WIREFRAME
    sprite.visible = NO;
#endif
    
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0);
    groundBodyDef.userData = (__bridge void *)[self.layer createUserDataWithObject:self];
    
    b2Body* groundBody = self.world->CreateBody(&groundBodyDef);
    b2EdgeShape groundBox;
    
    CGSize contentSize = [self getSize];
    
    // bottom
    groundBox.Set(b2Vec2(0, 0), b2Vec2(contentSize.width / PTM_RATIO, 0));
    groundBody->CreateFixture(&groundBox, 0);
    // top
    groundBox.Set(b2Vec2(0, contentSize.height / PTM_RATIO), b2Vec2(contentSize.width / PTM_RATIO, contentSize.height / PTM_RATIO));
    groundBody->CreateFixture(&groundBox, 0);
    // left
    groundBox.Set(b2Vec2(0, contentSize.height / PTM_RATIO), b2Vec2(0, 0));
    groundBody->CreateFixture(&groundBox, 0);
    // right
    groundBox.Set(b2Vec2(contentSize.width / PTM_RATIO, contentSize.height / PTM_RATIO), b2Vec2(contentSize.width / PTM_RATIO, 0));
    groundBody->CreateFixture(&groundBox, 0);
    
    // level
    b2BodyDef levBodyDef;
    levBodyDef.position.Set(0, 0);
    levBodyDef.userData = (__bridge void *)[self.layer createUserDataWithObject:self];
    levBody = self.world->CreateBody(&levBodyDef);
    
    [self createCollisionMap];
    
//    [self createItems];

    return self;
}

- (CGSize)getSize
{
    return CGSizeMake(0, 0);
}

- (void)registerPlayerStartCoords:(CGPoint)coords rotate:(float)rotate
{
    GameStartCoords *c = [[GameStartCoords alloc] initWithCoords:coords.x y:coords.y rotate:rotate];
    [self.startCoordsManager add:c];
}

- (void)registerItemWithCoords:(CGPoint)coords type:(GameItemType)aType
{
    GameItem *item = [[GameItem alloc] initWithPosition:coords type:aType layer:_layer];
    [items addObject:item];
}

- (void)registerDecorationWithCoords:(CGPoint)coords type:(GameDecorationType)aType
{
    GameDecoration *d = [[GameDecoration alloc] initWithPosition:coords type:aType layer:_layer];
    [decorations addObject:d];
}

- (void)createCollisionMap
{
    /* abstract */
}

- (void)createItems
{
    /* abstract */
}

- (NSString *)getFilename;
{
    /* abstract */
    return @"";
}

+ (NSString *)getLabel;
{
    /* abstract */
    return @"";
}

+ (NSString *)getGameCenterID;
{
    /* abstract */
    return @"";
}

+ (int)menuImageIndex;
{
    return LEVEL_FRAGTEMPLE_IMAGE_INDEX;
}

- (float)getScale
{
    return 1.0f;
}

@end
