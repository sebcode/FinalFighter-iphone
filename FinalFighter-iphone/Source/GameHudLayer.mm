
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
#import "WorldLayer.h"
#import "GameSoundPlayer.h"
#import "GameStats.h"
#import "GameAmmo.h"
#import "GameCenterManager.h"
#import "AppDelegate.h"
#import <GameKit/GameKit.h>
#import "LandscapeNavigationController.h"

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
    timeLabel.visible = NO; // XXX
    [self addChild:timeLabel z:20];

//    playersLabel = [CCLabelBMFont labelWithString:@"" fntFile:GameFontMini];
//    playersLabel.opacity = 150;
//    playersLabel.anchorPoint = ccp(0, 1.0f);
//    [self addChild:playersLabel z:20];
    
    pauseSprite = [CCSprite spriteWithSpriteFrameName:@"pause.png"];
    pauseSprite.opacity = 30.0f;
    [self addChild:pauseSprite z:10];

    self.instructionLabel = [CCLabelBMFont labelWithString:@"" fntFile:GameFontMenuSmall];
    self.instructionLabel.alignment = kCCTextAlignmentCenter;
    [self addChild:self.instructionLabel];
    
    self.instructionLabel2 = [CCLabelBMFont labelWithString:@"" fntFile:GameFontMenuSmall];
    self.instructionLabel2.alignment = kCCTextAlignmentCenter;
    [self addChild:self.instructionLabel2];

    self.scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:GameFontMenuSmall];
    self.scoreLabel.alignment = kCCTextAlignmentCenter;
    [self addChild:self.scoreLabel];
    self.score = 0;

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
//    playersLabel.position = ccp(10.0f, screenSize.height - 50.0f);
    
    self.instructionLabel.position = ccp(screenSize.width / 2.0f, 35.0f);
    self.instructionLabel2.position = ccp(screenSize.width / 2.0f, 15.0f);
    self.scoreLabel.position = ccp(screenSize.width / 2.0f, screenSize.height - 15.0f);
    
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
    // ZZZ no playerlist in lite version
    return;
    
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

#pragma mark - Score

- (void)setScore:(int)score
{
    _score = score;
    self.scoreLabel.string = [NSString stringWithFormat:@"SCORE: %d", _score];
}

#pragma mark - Handle touches

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

#pragma mark GK Delegate Methods
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *allTouches = [touches allObjects];
    
    for (UITouch *touch in allTouches) {
        CGPoint p = [touch locationInView:[touch view]];
        
        if (gameOverSprite) {
            if (!adActive) {
                return;
            }
            
            CGPoint p2 = [gameOverSprite convertToNodeSpace:p];
            
            /* game center */
            if (CGRectContainsPoint(CGRectMake(0, 245, 200, 70), p2)) {
                [self pressGameCenter:nil];
            }
            /* new game */
            else if (CGRectContainsPoint(CGRectMake(200, 245, 200, 70), p2)) {
                [gameOverSprite removeFromParentAndCleanup:YES];
                gameOverSprite = nil;
                
                restartOnContinue = YES;            
                [self showPause];
            }
        }
        else if (adSprite) {
            if (!adActive) {
                return;
            }
            
            CGPoint p2 = [adSprite convertToNodeSpace:p];

            /* buy now */
            if (CGRectContainsPoint(CGRectMake(0, 245, 200, 70), p2)) {
                [[GameSoundPlayer getInstance] play:@"menu_hover"];
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=578148499&mt=8&uo=6"]];
            }
            /* continue */
            else if (CGRectContainsPoint(CGRectMake(200, 245, 200, 70), p2)) {
                if (restartOnContinue) {
                    [self pressRestart:nil];
                    return;
                }
            
                [[GameSoundPlayer getInstance] play:@"menu_hover"];
                
                leftJoy.position = ccp(64,64);
                rightJoy.position = ccp(screenSize.width - 64, 64);
                
                gcButtonMenu.visible = NO;
                restartButtonMenu.visible = NO;
                tutorialButtonMenu.visible = NO;

                [adSprite runAction:[CCSequence actions:
                                     [CCFadeOut actionWithDuration:0.5f],
                                     [CCCallBlock actionWithBlock:^{
                                        [self.world unpause];
                                        [adSprite removeFromParentAndCleanup:YES];
                                        adSprite = nil;
                                        adActive = NO;
                                     }],
                                     nil]];
            }
        }
        else if ([self pointInPauseButton:p]) {
            [[GameSoundPlayer getInstance] play:@"menu_hover"];
            [self showPause];
            [self.world pause];
        }
        else if ([self pointInWeaponRect:p]) {
            [self.player nextWeapon];
        }
    }
}

#pragma mark - Menu (Ad and Game over)

- (void)pressRestart:(id)sender
{
    [[GameSoundPlayer getInstance] play:@"menu_hover"];
    [GameAmmo clearCache];
    CCScene *scene = [WorldLayer scene];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)pressTutorial:(id)sender
{
    [[GameStats getInstance] setInt:0 forKey:@"tutorialDone"];
    [self pressRestart:sender];
}

- (void)pressGameCenter:(id)sender
{
    [[GameSoundPlayer getInstance] play:@"menu_hover"];
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = self;
    leaderboardViewController.category = LEADERBOARD_CATEGORY;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [[keyWindow rootViewController] presentModalViewController:leaderboardViewController animated:YES];
}

- (void)showGameOver
{
    CCSprite *s = [CCSprite spriteWithFile:@"GameOver.png"];
    s.anchorPoint = ccp(0.5, 0);
    s.position = ccp(screenSize.width / 2.0f, 0);
    s.opacity = 0;
    [self addChild:s z:500];
    gameOverSprite = s;
    
    [gameOverSprite runAction:[CCSequence actions:
                         [CCFadeIn actionWithDuration:0.5f],
                         [CCCallBlock actionWithBlock:^{
                            adActive = YES;
                            [self showScores];
                         }],
                         nil]];
    
    leftJoy.position = ccp(-10000, -10000);
    rightJoy.position = ccp(-10000, -10000);
}

- (void)saveScore
{
    int bestScore = [[GameStats getInstance] getInt:@"bestScore"];
    
    if (_score > bestScore) {
        [[GameStats getInstance] setInt:_score forKey:@"bestScore"];
        [[GameStats getInstance] synchronize];
        bestScore = _score;
    }

    [[GameCenterManager sharedInstance] reportScore:bestScore forCategory:LEADERBOARD_CATEGORY];
}

- (void)showScores
{
    [self saveScore];
    
    int bestScore = [[GameStats getInstance] getInt:@"bestScore"];

    CCLabelBMFont *l = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"SCORE:\n%d\n\nYOUR BEST:\n%d", _score, bestScore] fntFile:GameFontDefault];
    l.position = ccp(gameOverSprite.boundingBox.size.width / 2, 240);
    l.anchorPoint = ccp(0.5, 1);
    l.alignment = kCCTextAlignmentCenter;
    [gameOverSprite addChild:l];
}

- (void)showPause
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int adNum = [defaults integerForKey:@"ad"];
    if (adNum < 1 || adNum > 3) {
        adNum = 1;
    }
    
    CCSprite *s;
    CCSprite *s2;

    s = [CCSprite spriteWithFile:[NSString stringWithFormat:@"ad%d.png", adNum]];
    s.anchorPoint = ccp(0.5, 0);
    s.position = ccp(screenSize.width / 2.0f, 0);
    s.opacity = 0;
    [self addChild:s z:500];
    adSprite = s;

    CCMenuItemImage *info;
    CCMenu *menu;

    s = [CCSprite spriteWithSpriteFrameName:@"GameCenterButton.png"];
    s2 = [CCSprite spriteWithSpriteFrameName:@"GameCenterButton.png"];
    s2.color = ccRED;
    info = [CCMenuItemImage itemWithNormalSprite:s selectedSprite:s2 target:self selector:@selector(pressGameCenter:)];
    menu = [CCMenu menuWithItems:info, nil];
    menu.position = ccp(363, 284);
    menu.opacity = 0;
    [adSprite addChild:menu];
    gcButtonMenu = menu;

    s = [CCSprite spriteWithSpriteFrameName:@"restart.png"];
    s2 = [CCSprite spriteWithSpriteFrameName:@"restart.png"];
    s2.color = ccRED;
    info = [CCMenuItemImage itemWithNormalSprite:s selectedSprite:s2 target:self selector:@selector(pressRestart:)];
    menu = [CCMenu menuWithItems:info, nil];
    menu.position = ccp(313, 284);
    menu.opacity = 0;
    [adSprite addChild:menu];
    restartButtonMenu = menu;

    s = [CCSprite spriteWithSpriteFrameName:@"tutorialButton.png"];
    s2 = [CCSprite spriteWithSpriteFrameName:@"tutorialButton.png"];
    s2.color = ccRED;
    info = [CCMenuItemImage itemWithNormalSprite:s selectedSprite:s2 target:self selector:@selector(pressTutorial:)];
    menu = [CCMenu menuWithItems:info, nil];
    menu.position = ccp(253, 284);
    menu.opacity = 0;
    [adSprite addChild:menu];
    tutorialButtonMenu = menu;
    
    [adSprite runAction:[CCSequence actions:
                         [CCFadeIn actionWithDuration:0.5f],
                         [CCCallBlock actionWithBlock:^{
                            adActive = YES;
                            [gcButtonMenu runAction:[CCFadeIn actionWithDuration:0.5f]];
                            [restartButtonMenu runAction:[CCFadeIn actionWithDuration:1.0f]];
                            [tutorialButtonMenu runAction:[CCFadeIn actionWithDuration:1.5f]];
                         }],
                         nil]];
    
    leftJoy.position = ccp(-10000, -10000);
    rightJoy.position = ccp(-10000, -10000);
    
    adNum++;
    [defaults setInteger:adNum forKey:@"ad"];
}

@end
