
#import "GameAchievement.h"
#import "GameStats.h"

@implementation GameAchievement

- (BOOL)isDone
{
    return [[GameStats getInstance] getInt:_trigger] > _triggerMin;
}

@end
