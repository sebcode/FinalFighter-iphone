
#import "GameAmmoFlame.h"
#import "GameLevel.h"
#import "GameSoundPlayer.h"
#import "GameTank.h"

@implementation GameAmmoFlame

#pragma mark - Init/reset

- (void)initSprite
{
    if (_sprite) {
        [_sprite removeFromParentAndCleanup:YES];
        _sprite = nil;
    }

    _sprite = [CCSprite spriteWithSpriteFrameName:@"ammo_flame_0.png"];

    if (!animation) {
        NSMutableArray *animFrames = [NSMutableArray arrayWithCapacity:16];
        
        for (int i = 0; i < 16; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"ammo_flame_%d.png", i]];
            [animFrames addObject:frame];
        }
        
        animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.019f];
        animation.restoreOriginalFrame = YES;
    }
    
    [_sprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]]];
}

#pragma mark - Configuration

- (float)getRestitution
{
    return 0.01;
}

- (float)getMaxAge
{
    return 2.0;
}

- (int)damagePoints
{
    return 10;
}

- (void)playLaunchSound
{
    [[GameSoundPlayer getInstance] play:@"weapon_flame"];
}

- (void)playExplodeSound
{
    /* nope */
}

#pragma mark - Rest

- (void)contact:(GameObject *)object
{
    if (object.category == catAmmo || object.category == catWall || object.category == catTankSensor) {
        return;
    }

    if ([object isKindOfClass:[GameTank class]]) {
        GameTank *tank = (GameTank *)object;
        if (tank == self.sender) {
            return;
        }
    }
    
    [self deactivate];
}

@end
