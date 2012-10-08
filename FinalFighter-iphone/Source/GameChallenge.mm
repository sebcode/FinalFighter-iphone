
#import "GameChallenge.h"
#import "GameStats.h"
#import "GameCenterManager.h"
#import "GameLevelYerLethalMetal.h"

@implementation GameChallenge

- (id)init
{
    self = [super init];

    _levelClass = [GameLevelYerLethalMetal class];
    
    return self;
}

- (NSString *)label
{
    if (_type == GameChallengeTutorial) {
        return [NSString stringWithFormat:@"%@", GameChallengeTypeLabels[_type]];
    }
    
    NSMutableString *str = [NSMutableString stringWithFormat:@"%@ %@", GameChallengeTypeLabels[_type], [_levelClass getLabel]];
    
    if (_tier) {
        [str appendString:[NSString stringWithFormat:@" - TIER %ld", (unsigned long)_tier]];
    }
    
    return str;
}

- (NSString *)menuLabel
{
    if (_type == GameChallengeTutorial) {
        return [NSString stringWithFormat:@"%@\n", GameChallengeTypeLabels[_type]];
    }

    NSMutableString *str = [NSMutableString stringWithFormat:@"%@\n%@", GameChallengeTypeLabels[_type], [_levelClass getLabel]];

    if (_tier) {
        [str appendString:[NSString stringWithFormat:@" - TIER %ld\n", (unsigned long)_tier]];
    }
    
    [str appendString:[NSString stringWithFormat:@"FRAGLIMIT %ld - %ld %@", (unsigned long)_fragLimit, (unsigned long)_numSpawnBots, _numSpawnBots > 1 ? @"BOTS" : @"BOT"]];
    
    return str;
}

- (NSString *)id
{
    return [NSString stringWithFormat:@"%@,%ld,%@", GameChallengeTypeLabels[_type], (unsigned long)_tier, [_levelClass getLabel]];
}

- (int)menuImageIndex
{
    return [_levelClass menuImageIndex];
}

- (void)markAsDone:(NSInteger)s
{
    GameStats *stats = [GameStats getInstance];
    [stats incInt:[NSString stringWithFormat:@"victoryChallenge_%@", self.id]];
    
    NSString *timeKey = [NSString stringWithFormat:@"victoryChallengeTime_%@", self.id];
    NSInteger os = [stats getInt:timeKey];
    
    if (os == 0 || os > s) {
        [stats setInt:s forKey:timeKey];
    }

    /* Game Center */

    NSString *gcID = nil;

    if (self.type == GameChallengeTutorial) {
        gcID = @"finish_tutorial";
    }
    else if (self.type == GameChallengeDeathmatch) {
        gcID = [NSString stringWithFormat:@"finish_%@_tier%d", [_levelClass getGameCenterID], self.tier];
    }

    [[GameCenterManager sharedInstance] submitAchievement:gcID percentComplete:100.0];
}

- (BOOL)isDone
{
    return [[GameStats getInstance] getInt:[NSString stringWithFormat:@"victoryChallenge_%@", self.id]];
}

- (NSString *)doneMessage
{
    if ([self isDone]) {
        long seconds = (long)[[GameStats getInstance] getInt:[NSString stringWithFormat:@"victoryChallengeTime_%@", self.id]];
        
        if (!seconds) {
            return [NSString stringWithFormat:@"FINISHED"];        
        }
        
        int m = round(seconds / 60);
        int s = seconds % 60;
        return [NSString stringWithFormat:@"FINISHED in %i:%02i", m, s];
    }
    
    return @"";
}

@end
