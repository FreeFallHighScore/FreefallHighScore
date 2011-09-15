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
@class Reachability;

@interface FFAppDelegate : NSObject<UIApplicationDelegate, FFLocationFinderDelegate> {

}

@property(nonatomic, retain) IBOutlet UIWindow* mainWindow;

@property(nonatomic, retain) HJObjManager* imageManager;
@property(nonatomic, retain) FFMainViewController* mainViewController;
@property(nonatomic, retain) FFYoutubeUploader* uploader;
@property(nonatomic, retain) FFLocationFinder* locationFinder;

@property(nonatomic, retain) Reachability* internetReachable;
@property(nonatomic, retain) Reachability* hostReachable;

@property(nonatomic, readwrite) BOOL internetAvailable;
@property(nonatomic, readwrite) BOOL hostAvailable;

- (void) switchMainView:(UIViewController*)newMainView;

- (void) locationChanged:(CLLocation*)newLocation;

- (void)applicationDidFinishLaunching:(UIApplication *)application;

- (void)applicationDidBecomeActive:(UIApplication *)application;

- (void)applicationWillResignActive:(UIApplication *)application;

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;

- (void)applicationSignificantTimeChange:(UIApplication *)application;

- (void)applicationWillTerminate:(UIApplication *)application;

- (void) acceptTerms;

@end
