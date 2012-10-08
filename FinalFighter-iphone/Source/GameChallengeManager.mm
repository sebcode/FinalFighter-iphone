
#import "GameChallenge.h"
#import "GameChallengeManager.h"
#import "GameLevelTutorial.h"
#import "GameLevelFragtemple.h"
#import "GameLevelYerLethalMetal.h"
#import "GameLevelHauntedHalls.h"
#import "GameLevelOverkillz.h"

@implementation GameChallengeManager

static GameChallengeManager *sharedChallengeManager;

+ (GameChallengeManager *)getInstance
{
    [GameChallengeManager createInstance];
    return sharedChallengeManager;
}

+ (void)createInstance
{
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedChallengeManager = [[GameChallengeManager alloc] init];
    }
}

- (id)init
{
    self = [super init];
    if (!self) {
        return self;
    }
    
    challenges = [NSMutableArray arrayWithCapacity:30];

    [self initChallenges];
    
    return self;
}

- (void)initChallenges
{
    GameChallenge *challenge;
    
    challenge = [[GameChallenge alloc] init];
    challenge.type = GameChallengeTutorial;
    challenge.levelClass = [GameLevelTutorial class];
    [self add:challenge];
    
    /* TIER 1 */
    
    challenge = [[GameChallenge alloc] init];
    challenge.type = GameChallengeDeathmatch;
    challenge.tier = 1;
    challenge.levelClass = [GameLevelFragtemple class];
    challenge.fragLimit = 5;
    challenge.numSpawnBots = 1;
    [self add:challenge];
    
    challenge = [[GameChallenge alloc] init];
    challenge.type = GameChallengeDeathmatch;
    challenge.tier = 1;
    challenge.levelClass = [GameLevelYerLethalMetal class];
    challenge.fragLimit = 5;
    challenge.numSpawnBots = 4;
    [self add:challenge];
    
    challenge = [[GameChallenge alloc] init];
    challenge.type = GameChallengeDeathmatch;
    challenge.tier = 1;
    challenge.levelClass = [GameLevelHauntedHalls class];
    challenge.fragLimit = 5;
    challenge.numSpawnBots = 4;
    [self add:challenge];
    
    challenge = [[GameChallenge alloc] init];
    challenge.type = GameChallengeDeathmatch;
    challenge.tier = 1;
    challenge.levelClass = [GameLevelOverkillz class];
    challenge.fragLimit = 5;
    challenge.numSpawnBots = 5;
    [self add:challenge];
    
    /* TIER 2 */
    
    challenge = [[GameChallenge alloc] init];
    challenge.type = GameChallengeDeathmatch;
    challenge.tier = 2;
    challenge.levelClass = [GameLevelFragtemple class];
    challenge.fragLimit = 10;
    challenge.numSpawnBots = 2;
    [self add:challenge];
    
    challenge = [[GameChallenge alloc] init];
    challenge.type = GameChallengeDeathmatch;
    challenge.tier = 2;
    challenge.levelClass = [GameLevelYerLethalMetal class];
    challenge.fragLimit = 10;
    challenge.numSpawnBots = 6;
    [self add:challenge];
    
    challenge = [[GameChallenge alloc] init];
    challenge.type = GameChallengeDeathmatch;
    challenge.tier = 2;
    challenge.levelClass = [GameLevelHauntedHalls class];
    challenge.fragLimit = 10;
    challenge.numSpawnBots = 6;
    [self add:challenge];
    
    challenge = [[GameChallenge alloc] init];
    challenge.type = GameChallengeDeathmatch;
    challenge.tier = 2;
    challenge.levelClass = [GameLevelOverkillz class];
    challenge.fragLimit = 10;
    challenge.numSpawnBots = 8;
    [self add:challenge];
    
    /* TIER 3 */

    challenge = [[GameChallenge alloc] init];
    challenge.type = GameChallengeDeathmatch;
    challenge.tier = 3;
    challenge.levelClass = [GameLevelFragtemple class];
    challenge.fragLimit = 30;
    challenge.numSpawnBots = 5;
    [self add:challenge];
    
    challenge = [[GameChallenge alloc] init];
    challenge.type = GameChallengeDeathmatch;
    challenge.tier = 3;
    challenge.levelClass = [GameLevelYerLethalMetal class];
    challenge.fragLimit = 30;
    challenge.numSpawnBots = 8;
    [self add:challenge];
    
    challenge = [[GameChallenge alloc] init];
    challenge.type = GameChallengeDeathmatch;
    challenge.tier = 3;
    challenge.levelClass = [GameLevelHauntedHalls class];
    challenge.fragLimit = 30;
    challenge.numSpawnBots = 8;
    [self add:challenge];
    
    challenge = [[GameChallenge alloc] init];
    challenge.type = GameChallengeDeathmatch;
    challenge.tier = 3;
    challenge.levelClass = [GameLevelOverkillz class];
    challenge.fragLimit = 30;
    challenge.numSpawnBots = 10;
    [self add:challenge];
}

- (void)add:(GameChallenge *)aChallenge
{
    [challenges addObject:aChallenge];
    aChallenge.index = [challenges count] - 1;
}

- (GameChallenge *)getByIndex:(NSUInteger)aIndex
{
    return [challenges objectAtIndex:aIndex];
}

- (GameChallenge *)getById:(NSString *)aId
{
    for (GameChallenge *c in challenges) {
        if ([c.id isEqualToString:aId]) {
            return c;
        }
    }
    
    return nil;
}

- (NSUInteger)count
{
    return [challenges count];
}

- (BOOL)isLocked:(GameChallenge *)aChallenge
{
    /* tutorial ist immer unlocked */
    if (aChallenge.index == 0) {
        return NO;
    }

    /* erste challange nach tutorial ist immer unlocked */
    if (aChallenge.index == 1) {
        return NO;
    }
    
    GameChallenge *prevChallenge = [self getByIndex:aChallenge.index - 1];
    return ![prevChallenge isDone];
}

- (BOOL)allDone
{
    for (GameChallenge *c in challenges) {
        if (!c.isDone) {
            return NO;
        }
    }
    
    return YES;
}

- (GameChallenge *)bestChallenge
{
    for (GameChallenge *c in challenges) {
        if (!c.isDone) {
            return c;
        }
    }
    
    return [challenges objectAtIndex:challenges.count - 1];
}

- (void)markAllAsDone
{
    for (GameChallenge *c in challenges) {
        [c markAsDone:60];
    }
}

@end
