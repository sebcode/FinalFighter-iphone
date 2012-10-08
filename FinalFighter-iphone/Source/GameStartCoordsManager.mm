
#import "GameStartCoordsManager.h"
#import "GameStartCoords.h"

@implementation GameStartCoordsManager

- (id)init
{
    self = [super init];
    if (!self) {
        return self;
    }
    
    coordList = [[NSMutableArray alloc] initWithCapacity:30];
    
    return self;
}

- (void)clear
{
    [coordList removeAllObjects];
}

- (void)add:(GameStartCoords *)aCoords
{
    [coordList addObject:aCoords];
}

- (void)shuffle
{
    NSUInteger count = [coordList count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger nElements = count - i;
        NSUInteger n = (random() % nElements) + i;
        [coordList exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

- (GameStartCoords *)get
{
    /* list empty? return default coords */
    if (!coordList.count) {
        GameStartCoords *c = [[GameStartCoords alloc] initWithCoords:100.0f y:100.0f rotate:0];
        return c;
    }
    
    /* shuffle on each loopover */
    if (nextIndex == 0) {
        [self shuffle];
    }
    
    GameStartCoords *c = [coordList objectAtIndex:nextIndex];
    
    nextIndex++;
    
    if (nextIndex >= [coordList count]) {
        nextIndex = 0;
    }
    
    return c;
}

@end
