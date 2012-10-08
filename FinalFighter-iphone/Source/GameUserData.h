
#import "GameUserDataCppInterface.h"

@class GameObject;

@interface GameUserData : NSObject

@property (nonatomic, strong) GameObject *object;
@property (readwrite) int type;
@property (readwrite) BOOL callTick;

+ (id)userDataWithObject:(GameObject *)aObject;
+ (id)userDataWithObject:(GameObject *)aObject doTick:(BOOL)aDoTick;

- (int)CheckCollision:(void *)aParameter;

@end
