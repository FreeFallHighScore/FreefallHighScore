//
//  FFAppDelegate.m
//  FreefallHighscore
//
//  Created by Jim on 9/9/11.
//  Copyright 2011 FlightPhase. All rights reserved.
//

#import "FFAppDelegate.h"
#import "FFMainViewController.h"
#import "FFYoutubeUploader.h"

@implementation FFAppDelegate
@synthesize mainViewController;
@synthesize uploader;
@synthesize mainWindow;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	NSLog(@"app did launch suckas");
    
    self.mainViewController = [[FFMainViewController alloc] initWithNibName:nil bundle:nil];
    self.mainWindow.rootViewController = self.mainViewController;
    [self.mainWindow makeKeyAndVisible];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
	NSLog(@"activating");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	NSLog(@"Deactivating");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{

}

- (void)applicationSignificantTimeChange:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
 	NSLog(@"closing... save the assit if you can..");   
}

@end
