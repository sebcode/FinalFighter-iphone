
#import "GameAmmoMine.h"
#import "GameSoundPlayer.h"
#import "GameTank.h"

@implementation GameAmmoMine

#pragma mark - Init/reset

- (void)resetWithPosition:(CGPoint)aPos angle:(float)aAngle type:(GameWeaponType)aType sender:(GameObject *)aSender resetPosition:(BOOL)aResetPosition
{
    [super resetWithPosition:aPos angle:aAngle type:aType sender:aSender resetPosition:aResetPosition];
    
    _isLethal = NO;
}

#pragma mark - Configuration

- (void)initSprite
{
    if (_sprite) {
        [_sprite removeFromParentAndCleanup:YES];
        _sprite = nil;
    }

    _sprite = [CCSprite spriteWithSpriteFrameName:@"ammo_mine_0.png"];

    if (!animation) {
        NSMutableArray *animFrames = [NSMutableArray arrayWithCapacity:11];
        
        for (int i = 0; i < 11; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"ammo_mine_%d.png", i]];
            [animFrames addObject:frame];
        }
        
        animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.019f];
        animation.restoreOriginalFrame = YES;
    }
    
    [_sprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]]];
}

- (int)damagePoints
{
    return 100;
}

- (float)getSpeed
{
    return 1.0f;
}

- (float)getMaxAge
{
    return 100.0f;
}

- (float)getDamping
{
    return 10.0f;
}

- (uint16)getMaskBits
{
    return catAll & ~catAmmo;
}

- (void)playExplodeSound
{
    [[GameSoundPlayer getInstance] play:GameSoundExplosion];
}

- (void)playLaunchSound
{
    [[GameSoundPlayer getInstance] play:GameSoundWeaponGrenade];
}

- (void)ageTimeout
{
    [self explode];
}

#pragma mark - Explosion

- (void)showExplosion
{
    if (!explodeAnimation) {
        NSMutableArray *animFrames = [NSMutableArray arrayWithCapacity:30];
        
        for (int i = 0; i < 30; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"explosion_tank_%d.png", i]];
            [animFrames addObject:frame];
        }
        
        explodeAnimation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.019f];
        explodeAnimation.restoreOriginalFrame = YES;
    }
    
    _sprite.scale = 1.0;
    [_sprite runAction:[CCSequence actions:
                        [CCAnimate actionWithAnimation:explodeAnimation],
                        [CCCallFunc actionWithTarget:self selector:@selector(deactivate)],
                        nil]
     ];
}

#pragma mark - Reset

- (void)contact:(GameObject *)object
{
    if (object.category == catAmmo || object.category == catTankSensor) {
        return;
    }

    if ([object isKindOfClass:[GameTank class]]) {
        GameTank *tank = (GameTank *)object;
        if (tank == self.sender && !self.isLethal) {
            return;
        }
    }
    
    [self explode];
}

@end
