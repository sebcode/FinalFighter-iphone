
#import "GameSoundPlayer.h"
#import "GameTank.h"
#import "GameAmmo.h"
#import "GameAmmoRocket.h"
#import "GameUserData.h"
#import "GameWeapon.h"
#import "WorldLayer.h"
#import "GameAmmoMine.h"
#import "GameAmmoGrenade.h"
#import "GameAmmoFlame.h"

@implementation GameAmmo
@synthesize damagePoints;
@synthesize sender;
@synthesize type;

#define USE_CACHE YES

#pragma mark - Configuration consts

static const Class GameWeaponAmmoClass[] = {
    [GameAmmo class],
    [GameAmmoGrenade class],
    [GameAmmoFlame class],
    [GameAmmoRocket class],
    [GameAmmoMine class]
};

static const NSMutableArray *reuseCache[5] = { nil, nil, nil, nil, nil };

#pragma mark - Cache

+ (void)clearCache
{
    for (int i = 0; i < 5; i++) {
        reuseCache[i] = [NSMutableArray arrayWithCapacity:50];
    }
}

#pragma mark - Init/reset

+ (GameAmmo *)ammoWithPosition:(CGPoint)aPos angle:(float)aAngle type:(GameWeaponType)aType sender:(GameObject *)aSender
{
    static BOOL initialized = NO;
    
    if (!initialized) {
        [GameAmmo clearCache];
        initialized = YES;
    }

    GameAmmo *instance = nil;
    
    if (USE_CACHE && reuseCache[aType].count) {
        instance = [reuseCache[aType] lastObject];
        [reuseCache[aType] removeLastObject];
        [instance resetWithPosition:aPos angle:aAngle type:aType sender:aSender];
    } else {
        instance = [[GameWeaponAmmoClass[aType] alloc] initWithPosition:aPos angle:aAngle type:aType sender:aSender];
    }
    
    return instance;
}

- (id)initWithPosition:(CGPoint)aPos angle:(float)aAngle type:(GameWeaponType)aType sender:(GameObject *)aSender
{
    self = [super initWithLayer:aSender.layer];
    if (!self) {
        return self;
    }
    
    maxAge = [self getMaxAge];
    lethalAge = [self getLethalAge];
    _category = catAmmo;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.userData = (__bridge void *)[self.layer createUserDataWithObject:self];
    bodyDef.linearDamping = [self getDamping];
    bodyDef.angularDamping = [self getDamping];
    bodyDef.bullet = YES;
    bodyDef.position.x = aPos.x / PTM_RATIO;
    bodyDef.position.y = aPos.y / PTM_RATIO;
    body = self.world->CreateBody(&bodyDef);
    
	b2CircleShape shape;
    shape.m_p.Set(0, 0);
    shape.m_radius = 0.1;
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 1.0f;
    fixtureDef.filter.categoryBits = catAmmo;
    fixtureDef.filter.maskBits = [self getMaskBits];
    fixtureDef.restitution = [self getRestitution];
	fixture = body->CreateFixture(&fixtureDef);
    
    [self resetWithPosition:aPos angle:aAngle type:aType sender:aSender resetPosition:NO];
    
    return self;
}

- (void)resetWithPosition:(CGPoint)aPos angle:(float)aAngle type:(GameWeaponType)aType sender:(GameObject *)aSender
{
    [self resetWithPosition:aPos angle:aAngle type:aType sender:aSender resetPosition:YES];
}

- (void)resetWithPosition:(CGPoint)aPos angle:(float)aAngle type:(GameWeaponType)aType sender:(GameObject *)aSender resetPosition:(BOOL)aResetPosition
{
    sender = aSender;
    _ignoreCollisionWith = aSender;
    type = aType;
    age = 0;
    exploding = NO;
    _isLethal = YES;
    
    [self initSprite];
    _sprite.position = aPos;
    _sprite.zOrder = 15;
    _sprite.visible = NO;
    _sprite.scale = 1.0f;
    [_layer addChild:_sprite];

    if (aResetPosition) {
        b2Vec2 pos;
        pos.x = aPos.x / PTM_RATIO;
        pos.y = aPos.y / PTM_RATIO;
        body->SetTransform(pos, CC_DEGREES_TO_RADIANS((aAngle * -1) - 90));
        [self activateBody];
    }

    float speed = [self getSpeed];
    float a = CC_DEGREES_TO_RADIANS((aAngle * -1) - 90);
    b2Vec2 velocity = speed * b2Vec2(cos(a), sin(a));
    body->ApplyLinearImpulse(velocity, body->GetWorldCenter());
    body->ApplyAngularImpulse(0.5);
    
    self.active = YES;
    
    [self playLaunchSound];
}

#pragma mark - Configuration

- (void)initSprite
{
    if (_sprite) {
        [_sprite removeFromParentAndCleanup:YES];
        _sprite = nil;
    }
    
    _sprite = [CCSprite spriteWithSpriteFrameName:@"ammo_minigun.png"];
}

- (void)ageTimeout
{
    [self deactivate];
}

- (uint16)getMaskBits
{
    return catAll & ~catAmmo;
}

- (int)damagePoints
{
    return 5;
}

- (float)getLethalAge
{
    return 0.035f;
}

- (float)getDamping
{
    return 2.0f;
}

- (float)getSpeed
{
    return 1.0f;
}

- (float)getRestitution
{
    return 0.5f;
}

- (float)getMaxAge
{
    return 0.3;
}

- (void)playLaunchSound
{
    [[GameSoundPlayer getInstance] play:@"weapon_m"];
}

- (void)playExplodeSound
{
    [[GameSoundPlayer getInstance] play:[NSString stringWithFormat:@"weapon_m%li", (random() % 3) + 1]];
}

#pragma mark - Explosion

- (void)showExplosion
{
    if (!explodeAnimation) {
        NSMutableArray *animFrames = [NSMutableArray arrayWithCapacity:8];
        
        for (int i = 0; i < 7; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"explosion_minigun_%d.png", i]];
            [animFrames addObject:frame];
        }
        
        explodeAnimation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.019f];
        explodeAnimation.restoreOriginalFrame = YES;
    }
    
    [_sprite runAction:[CCSequence actions:[CCAnimate actionWithAnimation:explodeAnimation],
                        [CCCallFunc actionWithTarget:self selector:@selector(deactivate)],
                        nil]];
}

- (void)explode
{
    if (exploding) {
        return;
    }
    
    exploding = YES;
    [self showExplosion];
    [self playExplodeSound];
}

#pragma mark - Reset

- (void)deactivate
{
    if (!self.active) {
        return;
    }
    
    if (reuseCache[type].count < 50) {
        body->SetLinearVelocity(b2Vec2(0,0));
        body->SetAngularVelocity(0);
        [self deactivateBody];
        self.active = NO;
        _sprite.visible = NO;
        [reuseCache[type] addObject:self];
    } else {
        [self destroy];
    }
}

- (void)tick:(ccTime)dt
{
    if (!exploding) {
        _sprite.position = CGPointMake(body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO);
        _sprite.rotation = -1 * (CC_RADIANS_TO_DEGREES(body->GetAngle()) + 90);
    }
    
    if (age >= maxAge && !exploding) {
        [self ageTimeout];
    } else {
        age += dt;
    }
    
    if (self.active && age >= lethalAge && !_sprite.visible) {
        _sprite.visible = YES;
        _isLethal = YES;
    }
}

- (void)contact:(GameObject *)object
{
    if (object.category == catAmmo || object.category == catTankSensor) {
        return;
    }
    
    if ([object isKindOfClass:[GameTank class]]) {
        GameTank *tank = (GameTank *)object;
        if (tank == self.sender) {
            return;
        }
    }

    [self explode];
}

- (void)increaseSenderFrags
{
    if (!sender) {
        return;
    }
    
    GameTank *tank = (GameTank *)sender;
    [tank increaseFragsByWeapon:type];
}

@end
