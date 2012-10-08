
@class GameStartCoords;

@interface GameStartCoordsManager : NSObject
{
    NSMutableArray *coordList;
    int nextIndex;
}

- (void)add:(GameStartCoords *)aCoords;
- (GameStartCoords *)get;
- (void)clear;

@end
