
#import "WorldLayer.h"
#import "GameAmmoRocket.h"
#import "GameSoundPlayer.h"

@implementation GameAmmoRocket

#pragma mark - Init/reset

- (void)resetWithPosition:(CGPoint)aPos angle:(float)aAngle type:(GameWeaponType)aType sender:(GameObject *)aSender resetPosition:(BOOL)aResetPosition
{
    [super resetWithPosition:aPos angle:aAngle type:aType sender:aSender resetPosition:aResetPosition];
    
    ageInt = 0;
}

#pragma mark - Configuration

- (void)initSprite
{
    if (_sprite) {
        [_sprite removeFromParentAndCleanup:YES];
        _sprite = nil;
    }
    
    _sprite = [self createDustSprite];
}

- (float)getSpeed
{
    return 3.0f;
}

- (float)getRestitution
{
    return 0.0f;
}

- (int)damagePoints
{
    return 30;
}

- (float)getMaxAge
{
    return 1.0;
}

- (float)getLethalAge
{
    return 0.01f;
}

- (void)playLaunchSound
{
    [[GameSoundPlayer getInstance] play:GameSoundWeaponRocket];
}

- (void)playExplodeSound
{
    [[GameSoundPlayer getInstance] play:GameSoundExplosion];
}

#pragma mark - Explosion

- (void)showExplosion
{
    if (!explodeAnimation) {
        NSMutableArray *animFrames = [NSMutableArray arrayWithCapacity:30];
        
        for (int i = 0; i < 29; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"explosion_tank_%d.png", i]];
            [animFrames addObject:frame];
        }
        
        explodeAnimation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.019f];
        explodeAnimation.restoreOriginalFrame = YES;
    }
    
    _sprite.scale = 1.5;
    [_sprite runAction:[CCSequence actions:
                        [CCAnimate actionWithAnimation:explodeAnimation],
                        [CCCallFunc actionWithTarget:self selector:@selector(deactivate)],
                        nil]
     ];
}

#pragma mark - Reset

- (CCSprite *)createDustSprite
{
    NSMutableArray *animFrames = [NSMutableArray array];
    
    for (int i = 0; i < 9; i++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"ammo_rocket_%d.png", i]];
        [animFrames addObject:frame];
    }
    
    CCSprite *s = [CCSprite spriteWithSpriteFrame:[animFrames objectAtIndex:0]];
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.025f];
    CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
    [s runAction:[CCSequence actions:animate,
                  [CCCallFuncND actionWithTarget:self selector:@selector(cleanupSprite:) data:(void *)s],
                  nil]];
    
    return s;
}

- (void)cleanupSprite:(CCSprite *)aSprite
{
    if (aSprite == _sprite) {
        return;
    }
    
    [aSprite removeFromParentAndCleanup:YES];
}

- (void)tick:(ccTime)dt
{
    [super tick:dt];

    if (age >= maxAge && !exploding) {
        [self explode];
    } else {
        age += dt;
    }

    ageInt++;
    
    if (!exploding && ageInt % 1 == 0) {
        CCSprite *s = [self createDustSprite];
        s.position = _sprite.position;
        s.zOrder = 15;
        [_layer addChild:s];
    }
}

@end
