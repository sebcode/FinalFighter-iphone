
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
#import "GameCenterManager.h"

@implementation WorldLayer

#define TEXT_FADE_DURATION 0.3f
#define MAX_ROUNDS 10

+ (CCScene *)scene
{
    GameChallenge *c = [[GameChallenge alloc] init];
    c.numSpawnBots = 6;
    c.levelClass = [GameLevelYerLethalMetal class];
    return [self sceneWithChallenge:c tank:GameTankTypeDragster];
}

+ (CCScene *)sceneWithChallenge:(GameChallenge *)aChallenge tank:(int)aTankIndex
{
    CCScene *scene = [CCScene node];
    
    GameHudLayer *hud = [GameHudLayer node];
    [scene addChild:hud z:1000];
    
    WorldLayer *layer = [[WorldLayer alloc] initWithHUD:hud challenge:aChallenge tank:aTankIndex];
    layer.tag = 99;
    [scene addChild:layer];
    hud.world = layer;

    return scene;
}

- (id)initWithHUD:(GameHudLayer *)aHudLayer challenge:(GameChallenge *)aChallenge tank:(int)aTankIndex
{
	self = [super init];
    if (!self) {
        return self;
    }

    [GameAmmo clearCache];

    [[GameCenterManager sharedInstance] authenticateLocalUser];

    self.scale = WORLD_SCALE;
    
    [[GameMusicPlayer getInstance] playNext];

    _hudLayer = aHudLayer;

    _destroyQueue = [NSMutableArray arrayWithCapacity:100];
    _changeBodyStateQueue = [NSMutableArray arrayWithCapacity:100];
    _userDataRetain = [NSMutableArray arrayWithCapacity:100];

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

    _player = [[GamePlayer alloc] initWithLayer:self tank:aTankIndex];
    [_player reset];
    [players addObject:_player];
    
    self.hudLayer.player = self.player;
    [_hudLayer setPlayersList:players];
    [_hudLayer updatePlayersList];
    
    items = [NSMutableArray arrayWithCapacity:30];
    
    [self schedule:@selector(tick:)];
    [self schedule:@selector(secondTick:) interval:1.0f];

    [self launchLevel1];
    
	return self;
}

- (void)launchLevel1
{
    levelNum = 1;

    if ([[GameStats getInstance] getInt:@"tutorialDone"]) {
        GameStartCoords *c = [[GameStartCoords alloc] initWithCoords:756.60425 y:636.39606 rotate:90];
        [self.player resetWithStartCoords:c];
        
        [self launchLevel3];
        return;
    }
    
    self.hudLayer.scoreLabel.visible = NO;

    self.player.collectStats = YES;
    
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:@"tutorial.png"];
    s.position = ccp([CCDirector sharedDirector].winSize.width / 2.0f, [CCDirector sharedDirector].winSize.height / 2.0f);
    s.visible = YES;
    [self.hudLayer addChild:s z:100];
    tutSprite = s;

    /* create repair kits */
    GameItem *item;
    item = [[GameItem alloc] initWithPosition:ccp(1015.91528, 763.80273) type:kItemRepair layer:self];
    [items addObject:item];
    item = [[GameItem alloc] initWithPosition:ccp(501.14774, 768.28278) type:kItemRepair layer:self];
    [items addObject:item];
    
    [self.level registerPlayerStartCoords:ccp(756.60425, 636.39606) rotate:90];

    [self createPracticeEnemiesWithAutoRespawn:NO];
    
    [self.player reset];
}

- (void)createPracticeEnemiesWithAutoRespawn:(BOOL)aAutoRespawn
{
    GameEnemy *enemy;
    NSMutableArray *starts = [NSMutableArray array];
    [starts addObject:[[GameStartCoords alloc] initWithCoords:539.93689 y:891.23785 rotate:315]];
    [starts addObject:[[GameStartCoords alloc] initWithCoords:973.61346 y:887.54382 rotate:225]];
    [starts addObject:[[GameStartCoords alloc] initWithCoords:542.45187 y:629.32501 rotate:45]];
    [starts addObject:[[GameStartCoords alloc] initWithCoords:973.78705 y:628.31488 rotate:135]];
    
    [GameEnemy setLeveragedDamageFactor:2.0f];
    
    for (GameStartCoords *coords in starts) {
        GameStartCoordsManager *scm = [[GameStartCoordsManager alloc] init];
        [scm add:coords];
        
        enemy = [[GameEnemy alloc] initWithLayer:self tank:5];
        enemy.startCoordsManager = scm;
        [enemy resetWithStartCoords:coords];
        enemy.inactive = YES;
        enemy.health = 30;
        enemy.initialHealth = 30;
        enemy.autoRespawn = aAutoRespawn;
        
        if (aAutoRespawn) {
            [items addObject:enemy];
        }
    }
}

- (void)launchLevel2
{
    levelNum = 2;

    [self createPracticeEnemiesWithAutoRespawn:YES];
    
    /* create rocket launcher ammo */
    GameItem *item;
    item = [[GameItem alloc] initWithPosition:ccp(720.71423, 922.14288) type:kItemWeaponRocket layer:self];
    [items addObject:item];
    item = [[GameItem alloc] initWithPosition:ccp(785, 921.42853) type:kItemWeaponRocket layer:self];
    [items addObject:item];

    self.hudLayer.instructionLabel2.opacity = 0;
    [self.hudLayer.instructionLabel2 runAction:[CCSequence actions:
                                [CCFadeOut actionWithDuration:TEXT_FADE_DURATION],
                                [CCCallBlock actionWithBlock:^{
                                    self.hudLayer.instructionLabel2.string = @"Objective: Destroy 4 enemies with rocket launcher";
                                }],
                                [CCFadeIn actionWithDuration:TEXT_FADE_DURATION],
                                nil]];
    
}

- (void)launchLevel3
{
    levelNum = 3;
    self.player.collectStats = NO;
    [self cleanItems];

    self.hudLayer.scoreLabel.opacity = 0;
    self.hudLayer.scoreLabel.visible = YES;
    [self.hudLayer.scoreLabel runAction:[CCFadeIn actionWithDuration:TEXT_FADE_DURATION]];
    
    self.hudLayer.instructionLabel2.opacity = 0;
    self.hudLayer.instructionLabel2.string = @"Starting match in ... 3";
    [self.hudLayer.instructionLabel2 runAction:[CCSequence actions:
                                  [CCFadeIn actionWithDuration:0.1f],
                                  [CCCallBlock actionWithBlock:^{ [[GameSoundPlayer getInstance] play:@"menu_hover"]; self.hudLayer.instructionLabel2.string = @"Starting match in ... 3"; }],
                                  [CCDelayTime actionWithDuration:1.0f],
                                  [CCCallBlock actionWithBlock:^{ [[GameSoundPlayer getInstance] play:@"menu_hover"]; self.hudLayer.instructionLabel2.string = @"Starting match in ... 2"; }],
                                  [CCDelayTime actionWithDuration:1.0f],
                                  [CCCallBlock actionWithBlock:^{ [[GameSoundPlayer getInstance] play:@"menu_hover"]; self.hudLayer.instructionLabel2.string = @"Starting match in ... 1"; }],
                                  [CCDelayTime actionWithDuration:1.0f],
                                  [CCCallBlock actionWithBlock:^{ [[GameSoundPlayer getInstance] play:@"piep"]; self.hudLayer.instructionLabel2.string = @"GO"; }],
                                  [CCCallBlock actionWithBlock:^{
                                    [self.level.startCoordsManager clear];
                                    [self.level createItems];
                                    self.player.frags = 0;
                                    [self.hudLayer setFrags:self.player.frags];
                                    [GameEnemy setLeveragedDamageFactor:100.0f];
                                    [self spawnBots:self.challenge.numSpawnBots players:players excludeTankIndex:self.player.tankIndex];
                                    nextFragGoal = 5;
                                    roundCountdown = 300;
                                    [self updateRoundLabelWithFade:YES];
                                    [self updateFragcountdown];
                                  }],
                                  nil]];
}

- (NSString *)roundTimeLeft
{
    int m = round(roundCountdown / 60);
    int s = roundCountdown % 60;
    
    return [NSString stringWithFormat:@"%i:%02i", m, s];
}

- (void)updateRoundLabelWithFade:(BOOL)aWithFade
{
    int roundNum = levelNum - 2;
    
    NSString *s = [NSString stringWithFormat:@"ROUND %d of %d - %@ LEFT", roundNum, MAX_ROUNDS, self.roundTimeLeft];
    
    if (roundNum == 10) {
        s = [NSString stringWithFormat:@"FINAL ROUND - %@ LEFT", self.roundTimeLeft];
    }
    
    if ([self.hudLayer.instructionLabel.string isEqualToString:s]) {
        return;
    }
    
    if (!aWithFade) {
        self.hudLayer.instructionLabel.string = s;
        return;
    }

    [self.hudLayer.instructionLabel runAction:[CCSequence actions:
                                 [CCFadeOut actionWithDuration:TEXT_FADE_DURATION],
                                 [CCCallBlock actionWithBlock:^{ self.hudLayer.instructionLabel.string = s; }],
                                 [CCFadeIn actionWithDuration:TEXT_FADE_DURATION],
                                 nil]];
}

- (void)updateFragcountdown
{
    int roundNum = levelNum - 2;
    int fragsLeft = nextFragGoal - self.player.frags;
    NSString *s = [NSString stringWithFormat:@"%d FRAG%@ %@", fragsLeft, fragsLeft > 1 ? @"S" : @"", roundNum >= MAX_ROUNDS ? @"LEFT" : @"UNTIL NEXT ROUND"];
    
    if ([self.hudLayer.instructionLabel2.string isEqualToString:s]) {
        return;
    }
    
    [self.hudLayer.instructionLabel2 runAction:[CCSequence actions:
                                  [CCFadeOut actionWithDuration:0.5f],
                                  [CCCallBlock actionWithBlock:^{ self.hudLayer.instructionLabel2.string = s; }],
                                  [CCFadeIn actionWithDuration:0.5f],
                                  nil]];
}

- (void)fragTick
{
    [self updateRoundLabelWithFade:NO];
    [self updateFragcountdown];
}

- (void)fragGoalReached
{
    int roundNum = levelNum - 2;
    int roundBonus = (300 - roundCountdown) * self.player.frags * 10;
    self.hudLayer.score += roundBonus;
    [self.hudLayer saveScore];

    roundCountdown = 300;
    nextFragGoal += 5;
    levelNum++;
    
    [self updateRoundLabelWithFade:YES];

    [self.hudLayer.instructionLabel2 runAction:[CCSequence actions:
                                  [CCFadeOut actionWithDuration:TEXT_FADE_DURATION],
                                  [CCCallBlock actionWithBlock:^{ self.hudLayer.instructionLabel2.string = [NSString stringWithFormat:@"ROUND %d - INCREASED DIFFICULTY", levelNum - 2]; }],
                                  [CCFadeIn actionWithDuration:TEXT_FADE_DURATION],
                                  nil]];
    
    GameEnemyLevel enemyLevel = GameEnemyLevelEasy;

    if (roundNum >= MAX_ROUNDS) {
        [self pause];
        [self.hudLayer showGameOver];    
    }

    switch (roundNum) {
        case 6:
            enemyLevel = GameEnemyLevelHard;
            [GameEnemy setLeveragedDamageFactor:0.0f];
            break;
        case 5:
            enemyLevel = GameEnemyLevelMedium;
            [GameEnemy setLeveragedDamageFactor:0.0f];
            break;
        case 4:
            [GameEnemy setLeveragedDamageFactor:1.0f];
            [self pause]; // Show Ad
            [self.hudLayer showPause];
            break;
        case 3:
            [GameEnemy setLeveragedDamageFactor:3.0f];
            break;
        case 2:
            [GameEnemy setLeveragedDamageFactor:5.0f];
            break;
        default:
            break;
    }
    
    for (GameTank *tank in players) {
        if ([tank isKindOfClass:[GameEnemy class]]) {
            GameEnemy *enemy = (GameEnemy *)tank;
            [enemy setLevel:enemyLevel];
        }
    }
    
    [[GameCenterManager sharedInstance] reportScore:self.hudLayer.score forCategory:LEADERBOARD_CATEGORY];
}

- (void)cleanItems
{
    for (GameObject *item in items) {
        if ([item isKindOfClass:[GameEnemy class]]) {
            GameEnemy *enemy = (GameEnemy *)item;
            enemy.autoRespawn = NO;
            [enemy explode];
        } else {
            [item destroy];
        }
    }
    
    [items removeAllObjects];
}

- (void)spawnBots:(NSUInteger)aCount players:(NSMutableArray *)aPlayers excludeTankIndex:(NSUInteger)aExcludeTankIndex
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
        
        [e setLevel:GameEnemyLevelEasy];
        [e resetWithStartCoords:c];
        [players addObject:e];
    }
    
    [_hudLayer updatePlayersList];
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
    
    if (levelNum == 1) {
        if (tutSprite && self.secondCounter >= 3 && self.player.statMoveUp > 0.5f && self.player.statMoveTurret > 10.0f) {
            CCSprite *_sprite = tutSprite;
            CCFadeOut *fade = [CCFadeOut actionWithDuration:0.5f];
            CCCallFuncN *remove = [CCCallBlock actionWithBlock:^{
                [_sprite removeFromParentAndCleanup:YES];
                
                self.hudLayer.instructionLabel.opacity = 0;
                self.hudLayer.instructionLabel.string = @"PRACTICE MODE";
                [self.hudLayer.instructionLabel runAction:[CCSequence actions:[CCFadeIn actionWithDuration:TEXT_FADE_DURATION], nil]];
                
                self.hudLayer.instructionLabel2.opacity = 0;
                self.hudLayer.instructionLabel2.string = @"Objective: Destroy 4 enemies with machine gun";
                [self.hudLayer.instructionLabel2 runAction:[CCSequence actions:[CCFadeIn actionWithDuration:TEXT_FADE_DURATION], nil]];
            }];
            [tutSprite runAction:[CCSequence actions:fade, remove, nil]];
            tutSprite = nil;
        }
        else if (!tutSprite && self.player.frags < 4 && !self.hudLayer.instructionLabel2.numberOfRunningActions && [self.hudLayer.instructionLabel2.string hasPrefix:@"Objective"]) {
            self.hudLayer.instructionLabel2.string = [NSString stringWithFormat:@"Objective: Destroy %d enemies with machine gun", 4 - self.player.frags];
        }
        else if (self.player.frags >= 4) {
            [self launchLevel2];
        }
    }
    else if (levelNum == 2) {
        if (self.player.statKillWithRockets >= 1 && self.player.statKillWithRockets < 4) {
            self.hudLayer.instructionLabel2.string = [NSString stringWithFormat:@"Objective: Destroy %d enemies with rocket launcher", 4 - self.player.statKillWithRockets];
        }
        else if (self.player.statKillWithRockets >= 4) {
            [[GameStats getInstance] incInt:@"tutorialDone"];
            
            [self.hudLayer.instructionLabel runAction:[CCSequence actions:
                                        [CCFadeOut actionWithDuration:TEXT_FADE_DURATION],
                                        [CCCallBlock actionWithBlock:^{
                                            self.hudLayer.instructionLabel.string = @"";
                                        }],
                                        nil]];
                        
            [self launchLevel3];
        }
    }
    else if (nextFragGoal > 0 && self.player.frags >= nextFragGoal) {
        [self fragGoalReached];
        fragTicker = self.player.frags;
    }
    else if (nextFragGoal > 0 && fragTicker != self.player.frags) {
        [self fragTick];
        fragTicker = self.player.frags;
    }
    
    if (nextFragGoal > 0 && levelNum >= 3) {
        roundCountdown -= 1;
        
        if (roundCountdown <= 0) {
            [self pause];
            [self.hudLayer showGameOver];
            return;
        }
        
        [self updateRoundLabelWithFade:NO];
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

#pragma mark - Pause

- (void)pause
{
    [self pauseSchedulerAndActions];
    isPaused = YES;
}

- (void)unpause
{
    [self resumeSchedulerAndActions];
    isPaused = NO;
}

#pragma mark - Frag handling

- (void)incTotalFrags
{
    _totalFrags++;
    
    if (levelNum >= 3) {
        self.hudLayer.score += 10 * _totalFrags;
    }
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
