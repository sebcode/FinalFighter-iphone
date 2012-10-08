
#import "WorldLayer.h"
#import "GameConstants.h"
#import "GameEnemy.h"
#import "GameUserData.h"
#import "GameArmory.h"
#import "GameAmmo.h"
#import "GamePlayer.h"

@implementation GameEnemy
@synthesize inactive;
@synthesize friendly;

static float leveragedDamageFactor = 0;

+ (void)setLeveragedDamageFactor:(float)aFactor
{
    leveragedDamageFactor = aFactor;
}

- (id)initWithLayer:(WorldLayer *)aLayer tank:(int)aTank
{
    self = [super initWithLayer:aLayer tank:aTank];
    if (!self) {
        return self;
    }
    
    return [self init];
}

- (id)init
{
    self = [super init];
    if (!self) {
        return self;
    }
    
    [self setLevel:GameEnemyLevelEasy];

    _moveUp = YES;
    
#ifdef ENEMIES_DONT_MOVE
    _moveUp = NO;
#endif
    
    tanksInRange = [NSMutableArray arrayWithCapacity:10];
    
    /* turret sensor */
    b2BodyDef bodyDef2;
    b2Vec2 vertices[4];
    b2PolygonShape p;
    bodyDef2.type = b2_dynamicBody;
    bodyDef2.userData = (__bridge void *)[self.layer createUserDataWithObject:self doTick:NO];
    bodyDef2.linearDamping = 0;
    bodyDef2.angularDamping = 0;
    turretSensorBody = self.world->CreateBody(&bodyDef2);
    vertices[0].Set(+ 0.0f, + 0.1f);
    vertices[1].Set(+ 0.0f, - 0.1f);
    vertices[2].Set(+ 7.0f, - 0.1f);
    vertices[3].Set(+ 7.0f, + 0.1f);
    p.Set(vertices, 4);
    b2FixtureDef fd3;
    fd3.shape = &p;
    fd3.filter.categoryBits = catTankSensor;
    fd3.filter.maskBits = catWall | catTank;
    fd3.isSensor = YES;
    fd3.userData = (void *) 4;
    turretSensorFixture = turretSensorBody->CreateFixture(&fd3);
    
    return self;
}

- (void)doDestroy
{
    [super doDestroy];
    
    if (turretSensorBody) {
        self.world->DestroyBody(turretSensorBody);
        turretSensorBody = nil;
    }
}

- (GameEnemyLevel)getLevel
{
    return level;
}

- (void)setLevel:(GameEnemyLevel)aLevel
{
    switch (aLevel) {
        case GameEnemyLevelHard:
            turretRotationSpeed = 500.0f;
            inaccuracyAngle = 5.0f;
            break;
            
        case GameEnemyLevelMedium:
            turretRotationSpeed = 400.0f;
            inaccuracyAngle = 15.0f;
            break;
            
        default:
        case GameEnemyLevelEasy:
            turretRotationSpeed = 300.0f;
            inaccuracyAngle = 30.0f;
            break;
    }
}

- (void)tick:(ccTime)dt
{
    if (inactive) {
        _moveUp = NO;
        _moveDown = NO;
        _moveLeft = NO;
        _moveRight = NO;
        _fire = NO;
    }
    
    [super tick:dt];

    if (actionDelay > 0) {
        actionDelay -= 10 * dt;
    }
    
    if (actionDelay <= 0) {
        actionDelay = 1.0f + (arc4random() % 10);
        
        if (!leftSensor && !rightSensor && _moveUp) {
            int dir = arc4random() % 2;
            
            if (dir) {
                [self moveLeftImpulse:dt * 5.0f];
            } else {
                [self moveRightImpulse:dt * 5.0f];
            }
        }
    }
    
    if (retargetDelay < 1000) {
        retargetDelay += dt;
    }

    if (checkMineDelay < 1000) {
        checkMineDelay += dt;
    }

    if (inaccuracyDelay < 1000) {
        inaccuracyDelay += dt;
    }

    /* turn turret smoothly to target angle
     * http://www.gamedev.net/topic/96281-shortest-rotation-from-one-direction-to-another/
     */
    float target = moveTurretTo - 90.0f;
    float turret = turretSprite.rotation - 90.0f;
    float diff = target - turret;
    if (diff > 180.0f) diff -= 360.0f;
    if (diff < -180.0f) diff += 360.0f;
    if (diff > 0) {
        if (diff <= 2.0f) {
            turret = target;
        } else {
            turret += dt * turretRotationSpeed;
        }
    } else {
        if (diff >= -2.0f) {
            turret = target;
        } else {
            turret -= dt * turretRotationSpeed;
        }
    }
    turretSprite.rotation = turret + 90.0f;
    turretShadowSprite.rotation = turretSprite.rotation;
    
    /* erst feuern, wenn turret im 32 grad radius ist */
    float diffAbs = diff * (diff < 0 ? -1 : 1);
    BOOL mayFire = diffAbs < 32.0f;
    
#ifdef SHOW_TANK_HEALTH_LABEL
    if (healthLabel) {
        healthLabel.position = sprite.position;
        //healthLabel.string = [NSString stringWithFormat:@"L:%i R:%i", leftSensor, rightSensor];
        healthLabel.string = [NSString stringWithFormat:@"%i", health];
    }
#endif
    
    if (targetTank) {
        b2Vec2 pos = body->GetPosition();
        CGPoint loc = targetTank.sprite.position;
        float o = loc.x - (pos.x * PTM_RATIO);
        float a = loc.y - (pos.y * PTM_RATIO);
        float at = (float) CC_RADIANS_TO_DEGREES(atanf(o / a));
        
        if (a < 0) {
            if (o < 0) {
                at = 180 + abs(at);
            } else {
                at = 180 - abs(at);
            }
        }

        turretSensorBody->SetTransform(pos, -1 * CC_DEGREES_TO_RADIANS(at + 270.0f));
        
        /* add some inaccuracy */
        if (inaccuracyDelay > 1.0f) {
            inaccuracyDelay = 0;
            int a = arc4random() % 2;
            int b = arc4random() % inaccuracyAngle;
            int c = (a == 0 ? -1 : 1) * b;
            inaccuracy = (float)c;
        }

        if (mayFire && turretSensorWallContact <= 0 && !inactive && !friendly && !targetTank.exploding) {
            _fire = YES;
#ifdef ENEMIES_DONT_FIRE
            _fire = NO;
#endif
            
            moveTurretTo = at + 180.0f + inaccuracy;
            
            [self checkMine];
        } else {
            /* gegner ist in reichweite, aber eine wand versperrt den weg.
             * mit ballern aufhoeren. */
            _fire = NO;
            
            /* wenn moeglich, anderen gegner in reichweite anvisieren.
             * aber nur nach einem delay, um wildes hin und herspringen
             * des turms zu vermeiden. */
            if (retargetDelay > 0.5f) {
                targetTank = [self selectOtherTankInRange:targetTank];
                retargetDelay = 0;
            }
            
            moveTurretTo = at + 180.0f;
        }

        CGPoint p;
        p.x = pos.x * PTM_RATIO;
        p.y = pos.y * PTM_RATIO;
        float distance = (ccpDistance(loc, p) / PTM_RATIO) - 1.0f;
        
        if (distance >= 1.0f) {
            b2PolygonShape *s = (b2PolygonShape *)turretSensorFixture->GetShape();
            b2Vec2 vertices[4];
            vertices[0].Set(+ 0.0f, + 0.1f);
            vertices[1].Set(+ 0.0f, - 0.1f);
            vertices[2].Set(+ distance, - 0.1f);
            vertices[3].Set(+ distance, + 0.1f);
            s->Set(vertices, 4);
        }        
    } else {
        _fire = NO;
    }
}

- (void)sensorContact:(GameObject *)aObject begin:(BOOL)aBegin fixture:(b2Fixture *)aFixture
{
    size_t sensorType = (size_t) aFixture->GetUserData();
    if (sensorType >= 1 && sensorType <= 4) {
        if (sensorType == 1) { // left
            if (aObject.category != catWall) {
                return;
            }
            if (aBegin) {
                leftSensor++;
            } else {
                leftSensor--;
            }
        } else if (sensorType == 2) { // right
            if (aObject.category != catWall) {
                return;
            }
            if (aBegin) {
                rightSensor++;
            } else {
                rightSensor--;
            }
        } else if (sensorType == 3 && aObject.category == catTank) { // enemy circle sensor
            if (aBegin) {
                if (![tanksInRange containsObject:aObject]) {
                    [tanksInRange addObject:aObject];
                    targetTank = (GameTank *)aObject;
                }
            } else {
                [tanksInRange removeObject:aObject];
                if ([aObject isEqual:targetTank]) {
                    targetTank = [tanksInRange lastObject];
                }
            }
        } else if (sensorType == 4) {
            if (aObject.category != catWall) {
                return;
            }
            if (aBegin) {
                turretSensorWallContact++;
            } else {
                turretSensorWallContact--;            
            }
        }
        
        return;
    }

    if (aObject.category != catWall) {
        return;
    }
        
    if (aBegin) {
        wallSensor++;
                
        if (wallSensor == 1) {
            [self autoTurn];
        }
    } else {
        wallSensor--;
                
        if (!wallSensor && !inactive) {
            _moveLeft = NO;
            _moveRight = NO;
            _moveUp = YES;
        }
    }
}

- (void)autoTurn
{
    if (inactive) {
        return;
    }
    
    if (!leftSensor && rightSensor) {
        _moveLeft = YES;
        _moveRight = NO;
        _moveUp = NO;
    } else if (leftSensor && !rightSensor) {
        _moveLeft = NO;
        _moveRight = YES;
        _moveUp = NO;
    } else {
        int dir = arc4random() % 2;
        
        if (dir) {
            _moveLeft = YES;
            _moveRight = NO;
            _moveUp = NO;
        } else {
            _moveLeft = NO;
            _moveRight = YES;
            _moveUp = NO;
        }
    }
}

- (void)explodeDone:(CCSprite *)aSprite
{
    [super explodeDone:aSprite];
    
    if (!self.autoRespawn) {
        [self destroy];
    }
}

- (void)consumeItem:(GameItem *)aItem
{
    [super consumeItem:aItem];
    
    [self.armory selectBestLoadedWeapon];
}

/* pruefen, ob wir eine mine legen koennen.
 * wir legen dann, wenn wir nach vorne fahren und direkt hinter und
 * ein gegner lungert. */
- (void)checkMine
{
    /* nur alle 0.5s mine legen */
    if (retargetDelay < 0.5f) {
        return;
    }
    retargetDelay = 0;

    /* haben wir ueberhaupt minen? */
    GameWeapon *w = [self.armory getWeapon:kWeaponMine];
    if (!w.hasAmmo) {
        return;
    }

    float r1 = CC_DEGREES_TO_RADIANS(_sprite.rotation);
    float f1 = atan2(sin(r1), cos(r1));
    int ff1 = CC_RADIANS_TO_DEGREES(f1);
    
    float r2 = CC_DEGREES_TO_RADIANS(turretSprite.rotation);
    float f2 = atan2(sin(r2), cos(r2));
    int ff2 = CC_RADIANS_TO_DEGREES(f2) - 180;
    
    int diff = ff1 - ff2;
    int range = 30;
    BOOL inRange = abs(diff % 360) <= range || (360 - abs(diff % 360) <= range);
    
    if (!inRange) {
        /* wenn minen schon als waffe ausgewaehlt sind, aber die zu legen
         * nicht sinnvoll ist, waffe wechseln. */
        [self.armory selectBestLoadedWeapon];
        return;
    }
    
    [self.armory selectWeapon:w];
}

- (GameTank *)selectOtherTankInRange:(GameTank *)aCurrentTank
{
    if ([tanksInRange count] <= 1) {
        return aCurrentTank;
    }
    
    if ([tanksInRange count] == 2) {
        GameTank *aTank = [tanksInRange objectAtIndex:0];
        GameTank *bTank = [tanksInRange objectAtIndex:1];
        
        if (aTank == aCurrentTank) {
            return bTank;
        } else {
            return aTank;
        }
    }
    
    NSUInteger retry = 0;
    NSUInteger c = [tanksInRange count];
    
    while (retry++ < 10) {
        NSUInteger i = arc4random() % c;
        GameTank *aTank = [tanksInRange objectAtIndex:i];
        
        if (aTank != aCurrentTank) {
            return aTank;
        }
    }

    return aCurrentTank;
}

- (void)resetWithStartCoords:(GameStartCoords *)c
{
    [super resetWithStartCoords:c];
    
    turretSprite.rotation = _sprite.rotation;
    turretShadowSprite.rotation = _sprite.rotation;
    moveTurretTo = _sprite.rotation;
}

- (void)applyLeveragedDamage:(GameAmmo *)aAmmo
{
    if ([aAmmo.sender isKindOfClass:[GamePlayer class]]) {
        _health -= (int)(aAmmo.damagePoints * leveragedDamageFactor);
    }
}

@end
