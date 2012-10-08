
#import "GameStartCoords.h"

@implementation GameStartCoords

- (id)initWithCoords:(float)aX y:(float)aY rotate:(float)aRotate
{
    if (self = [super init]) {
        _x = aX;
        _y = aY;
        _rotate = aRotate;
    }
    
    return self;
}

@end
