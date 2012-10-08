
#import <CoreGraphics/CoreGraphics.h>

#import "GameHudLayer.h"
#import "GameFont.h"
#import "GameTank.h"
#import "GamePlayer.h"
#import "GameWeapon.h"
#import "GameArmory.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedJoystickExample.h"
#import "ColoredCircleSprite.h"

@implementation GameHudLayer

- (id)init
{
	self = [super init];
    if (!self) {
        return self;
    }

    screenSize = [CCDirector sharedDirector].winSize;
    
    self.isTouchEnabled = YES;
    
    weaponSprite = [CCSprite spriteWithSpriteFrameName:@"weapon_0.png"];
    weaponSprite.opacity = 150;
    [self addChild:weaponSprite z:10];
    
    healthSprite = [CCSprite spriteWithSpriteFrameName:@"hud_health.png"];
    healthSprite.opacity = 150;
    [self addChild:healthSprite z:10];

    healthLabel = [CCLabelBMFont labelWithString:@"" fntFile:GameFontDefault];
    healthLabel.opacity = 150;
    [self addChild:healthLabel z:20];

    fragSprite = [CCSprite spriteWithSpriteFrameName:@"hud_fragskull.png"];
    fragSprite.opacity = 150;
    [self addChild:fragSprite z:10];

    fragLabel = [CCLabelBMFont labelWithString:@"0" fntFile:GameFontDefault];
    fragLabel.opacity = 150;
    [self addChild:fragLabel z:20];

    /* weapon label (machine gun) */
    ammoLabel = [CCLabelBMFont labelWithString:@"" fntFile:GameFontDefault];
    ammoLabel.opacity = 150;
    ammoLabel.anchorPoint = ccp(1, 0);
    ammoLabel.alignment = kCCTextAlignmentRight;
    [self addChild:ammoLabel z:20];

    /* remaining ammo count */
    ammoLabel2 = [CCLabelBMFont labelWithString:@"" fntFile:GameFontDefault];
    ammoLabel2.opacity = 150;
    ammoLabel2.anchorPoint = ccp(1, 0);
    ammoLabel2.alignment = kCCTextAlignmentRight;
    [self addChild:ammoLabel2 z:20];
    
    timeLabel = [CCLabelBMFont labelWithString:@"0:00" fntFile:GameFontSmall];
    timeLabel.opacity = 150;
    timeLabel.anchorPoint = ccp(0, 0);
    [self addChild:timeLabel z:20];

    playersLabel = [CCLabelBMFont labelWithString:@"" fntFile:GameFontMini];
    playersLabel.opacity = 150;
    playersLabel.anchorPoint = ccp(0, 1.0f);
    [self addChild:playersLabel z:20];
    
    pauseSprite = [CCSprite spriteWithSpriteFrameName:@"pause.png"];
    pauseSprite.opacity = 30.0f;
    [self addChild:pauseSprite z:10];

    leftJoy = [[SneakyJoystickSkinnedBase alloc] init];
    leftJoy.backgroundSprite = [ColoredCircleSprite circleWithColor:ccc4(0, 0, 0, 100) radius:64];
    leftJoy.thumbSprite = [ColoredCircleSprite circleWithColor:ccc4(0, 0, 0, 220) radius:32];
    leftJoy.joystick = [[SneakyJoystick alloc] initWithRect:CGRectMake(0,0,128,128)];
    leftJoystick = leftJoy.joystick;
    [self addChild:leftJoy z:100];
    
    rightJoy = [[SneakyJoystickSkinnedBase alloc] init];
    rightJoy.backgroundSprite = [ColoredCircleSprite circleWithColor:ccc4(0, 0, 0, 100) radius:64];
    rightJoy.thumbSprite = [ColoredCircleSprite circleWithColor:ccc4(0, 0, 0, 220) radius:32];
    rightJoy.joystick = [[SneakyJoystick alloc] initWithRect:CGRectMake(0,0,128,128)];
    rightJoystick = rightJoy.joystick;
    [self addChild:rightJoy z:100];

    [self scheduleUpdate];

    return self;
}

- (void)onEnter
{
    [super onEnter];

    weaponSprite.position = ccp(screenSize.width - 30.0f, screenSize.height - 30);
    ammoLabel.position = ccp(screenSize.width - 60.0f, screenSize.height - 30);
    ammoLabel2.position = ccp(screenSize.width - 60.0f, screenSize.height - 53);

    pauseSprite.position = ccp(160.0f, screenSize.height - 26.0f);

    healthSprite.position = ccp(110.0f, screenSize.height - 25.0f);
    healthLabel.position = ccp(120.0f, screenSize.height - 25.0f);
    
    fragSprite.position = ccp(40.0f, screenSize.height - 25.0f);
    fragLabel.position = ccp(50.0f, screenSize.height - 25.0f);
    
    timeLabel.position = ccp(screenSize.width - 40, 3);
    playersLabel.position = ccp(10.0f, screenSize.height - 50.0f);
    
    leftJoy.position = ccp(64,64);
    rightJoy.position = ccp(screenSize.width - 64, 64);
}

- (void)update:(ccTime)dt
{
    if (leftJoystick.degrees > 0) {
        self.player.moveUp = YES;
        [self.player moveAngle:leftJoystick.degrees];
    } else {
        self.player.moveUp = NO;
    }
    
    if (rightJoystick.degrees > 0) {
        [self.player moveTurretAngle:- rightJoystick.degrees - 90.0f];
        
        if (self.player.armory.selectedWeapon.isRelentless) {
            self.player.fire = YES;
        } else {
            self.player.aiming = YES;
        }
    } else {
        /* fire rocket, mine, grenade */
        if (self.player.aiming) {
            [self.player doFire];
            self.player.aiming = NO;
        }
        /* stop firing machine gun, flame thrower */
        else {
            self.player.fire = NO;
        }
    }
}

- (void)setWeapon:(GameWeapon *)aWeapon
{
    ammoLabel.string = aWeapon.label;
    
    [weaponSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"weapon_%d.png", aWeapon.type]]];
    
    if (aWeapon.hasInfiniteAmmo) {
        ammoLabel2.string = @"";
    } else {
        ammoLabel2.string = [NSString stringWithFormat:@"%i", aWeapon.ammo];
    }
}

- (void)setHealth:(int)aHealth
{
    healthLabel.string = [NSString stringWithFormat:@"%i", aHealth];
}

- (void)setFrags:(int)aFrags
{
    fragLabel.string = [NSString stringWithFormat:@"%i", aFrags];
}

- (void)setTime:(int)aSeconds
{
    int m = round(aSeconds / 60);
    int s = aSeconds % 60;
    
    timeLabel.string = [NSString stringWithFormat:@"%i:%02i", m, s];
}

#pragma mark - Player List

- (void)setPlayersList:(NSArray *)aList
{
    playersList = aList;
}

- (void)updatePlayersList
{
    if (!playersList) {
        return;
    }
    
    if (playersList.count == 1) {
        return;
    }

    NSArray *sortedArray = [playersList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        GameTank *aTank = (GameTank *)a;
        GameTank *bTank = (GameTank *)b;
        int aFrags = aTank.frags;
        int bFrags = bTank.frags;
        
        if (aFrags == bFrags) {
            return NSOrderedSame;
        } else if (aFrags < bFrags) {
            return NSOrderedDescending;
        }
        
        return NSOrderedAscending;
    }];

    NSMutableString *text = [NSMutableString stringWithString:@""];
    
    for (GameTank *p in sortedArray) {
        NSString *tankName;
        
        if ([p isKindOfClass:[GamePlayer class]]) {
            tankName = @"PLAYER";
        } else {
            tankName = GameTankLabels[p.tankIndex];
        }
        
        NSString *line = [NSString stringWithFormat:@"%d   %@\n", p.frags, tankName];
        [text appendString:line];
    }
    
    playersLabel.string = text;
}

#pragma mark - Handle touches 480x320

- (BOOL)pointInWeaponRect:(CGPoint)p
{
    p.y = screenSize.height - p.y;
    return CGRectContainsPoint(CGRectMake(screenSize.width - 128.0f, screenSize.height - 128.0f, 128.0f, 128.0f), p);
}

- (BOOL)pointInPauseButton:(CGPoint)p
{
    p.y = 320.0f - p.y;
    CGRect rect = CGRectMake(150.0f, 320.0f - 64.0f, 64.0f, 64.0f);
    return CGRectContainsPoint(rect, p);
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *allTouches = [touches allObjects];
    
    for (UITouch *touch in allTouches) {
        CGPoint p = [touch locationInView:[touch view]];
        
        if ([self pointInWeaponRect:p]) {
            [self.player nextWeapon];
        }
    }
}

@end
