//
//  AppDelegate.h
//  FinalFighter-iphone
//
//  Created by Sebastian Volland on 08.10.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

@class LandscapeNavigationController;

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (readonly) LandscapeNavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end
