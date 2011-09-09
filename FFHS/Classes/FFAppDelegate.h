//
//  FFAppDelegate.h
//  FreefallHighscore
//
//  Created by Jim on 9/9/11.
//  Copyright 2011 FlightPhase. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FFYoutubeUploader;
@class FFMainViewController;

@interface FFAppDelegate : NSObject<UIApplicationDelegate> {

}
@property(nonatomic, retain) IBOutlet UIWindow* mainWindow;
@property(nonatomic, retain) FFMainViewController* mainViewController;
@property(nonatomic, retain) FFYoutubeUploader* uploader;

- (void)applicationDidFinishLaunching:(UIApplication *)application;

- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillResignActive:(UIApplication *)application;

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;

- (void)applicationSignificantTimeChange:(UIApplication *)application;

- (void)applicationWillTerminate:(UIApplication *)application;

@end
