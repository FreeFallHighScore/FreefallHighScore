//
//  TrackLocation.m
//  FreefallHighscore
//
//  Created by mafe on 8/13/11.
//  Copyright 2011 NYU. All rights reserved.
//

#import "FFTrackLocation.h"

#define LOCATION_TIMEOUT 7


@implementation FFTrackLocation

@synthesize locationManager;
@synthesize location;

- (void) locationManager:(CLLocationManager *)manager
	 didUpdateToLocation:(CLLocation *)newLocation
			fromLocation:(CLLocation *)oldLocation
{
	
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0){
		return;
	}

	self.location = newLocation;
   
   
    NSLog(@"latitude %+.6f, longitude %+.6f\n",
          newLocation.coordinate.latitude,
          newLocation.coordinate.longitude);
	
	[manager stopUpdatingLocation];
}


- (void) locationManager:(CLLocationManager *)manager 
		didFailWithError:(NSError *)error
{
	[manager stopUpdatingLocation];
	//[self selectPlate:NO];	
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
