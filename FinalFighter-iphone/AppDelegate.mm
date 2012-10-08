//
//  AppDelegate.mm
//  FinalFighter-iphone
//
//  Created by Sebastian Volland on 08.10.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"
#import "AppDelegate.h"
#import "MenuLayer.h"
#import "WorldLayer.h"
#import "GameLevelTutorial.h"
#import "GameLevelFragtemple.h"
#import "GameLevelYerLethalMetal.h"
#import "GameDebug.h"
#import "GameMusicPlayer.h"
#import "GameSoundPlayer.h"
#import "GameStats.h"
#import "GameChallengeManager.h"
#import "LandscapeNavigationController.h"

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//#if DEBUG
// ****************************
//    /* CHEAT FOR DEBUG */
//    GameChallengeManager *gcm = [GameChallengeManager getInstance];
//    [gcm markAllAsDone];
// ****************************
//    [[GameCenterManager sharedInstance] resetAchievements];
// ****************************
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
// ****************************
//#endif

	// Create the main window
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [self startGame];

#ifndef DEBUG
#if !(TARGET_IPHONE_SIMULATOR)
    /* splash screen laenger anzeigen */
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [NSThread sleepForTimeInterval:1.0];
    }
#endif
#endif

    return YES;
}

- (void)startGame
{
	CGRect bounds = [_window bounds];
    
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:bounds
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    
	// Enable multiple touches
	[glView setMultipleTouchEnabled:YES];
    _director = (CCDirectorIOS*) [CCDirector sharedDirector];
	_director.wantsFullScreenLayout = YES;
    
#ifdef DISPLAY_STATS
	[_director setDisplayStats:YES];
#endif
    
	[_director setAnimationInterval:1.0/60];
    [_director setView:glView];
    [glView setMultipleTouchEnabled:YES];
    [_director setDelegate:self];
    [_director setProjection:kCCDirectorProjection2D];
	[_director enableRetinaDisplay:NO];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
    
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    [self readUserDefaults];
    
    [GameMusicPlayer getInstance];
    [GameSoundPlayer getInstance];
    
    GameStats *stats = [GameStats getInstance];
    [stats incInt:@"startups"];
    
	_navController = [[LandscapeNavigationController alloc] initWithRootViewController:_director];
	_navController.navigationBarHidden = YES;
    [_window setRootViewController:_navController];
    [_window makeKeyAndVisible];
    
    CCScene *scene = START_SCENE;
	[_director pushScene: scene];
}

- (void)readUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *def = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInt:100], @"SoundVolume",
                         [NSNumber numberWithInt:100], @"MusicVolume",
                         nil];
    
    [defaults registerDefaults:def];    
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	if ([_navController visibleViewController] == _director) {
		[_director pause];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if ([_navController visibleViewController] == _director) {
        [_director resume];
    }
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
    if ([_navController visibleViewController] == _director) {
        [_director stopAnimation];
    }
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
    if ([_navController visibleViewController] == _director) {
        [_director startAnimation];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    CC_DIRECTOR_END();
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[CCDirector sharedDirector] purgeCachedData];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application
{
    [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
