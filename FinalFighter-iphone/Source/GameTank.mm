
#import "WorldLayer.h"
#import "GameTank.h"
#import "GameLevel.h"
#import "GameItem.h"
#import "GameAmmo.h"
#import "GameSoundPlayer.h"
#import "GameUserData.h"
#import "GameFont.h"
#import "GameStartCoords.h"
#import "GameStartCoordsManager.h"
#import "GameArmory.h"

@implementation GameTank

- (id)initWithLayer:(WorldLayer *)aLayer tank:(int)aTank
{
    self = [super initWithLayer:aLayer];
    if (!self) {
        return self;
    }
    
    _armory = [[GameArmory alloc] init];
    _tankIndex = aTank;
    _category = catTank;
    _autoRespawn = YES;
    _initialHealth = 100;
    
    if (_tankIndex == -1 || _tankIndex > numTanks - 1) {
        _tankIndex = arc4random() % numTanks;
    }
    
    NSString *label = GameTankLabels[aTank];
    NSString *tankShadowFrameName;
    NSString *turretShadowFrameName;
    if ([label hasPrefix:@"Enforcer"]) {
        tankShadowFrameName = @"tank1_shadow_0.png";
        turretShadowFrameName = @"tank1_shadow_1.png";
    } else {
        tankShadowFrameName = @"tank2_shadow_0.png";
        turretShadowFrameName = @"tank2_shadow_1.png";
    }
    
    tankShadowSprite = [CCSprite spriteWithSpriteFrameName:tankShadowFrameName];
    tankShadowSprite.visible = NO;
    tankShadowSprite.anchorPoint = ccp(0.5f, 0.5f);
    tankShadowSprite.opacity = 200.0f;
    [_layer addChild:tankShadowSprite z:5];

    turretShadowSprite = [CCSprite spriteWithSpriteFrameName:turretShadowFrameName];
    turretShadowSprite.visible = NO;
    turretShadowSprite.anchorPoint = ccp(0.5f, 0.5f);
    turretShadowSprite.opacity = 200.0f;
    [_layer addChild:turretShadowSprite z:6];
    
    _sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"tanks_%d.png", _tankIndex]];
    _sprite.visible = NO;
    _sprite.anchorPoint = ccp(0.5f, 0.5f);
    [_layer addChild:_sprite z:10];
    
    turretSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"turrets_%d.png", _tankIndex]];
    turretSprite.visible = NO;
    turretSprite.anchorPoint = ccp(0.5f, 0.5f);
    [_layer addChild:turretSprite z:20];
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.userData = (__bridge void *)[self.layer createUserDataWithObject:self];
    bodyDef.linearDamping = 8.0;
    bodyDef.angularDamping = 10.0;
    body = self.world->CreateBody(&bodyDef);

    b2CircleShape dynamicBox;
    dynamicBox.m_p.Set(0, 0);
    dynamicBox.m_radius = 0.6;
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;	
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.0f;
    fixtureDef.filter.categoryBits = catTank;
    fixtureDef.restitution = 0.5;
    fixture = body->CreateFixture(&fixtureDef);

    b2Vec2 vertices[4];
    b2PolygonShape p;
    b2FixtureDef fd;
    vertices[0].Set(+ 0.0f, + 0.5f);
    vertices[1].Set(+ 0.0f, - 0.5f);
    vertices[2].Set(+ 2.0f, - 0.5f);
    vertices[3].Set(+ 2.0f, + 0.5f);
    p.Set(vertices, 4);
    fd.shape = &p;
    fd.filter.categoryBits = catTankSensor;
    fd.filter.maskBits = catWall | catTank;
    fd.isSensor = YES;
    body->CreateFixture(&fd);

    vertices[0].Set(+ 0.0f, + 0.5f);
    vertices[1].Set(+ 2.0f, + 0.5f);
    vertices[2].Set(+ 2.0f, + 0.9f);
    vertices[3].Set(+ 0.0f, + 0.9f);
    p.Set(vertices, 4);
    fd.shape = &p;
    fd.filter.categoryBits = catTankSensor;
    fd.filter.maskBits = catWall | catTank;
    fd.isSensor = YES;
    fd.userData = (void *) 1;
    body->CreateFixture(&fd);

    vertices[0].Set(+ 0.0f, - 0.9f);
    vertices[1].Set(+ 2.0f, - 0.9f);
    vertices[2].Set(+ 2.0f, - 0.5f);
    vertices[3].Set(+ 0.0f, - 0.5f);
    p.Set(vertices, 4);
    fd.shape = &p;
    fd.filter.categoryBits = catTankSensor;
    fd.filter.maskBits = catWall | catTank;
    fd.isSensor = YES;
    fd.userData = (void *) 2;
    body->CreateFixture(&fd);

    b2CircleShape c;
    c.m_p.Set(0, 0);
    c.m_radius = 7.0;
    b2FixtureDef fd2;
    fd2.shape = &c;
    fd2.filter.categoryBits = catTankSensor;
    fd2.filter.maskBits = catTank;
    fd2.isSensor = YES;
    fd2.userData = (void *) 3;
    body->CreateFixture(&fd2);

#ifdef SHOW_TANK_HEALTH_LABEL
    healthLabel = [CCLabelBMFont labelWithString:@"" fntFile:GameFontDefault];
    healthLabel.opacity = 200;
    healthLabel.scale = 1.0;
    [layer addChild:healthLabel z:30];
#endif

    return self;
}

- (void)doDestroy
{
    [super doDestroy];
    
    if (tankShadowSprite) {
        [tankShadowSprite removeFromParentAndCleanup:YES];
        tankShadowSprite = nil;
    }
    
    if (turretShadowSprite) {
        [turretShadowSprite removeFromParentAndCleanup:YES];
        turretShadowSprite = nil;
    }
    
    if (turretSprite) {
        [turretSprite removeFromParentAndCleanup:YES];
        turretSprite = nil;
    }
}

- (void)showExplosion
{
    if (!explodeAnimation) {
        NSMutableArray *animFrames = [NSMutableArray arrayWithCapacity:30];
        
        for (int i = 0; i < 30; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"explosion_tank_%d.png", i]];
            [animFrames addObject:frame];
        }
        
        explodeAnimation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.019f];
    }
    
    CCSprite *sprite2 = [CCSprite spriteWithSpriteFrameName:@"explosion_tank_0.png"];
    sprite2.position = _sprite.position;
    sprite2.zOrder = 100;
    sprite2.scale = 1.5;
    [_layer addChild:sprite2];
    
    [sprite2 runAction:[CCSequence actions:[CCAnimate actionWithAnimation:explodeAnimation],
                        [CCCallBlock actionWithBlock:^{
                            sprite2.visible = NO;
                            [self deactivateBody];
                        }],
                        [CCDelayTime actionWithDuration:1.5f],
                        [CCCallFuncND actionWithTarget:self selector:@selector(explodeDone:) data:(void *)sprite2],
                        nil]];
}

- (void)explode
{
    if (_exploding) {
        return;
    }
    
    _sprite.visible = NO;
    turretSprite.visible = NO;
    tankShadowSprite.visible = NO;
    turretShadowSprite.visible = NO;
    _exploding = YES;
    [self showExplosion];
    [[GameSoundPlayer getInstance] play:GameSoundExplosion];
}

- (void)explodeDone:(CCSprite *)aSprite
{
    [aSprite removeFromParentAndCleanup:YES];
    
    [self reset];
}

- (void)tick:(ccTime)dt
{
    _sprite.position = CGPointMake(body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO);
    _sprite.rotation = -1 * (CC_RADIANS_TO_DEGREES(body->GetAngle()) + 90);
    turretSprite.position = CGPointMake(body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO);
    
    tankShadowSprite.position = _sprite.position;
    tankShadowSprite.rotation = _sprite.rotation;
    turretShadowSprite.position = turretSprite.position;
    
#ifdef SHOW_TANK_HEALTH_LABEL
    if (healthLabel) {
        healthLabel.position = sprite.position;
        healthLabel.string = [NSString stringWithFormat:@"%i", health];        
    }
#endif
    
    if (_exploding) {
        return;
    }
    
    if (_moveUp) {
        float a = body->GetAngle();
        float speed = 60.0f * dt;
        b2Vec2 velocity = speed * b2Vec2(cos(a), sin(a));
        body->ApplyLinearImpulse(velocity, body->GetWorldCenter());
    }
    
    if (_moveDown) {
        float a = body->GetAngle();
        float speed = 60.0f * dt;
        b2Vec2 velocity = speed * b2Vec2(cos(a), sin(a));
        body->ApplyLinearImpulse(- velocity, body->GetWorldCenter());
    }
    
    if (_moveLeft) {
        [self moveLeftImpulse:dt];
    }
    
    if (_moveRight) {
        [self moveRightImpulse:dt];
    }
    
    if (_fire) {
        [self doFire];
    }
    
    if (fireDelay > 0) {
        fireDelay -= dt;
    }
}

- (void)moveLeftImpulse:(ccTime)dt
{
    body->ApplyAngularImpulse(dt * 12.0f);
}

- (void)moveRightImpulse:(ccTime)dt
{
    body->ApplyAngularImpulse(- (dt * 12.0f));
}

- (void)reset
{
    GameStartCoordsManager *scm = nil;
    
    if (_startCoordsManager) {
        scm = _startCoordsManager;
    } else {
        scm = _layer.level.startCoordsManager;
    }

    if (self.autoRespawn && scm) {
        [_armory reset];
        GameStartCoords *c = [scm get];
        [self resetWithStartCoords:c];
    } else {
        [self destroy];
    }
}

- (void)resetWithStartCoords:(GameStartCoords *)c
{
    _health = self.initialHealth;

    _sprite.opacity = 0;
    turretSprite.opacity = 0;
    tankShadowSprite.opacity = 0;
    turretShadowSprite.opacity = 0;

    _sprite.visible = YES;
    turretSprite.visible = YES;
    tankShadowSprite.visible = YES;
    turretShadowSprite.visible = YES;
    
    [_sprite runAction:[CCFadeIn actionWithDuration:0.5f]];
    [turretSprite runAction:[CCFadeIn actionWithDuration:0.5f]];
    [tankShadowSprite runAction:[CCFadeIn actionWithDuration:0.5f]];
    [turretShadowSprite runAction:[CCFadeIn actionWithDuration:0.5f]];

    _exploding = NO;
    
    [self activateBody];
    
    b2Vec2 pos;
    pos.x = c.x / PTM_RATIO;
    pos.y = c.y / PTM_RATIO;
    if (body) {
        body->SetTransform(pos, CC_DEGREES_TO_RADIANS(c.rotate));
    }
}

- (void)consumeItem:(GameItem *)aItem
{
    if (aItem.type == kItemRepair) {
        [self repair];
        return;
    }
    
    [_armory consumeItem:aItem.type];
}

- (void)repair
{
    if (_health >= 150) {
        return;
    }
    
    _health += 50;
    
    if (_health >= 150) {
        _health = 150;
    }
}

- (void)cheat
{
    _health = 999999;
}

- (void)applyDamage:(GameAmmo *)aAmmo
{
    if (_exploding) {
        return;
    }

    if (aAmmo.sender == self && aAmmo.type != kWeaponMine) {
        return;
    }
    
    _health -= aAmmo.damagePoints;
    
    [self applyLeveragedDamage:aAmmo];
    
    if (_health <= 0) {
        if ([aAmmo.sender isEqual:self]) {
            [self decreaseFrags];
        } else {
            [aAmmo increaseSenderFrags];
        }
        
        _deathCount++;
        [self explode];
    } else {
        id a1 = [CCTintTo actionWithDuration:0.1f red:255.0f green:0.0f blue:0.0f];
        id a2 = [CCTintTo actionWithDuration:0.1f red:255.0f green:255.0f blue:255.0f];
        [_sprite runAction:[CCSequence actions:a1, a2, nil]];
        id at1 = [CCTintTo actionWithDuration:0.1f red:255.0f green:0.0f blue:0.0f];
        id at2 = [CCTintTo actionWithDuration:0.1f red:255.0f green:255.0f blue:255.0f];
        [turretSprite runAction:[CCSequence actions:at1, at2, nil]];
    }
}

- (void)applyLeveragedDamage:(GameAmmo *)aAmmo
{
    /* abstract */
}

- (BOOL)doFireWeapon:(GameWeapon *)aWeapon
{
    if (fireDelay > 0) {
        return NO;
    }
    
    if (![aWeapon consumeBullet]) {
        return NO;
    }
    
    /* throwback tank on rocket launch */
    if (aWeapon.type == kWeaponRocket) {
        float a = -1 * CC_DEGREES_TO_RADIANS(turretSprite.rotation + 90);
        float speed = 10.0;
        b2Vec2 velocity = speed * b2Vec2(cos(a), sin(a));
        body->ApplyLinearImpulse(- velocity, body->GetWorldCenter());
    }
    
    [GameAmmo ammoWithPosition:_sprite.position angle:turretSprite.rotation type:aWeapon.type sender:self];

    if (aWeapon.isRelentless) {
        fireDelay = 0.1;
    } else {
        fireDelay = 0.5;
    }
    
    return YES;
}

- (BOOL)doFire
{
    GameWeapon *w = _armory.selectedWeapon;

    [self doFireWeapon:w];
    
    if (!w.hasAmmo) {
        [self.armory selectBestLoadedWeapon];
        _fire = NO;
    }
    
    return YES;
}

- (void)nextWeapon
{
    GameWeapon *w = _armory.selectedWeapon;
    
    [_armory next];
    
    if (w == _armory.selectedWeapon) {
        [[GameSoundPlayer getInstance] play:GameSoundWeaponChangeEmpty];
        return;
    }
    
    [[GameSoundPlayer getInstance] play:GameSoundWeaponChange];
}

- (void)prevWeapon
{
    GameWeapon *w = _armory.selectedWeapon;
    
    [_armory prev];
    
    if (w == _armory.selectedWeapon) {
        [[GameSoundPlayer getInstance] play:GameSoundWeaponChangeEmpty];
        return;
    }
    
    [[GameSoundPlayer getInstance] play:GameSoundWeaponChange];
}

- (void)sensorContact:(GameObject *)aObject begin:(BOOL)aBegin fixture:(b2Fixture *)aFixture
{
    /* abstract */
}

- (void)contact:(GameObject *)aObject
{
    if (aObject.category == catItem) {
        [self consumeItem:(GameItem *)aObject];
    } else if (aObject.category == catAmmo) {
        GameAmmo *ammo = (GameAmmo *)aObject;
        if (ammo.isLethal) {
            [self applyDamage:ammo];
        }
    }
}

- (void)increaseFragsByWeapon:(GameWeaponType)aType
{
    _frags++;
    
    [_layer.hudLayer updatePlayersList];
    
    [_layer checkFragLimit:self];
}

- (void)decreaseFrags
{
    _frags--;
    
    [_layer.hudLayer updatePlayersList];
}

@end
