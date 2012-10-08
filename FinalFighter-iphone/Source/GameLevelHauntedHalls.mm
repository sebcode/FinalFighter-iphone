
#import "GameLevelHauntedHalls.h"

@implementation GameLevelHauntedHalls

- (NSString *) getFilename;
{
    return @"HauntedHalls.png";
}

- (void) createCollisionMap
{
#include "HauntedHalls.inc"
}

- (void) createItems
{
#include "HauntedHalls_Items.inc"
}

+ (NSString *)getLabel;
{
    return @"HAUNTED HALLS";
}

+ (int)menuImageIndex;
{
    return LEVEL_HAUNTEDHALLS_IMAGE_INDEX;
}

+ (NSString *)getGameCenterID;
{
    return @"hh";
}

- (float)getScale
{
    return 1666.0f/1166.0f;
}

- (CGSize)getSize
{
    return CGSizeMake(1666.0f, 1468.0f);
}

@end
