//
//  TrackLocation.h
//  FreefallHighscore
//
//  Created by mafe on 8/13/11.
//  Copyright 2011 NYU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface FFTrackLocation : NSObject<CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
	CLLocation* location;
}

@property(nonatomic, retain) CLLocationManager *locationManager;  
@property(nonatomic, retain) CLLocation* location;


- (void) setupLocation;

- (void) locationTimeout;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;



@end
