
#import "GameAmmoGrenade.h"
#import "GameLevel.h"
#import "GameSoundPlayer.h"
#import "GameTank.h"

@implementation GameAmmoGrenade

#pragma mark - Configuration

- (void)initSprite
{
    _sprite = [CCSprite spriteWithSpriteFrameName:@"ammo_grenade.png"];
}

- (void)playLaunchSound
{
    [[GameSoundPlayer getInstance] play:GameSoundWeaponGrenade];
}

- (void)playExplodeSound
{
    [[GameSoundPlayer getInstance] play:GameSoundExplosion];
}

- (int)damagePoints
{
    return 20;
}

- (float)getMaxAge
{
    return 2.0;
}

#pragma mark - Explosion

- (void)showExplosion
{
    if (!explodeAnimation) {
        NSMutableArray *animFrames = [NSMutableArray arrayWithCapacity:14];
        
        for (int i = 0; i < 14; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"explosion_grenade_%d.png", i]];
            [animFrames addObject:frame];
        }
        
        explodeAnimation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.019f];
        explodeAnimation.restoreOriginalFrame = YES;
    }
    
    [_sprite runAction:[CCSequence actions:[CCAnimate actionWithAnimation:explodeAnimation],
                        [CCCallFunc actionWithTarget:self selector:@selector(deactivate)],
                        nil]];
}

#pragma mark - Rest

- (void)ageTimeout
{
    [self explode];
}

- (void)contact:(GameObject *)object
{
    if (object.category == catWall || object.category == catAmmo || object.category == catTankSensor) {
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

@end
