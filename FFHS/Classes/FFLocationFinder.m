//
//  TrackLocation.m
//  FreefallHighscore
//
//  Created by mafe on 8/13/11.
//  Copyright 2011 NYU. All rights reserved.
//

#import "FFLocationFinder.h"

#define LOCATION_TIMEOUT 7


@implementation FFLocationFinder

@synthesize locationManager;
@synthesize location;
@synthesize delegate;

- (void) locationManager:(CLLocationManager *)manager
	 didUpdateToLocation:(CLLocation *)newLocation
			fromLocation:(CLLocation *)oldLocation
{
	
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0){
		return;
	}

	self.location = newLocation;
    if(delegate != nil){
        [delegate locationChanged:newLocation];
    }
    
    NSLog(@"latitude %+.6f, longitude %+.6f\n",
          newLocation.coordinate.latitude,
          newLocation.coordinate.longitude);
	
	[manager stopUpdatingLocation];
}


- (void) locationManager:(CLLocationManager *)manager 
		didFailWithError:(NSError *)error
{
	[manager stopUpdatingLocation];
}

- (void) setupLocation
{
    #if !(TARGET_IPHONE_SIMULATOR)
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        if ([CLLocationManager locationServicesEnabled] == NO) {
            [self performSelector:@selector(locationTimeout) withObject:nil afterDelay:1.5f];
        }
        else{
            self.locationManager.delegate = self; 
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = kCLDistanceFilterNone;
            [self.locationManager startUpdatingLocation];		
        }
        
    #else
        [self performSelector:@selector(locationTimeout) withObject:nil afterDelay:1.5f];
    #endif
}

- (void) locationTimeout
{
	[self.locationManager stopUpdatingLocation];
}

@end
