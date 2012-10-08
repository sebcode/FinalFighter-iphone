
#import "GameMenuPageSettings.h"
#import "GameFont.h"
#import "GameMenuItemLabel.h"
#import "GameSoundPlayer.h"
#import "GameConstants.h"
#import "GameMusicPlayer.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>

@implementation GameMenuPageSettings

- (id)init
{
    self = [super init];
    if (!self) {
        return self;
    }
    
    soundPlayer = [GameSoundPlayer getInstance];
    musicPlayer = [GameMusicPlayer getInstance];

    CCSprite *sprite;
    sprite = [CCSprite spriteWithSpriteFrameName:@"menu_settings.png"];
    sprite.anchorPoint = ccp(0, 0);
    [self addChild:sprite];

    return self;
}

- (void)sliderActionSound:(id)sender
{
    soundPlayer.volume = soundVolSlider.value;
    [[GameSoundPlayer getInstance] play:GameSoundMenuHover];
}

- (void)sliderActionMusic:(id)sender
{
    musicPlayer.volume = musicVolSlider.value;
}

- (void)update
{
    CCDirector *director = (CCDirector *)[CCDirector sharedDirector];
    
    if (!musicVolSlider) {
        CGRect frame = CGRectMake(0.0, 0.0, 200.0, 10.0);
        UISlider *slider = [[UISlider alloc] initWithFrame:frame];
        [slider addTarget:self action:@selector(sliderActionMusic:) forControlEvents:UIControlEventValueChanged];
        [slider setBackgroundColor:[UIColor clearColor]];
        slider.minimumValue = 0.0;
        slider.maximumValue = 100.0;
        slider.continuous = YES;
        musicVolSlider = slider;
    }
    
    if ([director.view.subviews indexOfObject:musicVolSlider] == NSNotFound) {
        [director.view addSubview:musicVolSlider];
    }
    
    musicVolSlider.value = musicPlayer.volume;
    musicVolSlider.frame = CGRectMake(self.position.x + 40.0f, self.position.y + 180.0f, 225.0, 10.0);

    if (!soundVolSlider) {
        CGRect frame = CGRectMake(0.0, 0.0, 200.0, 10.0);
        UISlider *slider = [[UISlider alloc] initWithFrame:frame];
        [slider addTarget:self action:@selector(sliderActionSound:) forControlEvents:UIControlEventValueChanged];
        [slider setBackgroundColor:[UIColor clearColor]];
        slider.minimumValue = 0.0;
        slider.maximumValue = 100.0;
        slider.continuous = YES;
        soundVolSlider = slider;
    }
    
    if ([director.view.subviews indexOfObject:soundVolSlider] == NSNotFound) {
        [director.view addSubview:soundVolSlider];
    }
    
    soundVolSlider.value = soundPlayer.volume;
    soundVolSlider.frame = CGRectMake(self.position.x + 40.0f, self.position.y + 110.0f, 225.0, 10.0);
}

- (void)hide
{
    [musicVolSlider removeFromSuperview];
    [soundVolSlider removeFromSuperview];
}

@end
