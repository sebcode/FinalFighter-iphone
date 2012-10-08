
#import "GameObject.h"
#import "GameUserData.h"
#import "WorldLayer.h"

@implementation GameObject

- (id)initWithLayer:(WorldLayer *)aLayer
{
    self = [super init];
    if (!self) {
        return self;
    }
    
    _layer = aLayer;
    _world = aLayer.world;
    _active = YES;
    
    return self;
}

/* actual destroy, called on destroyQueue cleanup */
- (void)doDestroy
{
    if (_sprite) {
        [_sprite removeFromParentAndCleanup:YES];
        _sprite = nil;
    }
    
    if (body) {
        GameUserData *userData = (__bridge GameUserData *)body->GetUserData();
        if (userData) {
            body->SetUserData(NULL);
            [self.layer.userDataRetain removeObject:userData];
        }
        
        _world->DestroyBody(body);
        body = nil;
    }
}

/* put into destroyQueue */
- (void)destroy
{
    if (!_layer || destroying) {
        return;
    }
    
    [_layer.destroyQueue addObject:self];
    destroying = YES;
}

- (void)activateBody
{
    changeBodyStateTo = 1;
    [_layer.changeBodyStateQueue addObject:self];
}

- (void)deactivateBody
{
    changeBodyStateTo = 2;
    [_layer.changeBodyStateQueue addObject:self];
}

/* called from changeBodyStateQueue loop */
- (void)doChangeBodyState
{
    if (!body) {
        changeBodyStateTo = 0;
        return;
    }

    if (changeBodyStateTo == 1) {
        body->SetActive(YES);
    } else if (changeBodyStateTo == 2) {
        body->SetActive(NO);
    }
    
    changeBodyStateTo = 0;
}

- (void)tick:(ccTime)dt
{
    /* abstract */
}

- (void)contact:(GameObject *)object
{
    /* abstract */
}

@end
