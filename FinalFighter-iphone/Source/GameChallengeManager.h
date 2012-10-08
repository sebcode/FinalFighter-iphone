
@class GameChallenge;

@interface GameChallengeManager : NSObject
{
    NSMutableArray *challenges;
}

+ (GameChallengeManager *)getInstance;

- (GameChallenge *)getById:(NSString *)aId;
- (GameChallenge *)getByIndex:(NSUInteger)aIndex;
- (NSUInteger)count;
- (BOOL)isLocked:(GameChallenge *)aChallenge;
- (GameChallenge *)bestChallenge;
- (BOOL)allDone;
- (void)markAllAsDone;

@end
