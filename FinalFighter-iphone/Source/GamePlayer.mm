
#import "GamePlayer.h"
#import "GameLevel.h"
#import "GameItem.h"
#import "GameAmmo.h"
#import "GameSoundPlayer.h"
#import "GameConstants.h"
#import "GameStats.h"
#import "GameItem.h"
#import "GameArmory.h"
#import "GameCenterManager.h"
#import "GameStartCoords.h"

@implementation GamePlayer

- (id)initWithLayer:(WorldLayer *)aLayer tank:(int)aTank
{
    self = [super initWithLayer:aLayer tank:aTank];
    if (!self) {
        return self;
    }
    
    pointerSprite = [CCSprite spriteWithSpriteFrameName:@"line.png"];
    pointerSprite.visible = NO;
    pointerSprite.anchorPoint = ccp(-0.5, 1);
    pointerSprite.scale = 1.0f;
    [_layer addChild:pointerSprite z:9];
    
    NSString *key = [NSString stringWithFormat:@"playTank%@", GameTankLabels[aTank]];
    [[GameStats getInstance] incInt:key];
    
    level = aLayer.level;
    levelSize = [level getSize];
    hudLayer = aLayer.hudLayer;
    
    [hudLayer setHealth:_health];
    [hudLayer setWeapon:_armory.selectedWeapon];
    
    _canFire = YES;
    
    return self;
}

- (id)initWithLayer:(WorldLayer *)aLayer
{
    return [self initWithLayer:aLayer tank:-1];
}

- (BOOL)switchWeapon:(GameWeaponType)aWeaponType
{
    GameWeapon *w = [self.armory getWeapon:aWeaponType];
    
    if (w == nil) {
        return NO;
    }
    
    if (self.armory.selectedWeapon == w) { /* already selected */
        [hudLayer setWeapon:w];
        return NO;
    }
    
    if (![self.armory selectWeapon:w]) {
        [[GameSoundPlayer getInstance] play:GameSoundWeaponChangeEmpty];
        return NO;
    }
    
    [[GameSoundPlayer getInstance] play:GameSoundWeaponChange];
    [hudLayer setWeapon:w];
    
    return YES;
}

- (void)nextWeapon
{
    [super nextWeapon];
    [hudLayer setWeapon:_armory.selectedWeapon];
}

- (void)prevWeapon
{
    [super prevWeapon];
    [hudLayer setWeapon:_armory.selectedWeapon];
}

- (void)tick:(ccTime)dt
{
    [super tick:dt];

    if (_exploding) {
        pointerSprite.visible = NO;
        return;
    }
    
    const b2Vec2 pos = body->GetPosition();
    float x = _layer.position.x;
    float y = _layer.position.y;
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    x = (-1 * pos.x * PTM_RATIO + (screenSize.width / 2));
    y = (-1 * pos.y * PTM_RATIO + (screenSize.height / 2));
    
    [_layer setPosition:ccp(x * WORLD_SCALE, y * WORLD_SCALE)];
    
    if (self.collectStats) {
        if (_moveUp) {
            _statMoveUp += dt;
        }        
        if (_moveDown) {
            _statMoveDown += dt;
        }
        if (_moveLeft) {
            _statMoveLeft += dt;
        }
        if (_moveRight) {
            _statMoveRight += dt;
        }
        if (_fire) {
            _statFire += dt;
        }
    }
    
    pointerSprite.visible = self.aiming && !self.exploding;
    pointerSprite.position = CGPointMake(body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO);
}

- (void)moveTurretAngle:(float)aAngle
{
    turretSprite.rotation = aAngle;
    turretShadowSprite.rotation = aAngle;
    pointerSprite.rotation = aAngle;
    
    if (self.collectStats) {
        _statMoveTurret += 1.0f;
    }
}

- (void)moveAngle:(float)aAngle
{
    body->SetTransform(body->GetPosition(), CC_DEGREES_TO_RADIANS(aAngle));
}

- (BOOL)doFire
{
    if (!self.canFire) {
        return NO;
    }
    
    GameWeapon *w = self.armory.selectedWeapon;
    [hudLayer setWeapon:w];
    
    BOOL ret = [super doFire];

    [hudLayer setWeapon:w];
    return ret;
}

- (void)repair
{
    [super repair];
    [hudLayer setHealth:_health];
}

- (void)cheat
{
    [super cheat];
    [hudLayer setHealth:_health];
}

- (void)applyDamage:(GameAmmo *)aAmmo
{
#ifdef GODMODE
    return;
#endif

    [super applyDamage:aAmmo];
    [hudLayer setHealth:_health];
}

- (void)increaseFragsByWeapon:(GameWeaponType)aType
{
    [super increaseFragsByWeapon:aType];
    [hudLayer setFrags:_frags];
    [[GameSoundPlayer getInstance] play:GameSoundFrag];
    NSUInteger totalFrags = [[GameStats getInstance] incInt:@"totalFrags"];

    if (totalFrags >= 500) {
        [[GameCenterManager sharedInstance] submitAchievement:@"frag_king" percentComplete:100.0];
    }
    
    NSString *key = [NSString stringWithFormat:@"frag with %@", GameWeaponLabels[aType]];
    NSUInteger numFragsWeapon = [[GameStats getInstance] incInt:key];
    
    [_layer incTotalFrags];
    
    if (_layer.totalFrags == 1) {
        [[GameStats getInstance] incInt:@"firstBlood"];
    }
    
    if (_layer.secondCounter <= 5) {
        [[GameStats getInstance] incInt:@"fastBlood5"];
        [[GameCenterManager sharedInstance] submitAchievement:@"fast_blood" percentComplete:100.0];
    }
    if (_layer.secondCounter <= 10) {
        [[GameStats getInstance] incInt:@"fastBlood10"];
    }
    
    fragsSinceDeath++;
    
    if (fragsSinceDeath >= 3) {
        [[GameStats getInstance] incInt:@"killingSpree3"];
    }
    if (fragsSinceDeath >= 10) {
        [[GameStats getInstance] incInt:@"killingSpree10"];
        [[GameCenterManager sharedInstance] submitAchievement:@"killing_spree" percentComplete:100.0];
    }
    if (fragsSinceDeath >= 15) {
        [[GameStats getInstance] incInt:@"killingSpree15"];
    }
    if (fragsSinceDeath >= 20) {
        [[GameStats getInstance] incInt:@"killingSpree20"];
    }
    if (fragsSinceDeath >= 30) {
        [[GameStats getInstance] incInt:@"killingSpree30"];
    }
    
    /* Game Center */
    
    if (numFragsWeapon >= 50) {
        switch (aType) {
            case kWeaponMachinegun: [[GameCenterManager sharedInstance] submitAchievement:@"frag_with_machinegun" percentComplete:100.0]; break;
            case kWeaponGrenade: [[GameCenterManager sharedInstance] submitAchievement:@"frag_with_grenades" percentComplete:100.0]; break;
            case kWeaponFlame: [[GameCenterManager sharedInstance] submitAchievement:@"frag_with_frame" percentComplete:100.0]; break; /* yes, typo... */
            case kWeaponRocket: [[GameCenterManager sharedInstance] submitAchievement:@"frag_with_rocket" percentComplete:100.0]; break;
            case kWeaponMine: [[GameCenterManager sharedInstance] submitAchievement:@"frag_with_mines" percentComplete:100.0]; break;
            default: break;
        }
    }
}

- (void)decreaseFrags
{
    [super decreaseFrags];
    [hudLayer setFrags:_frags];
}

- (void)reset
{
    [super reset];
    
    [hudLayer setHealth:_health];
    [_armory reset];
    [hudLayer setWeapon:_armory.selectedWeapon];
    fragsSinceDeath = 0;
    self.aiming = NO;
}

- (void)resetStats
{
    _statMoveLeft = 0;
    _statMoveRight = 0;
    _statMoveUp = 0;
    _statMoveDown = 0;
    _statMoveTurret = 0;
    _statFire = 0;
    _statCollectGrenade = 0;
    _statCollectFlame = 0;
    _statCollectRocket = 0;
    _statCollectMine = 0;
    _statCollectRepair = 0;
}

- (void)consumeItem:(GameItem *)aItem
{    
    [super consumeItem:aItem];
    [[GameSoundPlayer getInstance] play:GameSoundItem];
    
    if (!self.aiming) {
        if ([self switchWeapon:(GameWeaponType)aItem.type]) {
            self.fire = NO;
        }
    }
    
    NSUInteger totalCollected = [[GameStats getInstance] incInt:[NSString stringWithFormat:@"collect %@", GameItemNames[aItem.type]]];
    
    /* immer fuer achivements zaehlen (auch ohne collectStats) */
    if (aItem.type == kItemRepair) {
        _statCollectRepair++;
    }

    if (_collectStats) {
        switch ((GameWeaponType)aItem.type) {
            case kWeaponGrenade: _statCollectGrenade++; break;
            case kWeaponFlame: _statCollectFlame++; break;
            case kWeaponRocket: _statCollectRocket++; break;
            case kWeaponMine: _statCollectMine++; break;
            default: break;
        }
    }
    
    /* Game Center */
    if (totalCollected >= 50) {
        switch ((GameWeaponType)aItem.type) {
            case kWeaponGrenade: [[GameCenterManager sharedInstance] submitAchievement:@"picker_grenades" percentComplete:100.0]; break;
            case kWeaponFlame: [[GameCenterManager sharedInstance] submitAchievement:@"picker_flame" percentComplete:100.0]; break;
            case kWeaponRocket: [[GameCenterManager sharedInstance] submitAchievement:@"picker_rocket" percentComplete:100.0]; break;
            case kWeaponMine: [[GameCenterManager sharedInstance] submitAchievement:@"picker_mines" percentComplete:100.0]; break;
            default: break;
        }
    }
}

@end
