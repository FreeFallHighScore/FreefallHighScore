//
//  FFAccelerometerSample.m
//  FreefallHighscore
//
//  Created by James George on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFAccelerometerSample.h"


@implementation FFAccelerometerSample
@synthesize time;
@synthesize x;
@synthesize y;
@synthesize z;
@synthesize magnitude;    

+ (FFAccelerometerSample*) sample
{
    return [[[FFAccelerometerSample alloc] init] autorelease];
}

@end
