
#import "GameLevelFragtemple.h"
#import "GameItem.h"

@implementation GameLevelFragtemple

- (NSString *)getFilename;
{
    return @"Fragtemple.png";
}

- (void) createCollisionMap
{
#include "Fragtemple.inc"    
}

- (void) createItems
{
#include "Fragtemple_Items.inc"
}

+ (NSString *)getLabel;
{
    return @"FRAGTEMPLE";
}

+ (NSString *)getGameCenterID;
{
    return @"fragtemple";
}

- (float)getScale
{
    return 1027.0f/719.0f;
}

- (CGSize)getSize
{
    return CGSizeMake(1027.0f, 1492.0f);
}

@end
