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
#import "HJObjManager.h"
#import "Reachability.h"
#import "FFUtilities.h"

@implementation FFAppDelegate

@synthesize mainViewController;
@synthesize uploader;
@synthesize mainWindow;
@synthesize locationFinder;
@synthesize imageManager;
@synthesize internetReachable;
@synthesize hostReachable;
@synthesize internetAvailable;
@synthesize hostAvailable;

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
    
    // Create the object manager
	self.imageManager = [[HJObjManager alloc] initWithLoadingBufferSize:6 memCacheSize:20];
    [self.imageManager release];
    
    // Create a file cache for the object manager to use
	// A real app might do this durring startup, allowing the object manager and cache to be shared by several screens
	NSString* cacheDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/imgcache/frefall/"] ;
	HJMOFileCache* fileCache = [[[HJMOFileCache alloc] initWithRootPath:cacheDirectory] autorelease];
	self.imageManager.fileCache = fileCache;
    
    // Have the file cache trim itself down to a size & age limit, so it doesn't grow forever
	fileCache.fileCountLimit = 100;
	fileCache.fileAgeLimit = 60*60*24*7; //1 week
	[fileCache trimCacheUsingBackgroundThread];
    
    self.mainViewController.uploader = self.uploader;
    self.mainWindow.rootViewController = self.mainViewController;
    [self.mainWindow makeKeyAndVisible];
 
    //check terms
    [self performSelector:@selector(acceptTerms) withObject:nil afterDelay:1.0];
    
    
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(checkNetworkStatus:) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    
    self.internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    self.hostReachable = [Reachability reachabilityWithHostName: @"www.freefallhighscore.com"];
    [hostReachable startNotifier];
 
}

- (void) acceptTerms
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL alreadyAccepted = [defaults boolForKey:@"TermsAccepted"];
    if(!alreadyAccepted){
        NSString* messageString = @"This application is intended for capturing and sharing videos based on the device's accelerometer.\n\nWe recommend that it is only used over soft surfaces or while enclosed in a protective casing.\n\nIn no event will the application developers be held responsible for any damage that arise from the use of this application.\n\nIf you agree press accept or exit the application.";
        UIAlertView* terms = [[[UIAlertView alloc] initWithTitle:@"Terms" 
                                                         message:messageString
                                                        delegate:nil 
                                               cancelButtonTitle:@"Accept" 
                                                    otherButtonTitles:nil] autorelease]; 
        [terms show];
        [defaults setBool:YES forKey:@"TermsAccepted"];
        [defaults synchronize];
    }
}

    
- (void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus){
        case NotReachable:
            ShowAlert(@"Network Required", @"You'll need to connect to the network to submit or watch any videos");
            NSLog(@"The internet is down.");
            self.internetAvailable = NO;
            break;
        case ReachableViaWiFi:
            NSLog(@"The internet is working via WIFI.");
            self.internetAvailable = YES;
            break;
        case ReachableViaWWAN:
            NSLog(@"The internet is working via WWAN.");
            self.internetAvailable = YES;	            
    }
    
    NetworkStatus hostStatus = [self.hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
            NSLog(@"A gateway to the host server is down.");
            self.hostAvailable = NO;            
            break;
        case ReachableViaWiFi:
            NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostAvailable = YES;
            break;
        case ReachableViaWWAN:
            NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostAvailable = YES;
            break;            
    }
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
    [self.mainViewController cancelRecording:self];
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
    [self.mainViewController applicationWillTerminate];
}

@end
