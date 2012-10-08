
#import "cocos2d.h"
#import "GameObject.h"
#import "GameWeapon.h"

@interface GameAmmo : GameObject
{
    float age;
    float maxAge;
    float lethalAge;
    BOOL exploding;
    CCAnimation *explodeAnimation;
    
    BOOL _isLethal;
}

+ (GameAmmo *)ammoWithPosition:(CGPoint)aPos angle:(float)aAngle type:(GameWeaponType)aType sender:(GameObject *)aSender;
+ (void)clearCache;

- (id)initWithPosition:(CGPoint)pos angle:(float)aAngle type:(GameWeaponType)aType sender:(GameObject *)aSender;
- (void)resetWithPosition:(CGPoint)aPos angle:(float)aAngle type:(GameWeaponType)aType sender:(GameObject *)aSender resetPosition:(BOOL)aResetPosition;
- (void)explode;
- (void)increaseSenderFrags;
- (void)deactivate;

@property (readonly) int damagePoints;
@property (readonly) GameObject *sender;
@property (readonly) GameWeaponType type;
@property (readonly) BOOL isLethal;

@end
