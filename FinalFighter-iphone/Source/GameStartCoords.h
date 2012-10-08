
@interface GameStartCoords : NSObject

- (id)initWithCoords:(float)aX y:(float)aY rotate:(float)aRotate;

@property (readonly) float x;
@property (readonly) float y;
@property (readonly) float rotate;

@end
