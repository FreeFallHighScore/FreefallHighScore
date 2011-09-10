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
#import "FFLocationFinder.h"

@implementation FFAppDelegate

@synthesize mainViewController;
@synthesize uploader;
@synthesize mainWindow;
@synthesize locationFinder;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	NSLog(@"app did launch suckas");
    
    self.mainViewController = [[FFMainViewController alloc] initWithNibName:nil bundle:nil];
    [mainViewController release];
    
    //create uploader:
    self.uploader = [[FFYoutubeUploader alloc] init];
    self.uploader.delegate = self.mainViewController;
    self.uploader.toplevelController = self.mainViewController;
    [uploader release];
    
    self.locationFinder = [[FFLocationFinder alloc] init];
    self.locationFinder.delegate = self;
    [self.locationFinder setupLocation];
    [locationFinder release];
    
    self.mainViewController.uploader = self.uploader;
    self.mainWindow.rootViewController = self.mainViewController;
    [self.mainWindow makeKeyAndVisible];
    
}

- (void) switchMainView:(UIViewController*)newMainView
{
	self.mainWindow.rootViewController = newMainView;    
}

- (void) locationChanged:(CLLocation*)newLocation
{
    NSLog(@"updated location on uploader");
    self.uploader.location = newLocation;
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
