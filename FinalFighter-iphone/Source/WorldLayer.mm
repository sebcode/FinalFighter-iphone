
#import "GameSoundPlayer.h"
#import "WorldLayer.h"
#import "GameHudLayer.h"
#import "GameLevel.h"
#import "GameObject.h"
#import "GameUserData.h"
#import "GameTank.h"
#import "GamePlayer.h"
#import "GameEnemy.h"
#import "GameLevelYerLethalMetal.h"
#import "GameItem.h"
#import "GameConstants.h"
#import "GameFont.h"
#import "GameStats.h"
#import "GameChallenge.h"
#import "GameMusicPlayer.h"
#import "GameStartCoords.h"
#import "GameStartCoordsManager.h"
#import "GameArmory.h"
#import "GameAmmo.h"
#import "GameLevelTutorial.h"
#import "GameLevelFragtemple.h"
#import "GameLevelHauntedHalls.h"
#import "MenuLayer.h"
#import "PauseLayer.h"
#import "GameTutorialLayer.h"
#import "GameLevelOverkillz.h"

@implementation WorldLayer

#ifndef PRODUCTION_BUILD
+ (CCScene *)scene
{
    return [self sceneWithLevel:[GameLevelTutorial class] tank:0];
}
#endif

#ifndef PRODUCTION_BUILD
+ (CCScene *)sceneWithLevel:(Class)aLevelClass tank:(int)aTankIndex
{
    GameChallenge *c = [[GameChallenge alloc] init];
    c.fragLimit = 200;
    c.numSpawnBots = 5;
    c.levelClass = aLevelClass;
    return [self sceneWithChallenge:c tank:aTankIndex];
}
#endif

+ (CCScene *)sceneWithChallenge:(GameChallenge *)aChallenge tank:(int)aTankIndex
{
    CCScene *scene = [CCScene node];
    
    GameHudLayer *hud = [GameHudLayer node];
    [scene addChild:hud z:1000];
    
    GameTutorialLayer *tutLayer = nil;
    if (aChallenge.levelClass == [GameLevelTutorial class]) {
        tutLayer = [GameTutorialLayer node];
        [scene addChild:tutLayer z:1500];
    }

    WorldLayer *layer = [[WorldLayer alloc] initWithHUD:hud challenge:aChallenge tank:aTankIndex];
    layer.tag = 99;
    layer.tutorialLayer = tutLayer;
    [scene addChild:layer];

    if (tutLayer) {
        tutLayer.worldLayer = layer;
    }
    
    return scene;
}

- (id)initWithHUD:(GameHudLayer *)aHudLayer challenge:(GameChallenge *)aChallenge tank:(int)aTankIndex
{
	self = [super init];
    if (!self) {
        return self;
    }

    [GameAmmo clearCache];

    self.scale = WORLD_SCALE;
    
    [[GameMusicPlayer getInstance] playNext];

    _hudLayer = aHudLayer;

    _destroyQueue = [NSMutableArray arrayWithCapacity:100];
    _changeBodyStateQueue = [NSMutableArray arrayWithCapacity:100];
    _userDataRetain = [NSMutableArray arrayWithCapacity:100];

    self.isTouchEnabled = YES;

    b2Vec2 gravity;
    gravity.Set(0.0f, 0.0f);
    _world = new b2World(gravity);
    _world->SetContinuousPhysics(true);

#ifdef WIREFRAME
    m_debugDraw = new GLESDebugDraw(PTM_RATIO);
    world->SetDebugDraw(m_debugDraw);
    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    flags += b2Draw::e_jointBit;
    flags += b2Draw::e_aabbBit;
    flags += b2Draw::e_pairBit;
    flags += b2Draw::e_centerOfMassBit;
    m_debugDraw->SetFlags(flags);
#endif

    contactListener = new GameContactListener();
    _world->SetContactListener(contactListener);
    
    players = [[NSMutableArray alloc] initWithCapacity:30];
    
    _challenge = aChallenge;
    _level = [[aChallenge.levelClass alloc] initWithLayer:self];

    [self spawnBots:_challenge.numSpawnBots players:players excludeTankIndex:aTankIndex tier:_challenge.tier];
    
    _player = [[GamePlayer alloc] initWithLayer:self tank:aTankIndex];
    [_player reset];
    [players addObject:_player];
    
    self.hudLayer.player = self.player;
    [_hudLayer setPlayersList:players];
    [_hudLayer updatePlayersList];
    
    if (_tutorialLayer) {
        _player.collectStats = YES;
    }

    [self schedule: @selector(tick:)];
    [self schedule: @selector(secondTick:) interval:1.0f];

	return self;
}

- (void)spawnBots:(NSUInteger)aCount players:(NSMutableArray *)aPlayers excludeTankIndex:(NSUInteger)aExcludeTankIndex tier:(NSUInteger)aTier
{
    /* create tank index array */
    NSMutableArray *tankIndexList = [NSMutableArray arrayWithCapacity:numTanks - 1];
    for (NSUInteger i = 0; i < numTanks - 1; i++) {
        if (i != aExcludeTankIndex) {
            [tankIndexList addObject:[NSNumber numberWithInteger:i]];
        }
    }
    /* shuffle tank index array */
    NSUInteger count = [tankIndexList count];
    for (NSUInteger i = 0; i < count; ++i) {
        unsigned long nElements = count - i;
        unsigned long n = (random() % nElements) + i;
        [tankIndexList exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    /* spawn bots */
    for (NSUInteger i = 0; i < aCount; i++) {
        int botTankIndex = 0;
        
        if (i > tankIndexList.count - 1) {
            botTankIndex = 0;
        } else {
            botTankIndex = (int)[(NSNumber *)[tankIndexList objectAtIndex:i] integerValue];
        }
        
        GameStartCoords *c = [_level.startCoordsManager get];
        GameEnemy *e = [[GameEnemy alloc] initWithLayer:self tank:botTankIndex];
        
        switch (aTier) {
            case 1:
                [e setLevel:GameEnemyLevelEasy];
                break;
            case 2:
                [e setLevel:GameEnemyLevelMedium];
                break;
            default:
            case 3:
                [e setLevel:GameEnemyLevelHard];
                break;
        }
        
        [e resetWithStartCoords:c];
        [players addObject:e];
    }
}

#ifdef DEBUG
- (void)draw
{
    [super draw];
    
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
    kmGLPushMatrix();
    _world->DrawDebugData();
    kmGLPopMatrix();
}
#endif

- (void)secondTick:(ccTime)dt
{
    [_hudLayer setTime:++_secondCounter];
    
    if (_tutorialLayer) {
        [_tutorialLayer secondTick:dt];
    }
}

- (void)tick:(ccTime)dt
{
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	_world->Step(dt, velocityIterations, positionIterations);
	
	for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext()) {
		if (b->GetUserData() == NULL) {
            continue;
        }
        
        GameUserData *userData = (__bridge GameUserData *)b->GetUserData();
        if (userData && userData.callTick) {
            GameObject *o = userData.object;
            if (o.active) {
                [o tick:dt];
            }
        }
	}
    
    std::vector<GameContact>::iterator pos;
    for (pos = contactListener->_contacts.begin(); pos != contactListener->_contacts.end(); ++pos) {
        GameContact contact = *pos;
        
        b2Body *bodyA = contact.bodyA;
        if (!bodyA) {
            continue;
        }
        b2Body *bodyB = contact.bodyB;
        if (!bodyB) {
            continue;
        }
        
        if (bodyA == bodyB) {
            continue;
        }
        
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            GameUserData *userData1 = (__bridge GameUserData *)bodyA->GetUserData();
            GameUserData *userData2 = (__bridge GameUserData *)bodyB->GetUserData();
            
            GameObject *o1 = userData1.object;
            GameObject *o2 = userData2.object;
            
            b2Filter filterA = contact.fixtureA->GetFilterData();
            b2Filter filterB = contact.fixtureB->GetFilterData();
            if (filterA.categoryBits == catTankSensor) {
                GameTank *tank = (GameTank *)userData1.object;
                [tank sensorContact:o2 begin:contact.begin fixture:contact.fixtureA];
                continue;
            }
            if (filterB.categoryBits == catTankSensor) {
                GameTank *tank = (GameTank *)userData2.object;
                [tank sensorContact:o1 begin:contact.begin fixture:contact.fixtureB];
                continue;
            }
            
            if (contact.begin) {
                [o1 contact:o2];
                [o2 contact:o1];
            }
        }
    }
    
    contactListener->_contacts.clear();

    for (GameObject *o in _changeBodyStateQueue) {
        [o doChangeBodyState];
    }
    [_changeBodyStateQueue removeAllObjects];

    for (GameObject *o in _destroyQueue) {
        [o doDestroy];
    }
    [_destroyQueue removeAllObjects];
}

#pragma mark - Scene navigation

- (void)showMenu
{
    [[CCDirector sharedDirector] pushScene:[PauseLayer scene]];
}

- (void)handleContinue
{
    if (fragLimitReached) { // exit to menu if fraglimit is reached
        [[CCDirector sharedDirector] popScene];
    }
    else if (_tutorialLayer) { // continue in tutorial
        [_tutorialLayer playerReturn];
    }
}

#pragma mark - Handle touches

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *allTouches = [touches allObjects];
    
    for (UITouch *touch in allTouches) {
        if (touch.tapCount > 1) {
            [self handleContinue];
            continue;
        }
        
        CGPoint p = [touch locationInView:[touch view]];
        if ([self pointInPauseButton:p]) {
            [self showMenu];
        }
    }
}

- (BOOL)pointInPauseButton:(CGPoint)p
{
    p.y = 320.0f - p.y;
    CGRect rect = CGRectMake(150.0f, 320.0f - 64.0f, 64.0f, 64.0f);
    return CGRectContainsPoint(rect, p);
}

#pragma mark - Frag handling

- (void)incTotalFrags
{
    _totalFrags++;
}

- (void)checkFragLimit:(GameTank *)aTank
{
    if (fragLimitReached) {
        return;
    }

    if (_challenge.fragLimit == 0) {
        return;
    }

    if (aTank.frags < _challenge.fragLimit) {
        return;
    }
    
    for (GameTank *tank in players) {
        if ([tank isKindOfClass:[GameEnemy class]]) {
            GameEnemy *enemy = (GameEnemy *)tank;
            enemy.friendly = YES;
        }
        
        if ([tank isKindOfClass:[GamePlayer class]]) {
            GamePlayer *aPlayer = (GamePlayer *)tank;
            aPlayer.canFire = NO;
        }
    }
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;

    NSString *text1;
    NSString *text2;
    
    if ([aTank isKindOfClass:[GamePlayer class]]) {
        text1 = @"VICTORY";
        text2 = [NSString stringWithFormat:@"You have won the match with %ld frags\n\nDOUBLE TAP to exit", (unsigned long)_challenge.fragLimit];
        
        [[GameStats getInstance] incInt:@"victoryCount"];        
        [_challenge markAsDone:_secondCounter];
        
        if (_player.statCollectRepair == 0) {
            [[GameStats getInstance] incInt:@"finishWithoutRepair"];
            [[GameStats getInstance] incInt:[NSString stringWithFormat:@"finishWithoutRepairTier%ld", (unsigned long)_challenge.tier]];
            [[GameCenterManager sharedInstance] submitAchievement:[NSString stringWithFormat:@"finish_norepair_tier%ld", (unsigned long)_challenge.tier] percentComplete:100.0];
        }
        
        if (_secondCounter <= (5 * 60)) {
            [[GameStats getInstance] incInt:@"finishFast5"];
            [[GameStats getInstance] incInt:[NSString stringWithFormat:@"finishFast5Tier%ld", (unsigned long)_challenge.tier]];
            [[GameCenterManager sharedInstance] submitAchievement:[NSString stringWithFormat:@"finish_fast_tier%ld", (unsigned long)_challenge.tier] percentComplete:100.0];
        }
    } else {
        NSString *tankLabel = GameTankLabels[aTank.tankIndex];
        text1 = @"DEFEAT";
        text2 = [NSString stringWithFormat:@"%@ wins the match with %ld frags\n\nDOUBLE TAP to exit", tankLabel, (unsigned long)_challenge.fragLimit];
        
        [[GameStats getInstance] incInt:@"defeatCount"];
    }

    CCLabelBMFont *l;
    l = [CCLabelBMFont labelWithString:text1 fntFile:GameFontBig];
    l.opacity = 200.0f;
    l.anchorPoint = ccp(0, 1.0f);
    l.anchorPoint = ccp(0.5f, 0.5f);
    l.position = ccp(screenSize.width / 2.0f, screenSize.height / 2.0f + 50.0f);
    [_hudLayer addChild:l z:20];
    
    CCLabelBMFont *l2;
    l2 = [CCLabelBMFont labelWithString:text2 fntFile:GameFontDefault];
    l2.opacity = 200.0f;
    l2.anchorPoint = ccp(0, 1.0f);
    l2.anchorPoint = ccp(0.5f, 0.5f);
    l2.position = ccp(screenSize.width / 2.0f, screenSize.height / 2.0f - 50.0f);
    l2.alignment = kCCTextAlignmentCenter;
    [_hudLayer addChild:l2 z:20];
    
    fragLimitReached = YES;
    
    [[GameStats getInstance] synchronize];
}

#pragma mark - Helper

- (id)createUserDataWithObject:(GameObject *)aObject
{
    GameUserData *userData = [GameUserData userDataWithObject:aObject];
    [_userDataRetain addObject:userData];
    return userData;
}

- (id)createUserDataWithObject:(GameObject *)aObject doTick:(BOOL)aDoTick
{
    GameUserData *userData = [GameUserData userDataWithObject:aObject doTick:aDoTick];
    [_userDataRetain addObject:userData];
    return userData;
}

@end
