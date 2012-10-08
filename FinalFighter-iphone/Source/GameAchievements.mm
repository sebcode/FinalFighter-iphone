
#import "GameChallenge.h"
#import "GameAchievement.h"
#import "GameAchievements.h"
#import "GameChallengeManager.h"
#import "GameItem.h"
#import "GameWeapon.h"

@implementation GameAchievements

static GameAchievements *sharedGameAchievements;

+ (GameAchievements *)getInstance
{
    [GameAchievements createInstance];
    
    return sharedGameAchievements;
}

+ (void)createInstance
{
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedGameAchievements = [[GameAchievements alloc] init];
    }
}

- (id)init
{
    self = [super init];
    if (!self) {
        return self;
    }
    
    achievements = [NSMutableArray arrayWithCapacity:300];
    
    [self initAchievements];
    
    return self;
}

- (void)add:(GameAchievement *)aAchievement
{
    [achievements addObject:aAchievement];
}

- (NSUInteger)count
{
    return [achievements count];
}

- (GameChallenge *)getByIndex:(NSUInteger)aIndex
{
    return [achievements objectAtIndex:aIndex];
}

- (void)initAchievements
{
    GameAchievement *a;

    /* finish-achievements for all challenges */
    
    GameChallengeManager *cm = [GameChallengeManager getInstance];
    
    for (int i = 0; i < cm.count; i++) {
        GameChallenge *c = [cm getByIndex:i];
        a = [[GameAchievement alloc] init];
        a.label = [NSString stringWithFormat:@"Finish %@", c.label];
        a.trigger = [NSString stringWithFormat:@"victoryChallenge_%@", c.id];
        [self add:a];
    }

    /* collect-achivements */
    
    for (int i = 1; i < numItems; i++) {
        a = [[GameAchievement alloc] init];
        a.label = [NSString stringWithFormat:@"Collect 10x %@", GameItemNames[i]];
        a.trigger = [NSString stringWithFormat:@"collect %@", GameItemNames[i]];
        a.triggerMin = 10;
        [self add:a];
    }
    for (int i = 1; i < numItems; i++) {
        a = [[GameAchievement alloc] init];
        a.label = [NSString stringWithFormat:@"Collect 50x %@", GameItemNames[i]];
        a.trigger = [NSString stringWithFormat:@"collect %@", GameItemNames[i]];
        a.triggerMin = 50;
        [self add:a];
    }
    for (int i = 1; i < numItems; i++) {
        a = [[GameAchievement alloc] init];
        a.label = [NSString stringWithFormat:@"Collect 100x %@", GameItemNames[i]];
        a.trigger = [NSString stringWithFormat:@"collect %@", GameItemNames[i]];
        a.triggerMin = 100;
        [self add:a];
    }

    /* frag with achivements */
    
    for (int i = 0; i < numWeapons; i++) {
        a = [[GameAchievement alloc] init];
        a.label = [NSString stringWithFormat:@"Frag 10x with %@", GameWeaponLabels[i]];
        a.trigger = [NSString stringWithFormat:@"frag with %@", GameWeaponLabels[i]];
        a.triggerMin = 10;
        [self add:a];
    }
    for (int i = 0; i < numWeapons; i++) {
        a = [[GameAchievement alloc] init];
        a.label = [NSString stringWithFormat:@"Frag 50x with %@", GameWeaponLabels[i]];
        a.trigger = [NSString stringWithFormat:@"frag with %@", GameWeaponLabels[i]];
        a.triggerMin = 50;
        [self add:a];
    }
    for (int i = 0; i < numWeapons; i++) {
        a = [[GameAchievement alloc] init];
        a.label = [NSString stringWithFormat:@"Frag 100x with %@", GameWeaponLabels[i]];
        a.trigger = [NSString stringWithFormat:@"frag with %@", GameWeaponLabels[i]];
        a.triggerMin = 100;
        [self add:a];
    }
    
    /* first blood */
    
    NSArray *firstBloodLevels = [NSArray arrayWithObjects:[NSNumber numberWithInt:3], [NSNumber numberWithInt:10], [NSNumber numberWithInt:20], [NSNumber numberWithInt:30], nil];
    
    for (NSNumber *n in firstBloodLevels) {
        a = [[GameAchievement alloc] init];
        a.label = [NSString stringWithFormat:@"Be %ldx the first one to kill opponent", (unsigned long)n.integerValue];
        a.trigger = @"firstBlood";
        a.triggerMin = n.integerValue;
        [self add:a];
    }
    
    /* total frags */
    
    NSArray *totalFragsLevels = [NSArray arrayWithObjects:[NSNumber numberWithInt:10], [NSNumber numberWithInt:100], [NSNumber numberWithInt:200], [NSNumber numberWithInt:500], nil];
    
    for (NSNumber *n in totalFragsLevels) {
        a = [[GameAchievement alloc] init];
        a.label = [NSString stringWithFormat:@"Reach %ld total frags", (unsigned long)n.integerValue];
        a.trigger = @"totalFrags";
        a.triggerMin = n.integerValue;
        [self add:a];
    }
    
    /* killing spree */

    NSArray *killingSpreeLevels = [NSArray arrayWithObjects:[NSNumber numberWithInt:3], [NSNumber numberWithInt:10], [NSNumber numberWithInt:15], [NSNumber numberWithInt:20], [NSNumber numberWithInt:30], nil];
    
    for (NSNumber *n in killingSpreeLevels) {
        a = [[GameAchievement alloc] init];
        a.label = [NSString stringWithFormat:@"Frag %ldx in a row without dying", (unsigned long)n.integerValue];
        a.trigger = [NSString stringWithFormat:@"killingSpree%ld", (unsigned long)n.integerValue];
        [self add:a];
    }
    
    /* fast bloods */
    
    a = [[GameAchievement alloc] init];
    a.label = @"Frag opponent in first 10s of game";
    a.trigger = @"fastBlood10";
    [self add:a];
    
    a = [[GameAchievement alloc] init];
    a.label = @"Frag opponent in first 5s of game";
    a.trigger = @"fastBlood5";
    [self add:a];
    
    /* finishWithoutRepair */

    NSArray *finishWithoutRepairLevels = [NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:5], [NSNumber numberWithInt:10], nil];
    
    for (NSNumber *n in finishWithoutRepairLevels) {
        a = [[GameAchievement alloc] init];
        a.label = [NSString stringWithFormat:@"Finish %ld games without collecting health", (unsigned long)n.integerValue];
        a.trigger = @"finishWithoutRepair";
        a.triggerMin = n.integerValue;
        [self add:a];
    }

    NSArray *tiers = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], nil];
    
    for (NSNumber *n in tiers) {
        a = [[GameAchievement alloc] init];
        a.label = [NSString stringWithFormat:@"Finish Tier %ld game without collecting health", (unsigned long)n.integerValue];
        a.trigger = [NSString stringWithFormat:@"finishWithoutRepairTier%ld", (unsigned long)n.integerValue];
        [self add:a];
    }
    
    /* finish fast */
    
    for (NSNumber *n in tiers) {
        a = [[GameAchievement alloc] init];
        a.label = [NSString stringWithFormat:@"Finish Tier %ld game in less than 5 minutes", (unsigned long)n.integerValue];
        a.trigger = [NSString stringWithFormat:@"finishFast5Tier%ld", (unsigned long)n.integerValue];
        [self add:a];
    }
}

- (NSUInteger)percentDone
{
    NSUInteger doneCount = 0;
    
    for (GameAchievement *a in achievements) {
        if (a.isDone) {
            doneCount++;
        }
    }
    
    return (doneCount * 100) / achievements.count;
}

@end
