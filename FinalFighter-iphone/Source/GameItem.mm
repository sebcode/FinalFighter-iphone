
#import "WorldLayer.h"
#import "GameItem.h"
#import "GameTank.h"
#import "GameUserData.h"

@implementation GameItem

static NSString *GameItemSprites[] = {
    @"",
    @"item_grenade_%d.png",
    @"item_flame_%d.png",
    @"item_rocket_%d.png",
    @"item_mine_%d.png",
    @"item_repair_%d.png",
};

static int GameItemSpritesNumFrames[] = {
    0,
    33,
    32,
    33,
    33,
    17
};

- (id)initWithPosition:(CGPoint)pos type:(GameItemType)aType layer:(WorldLayer *)aLayer
{
    self = [super initWithLayer:aLayer];
    if (!self) {
        return self;
    }
    
    _category = catItem;
    originalPos = pos;
    _type = aType;
    
    NSString *filename = GameItemSprites[aType];
    NSMutableArray *animFrames = [NSMutableArray array];
    int numberOfFrames = GameItemSpritesNumFrames[aType];
    
    for (int i = 0; i < numberOfFrames; i++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:filename, i]];
        [animFrames addObject:frame];
    }
    
    _sprite = [CCSprite spriteWithSpriteFrame:[animFrames objectAtIndex:0]];
    _sprite.position = pos;
    _sprite.scale = 0;
    _sprite.zOrder = 100;
    [_layer addChild:_sprite];

    [_sprite runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.05];
    CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
    [_sprite runAction:[CCRepeatForever actionWithAction: animate]];

    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.userData = (__bridge void *)[self.layer createUserDataWithObject:self];
    bodyDef.linearDamping = 0.0;
    bodyDef.angularDamping = 0.0;
	body = self.world->CreateBody(&bodyDef);
    
	b2CircleShape dynamicBox;
    dynamicBox.m_p.Set(0, 0);
    dynamicBox.m_radius = 0.6;
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 0.0f;
	fixtureDef.friction = 0.0f;
    fixtureDef.isSensor = YES;
    fixtureDef.filter.categoryBits = catItem;
    fixtureDef.filter.maskBits = catTank | catTankSensor;
	body->CreateFixture(&fixtureDef);
    
    [self reset];
    
    return self;
}

- (void)reset
{
    _sprite.opacity = 200;
    respawnTime = 0;
    fadingAway = NO;
    
    b2Vec2 p;
    p.x = originalPos.x / PTM_RATIO;
    p.y = originalPos.y / PTM_RATIO;
    body->SetTransform(p, 0);
    [self activateBody];
}

- (void)tick:(ccTime)dt
{
    if (!fadingAway) {
        _sprite.position = CGPointMake(body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO);
    }
    
    if (respawnTime > 0) {
        respawnTime -= dt;
    }
    
    if (respawnTime < 0) {
        [self reset];
        _sprite.scale = 0;
        [_sprite runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    }
}

- (void)contact:(GameObject *)object
{
    if (object.category == catTank) {
        [self deactivateBody];
        
        _sprite.opacity = 150;
        id a = [CCScaleTo actionWithDuration:0.2 scale:5.0];
        id a2 = [CCFadeOut actionWithDuration:0.1];
        [_sprite runAction:[CCSequence actions:a, a2, nil]];
        
        fadingAway = YES;
        respawnTime = 10.0;
        _collectCount++;
    }
}

@end
