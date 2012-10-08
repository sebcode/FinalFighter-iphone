
#import "GameLevelOverkillz.h"

@implementation GameLevelOverkillz

- (NSString *)getFilename;
{
    return @"Overkillz.png";
}

- (void)createCollisionMap
{
#include "Overkillz.inc"
}

- (void)createItems
{
#include "Overkillz_Items.inc"
}

+ (NSString *)getLabel;
{
    return @"OVERKILLZ";
}

+ (int)menuImageIndex;
{
    return LEVEL_OVERKILLZ_IMAGE_INDEX;
}

+ (NSString *)getGameCenterID;
{
    return @"overkillz";
}

- (float)getScale
{
    return 2500.0f/1750.0f;
}

- (CGSize)getSize
{
    return CGSizeMake(2500.0f, 1952.0f);
}

@end
