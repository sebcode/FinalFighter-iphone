
#import "WorldLayer.h"
#import "GameDecoration.h"

@implementation GameDecoration

- (id)initWithPosition:(CGPoint)pos type:(GameDecorationType)aType layer:(WorldLayer *)aLayer
{
    self = [super initWithLayer:aLayer];
    if (!self) {
        return self;
    }
    
    _sprite = [CCSprite spriteWithSpriteFrameName:GameDecorationSprites[aType]];
    _sprite.position = pos;
    _sprite.zOrder = 100;
    [_layer addChild:_sprite];
    
    return self;
}

@end
