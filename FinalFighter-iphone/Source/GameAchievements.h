
@class GameAchievement;

@interface GameAchievements : NSObject
{
    NSMutableArray *achievements;
}

+ (GameAchievements *)getInstance;

- (NSUInteger)count;
- (GameAchievement *)getByIndex:(NSUInteger)aIndex;
- (NSUInteger)percentDone;

@end
