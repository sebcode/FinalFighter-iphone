
#import "WorldLayer.h"
#import "GameConstants.h"
#import "GameObject.h"
#import "GameItem.h"
#import "GameDecoration.h"

@class GameStartCoordsManager;

/* sprite index aus menu_levels.png */
static const int LEVEL_FRAGTEMPLE_IMAGE_INDEX = 0;
static const int LEVEL_YERLETHALMETAL_IMAGE_INDEX = 1;
static const int LEVEL_HAUNTEDHALLS_IMAGE_INDEX = 2;
static const int LEVEL_OVERKILLZ_IMAGE_INDEX = 3;

@interface GameLevel : GameObject
{
    b2Body *levBody;
    b2EdgeShape levBox;
    
    NSMutableArray *decorations;
    NSMutableArray *items;
    
    CGPoint lastLocation;
}

- (CGSize)getSize;
- (NSString *)getFilename;
- (void)createCollisionMap;
- (void)createItems;
- (void)registerItemWithCoords:(CGPoint)coords type:(GameItemType)aType;
- (void)registerPlayerStartCoords:(CGPoint)coords rotate:(float)rotate;
- (void)registerDecorationWithCoords:(CGPoint)coords type:(GameDecorationType)aType;

+ (NSString *)getLabel;
+ (NSString *)getGameCenterID;
+ (int)menuImageIndex;

@property (nonatomic, strong) GameStartCoordsManager *startCoordsManager;

@end
