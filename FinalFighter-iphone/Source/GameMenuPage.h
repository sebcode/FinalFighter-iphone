
#import <cocos2d.h>

@class MenuLayer;
@class GameMenuItemImage;

@interface GameMenuPage : CCNode

- (void)start;
- (void)update;
- (void)hide;
- (GameMenuItemImage *)createItemWithImage:(NSString *)aImage selected:(NSString *)aImageSelected selector:(SEL)aSelector;

@property (strong) MenuLayer *delegate;

@end
