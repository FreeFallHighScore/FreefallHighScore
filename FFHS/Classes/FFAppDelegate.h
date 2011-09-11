//
//  FFAppDelegate.h
//  FreefallHighscore
//
//  Created by Jim on 9/9/11.
//  Copyright 2011 FlightPhase. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FFLocationFinder.h"

@class HJObjManager;
@class FFYoutubeUploader;
@class FFMainViewController;
@interface FFAppDelegate : NSObject<UIApplicationDelegate, FFLocationFinderDelegate> {

}

@property(nonatomic, retain) HJObjManager* imageManager;
@property(nonatomic, retain) IBOutlet UIWindow* mainWindow;
@property(nonatomic, retain) FFMainViewController* mainViewController;
@property(nonatomic, retain) FFYoutubeUploader* uploader;
@property(nonatomic, retain) FFLocationFinder* locationFinder;

- (void) switchMainView:(UIViewController*)newMainView;

- (void) locationChanged:(CLLocation*)newLocation;

- (void)applicationDidFinishLaunching:(UIApplication *)application;

- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillResignActive:(UIApplication *)application;

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;

- (void)applicationSignificantTimeChange:(UIApplication *)application;

- (void)applicationWillTerminate:(UIApplication *)application;

@end
