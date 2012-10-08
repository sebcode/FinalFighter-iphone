
#import "GameObject.h"

enum GameDecorationType {
    kDecorationPalm1,
    kDecorationPalm2,
    numDecorations
};
typedef enum GameDecorationType GameDecorationType;

static NSString *GameDecorationSprites[] = {
    @"palm1.png",
    @"palm2.png"
};


@interface GameDecoration : GameObject

- (id)initWithPosition:(CGPoint)pos type:(GameDecorationType)aType layer:(WorldLayer *)aLayer;

@end
