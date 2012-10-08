
#import "GameUserData.h"
#import "GameObject.h"

@implementation GameUserData

+ (id)userDataWithObject:(GameObject *)aObject
{
    GameUserData *userData = [[GameUserData alloc] init];
    userData.object = aObject;
    userData.callTick = YES;
    return userData;
}

+ (id)userDataWithObject:(GameObject *)aObject doTick:(BOOL)aDoTick
{
    GameUserData *userData = [[GameUserData alloc] init];
    userData.object = aObject;
    userData.callTick = aDoTick;
    return userData;
}

- (int)CheckCollision:(void *)aParameter
{
    GameUserData *userData = (__bridge GameUserData *)aParameter;
    if (!userData) {
        return 0;
    }
    
    if (userData.object.ignoreCollisionWith == _object || _object.ignoreCollisionWith == userData.object) {
        return 0;
    }
    
    return 1;
}

int CheckCollision(void *self, void *aParameter)
{
    return [(__bridge id) self CheckCollision:aParameter];
}

@end
