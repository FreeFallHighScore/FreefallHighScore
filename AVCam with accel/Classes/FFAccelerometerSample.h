//
//  FFAccelerometerSample.h
//  FreefallHighscore
//
//  Created by James George on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FFAccelerometerSample : NSObject {
    NSTimeInterval time;
    CGFloat x;
    CGFloat y;
    CGFloat z;
    CGFloat magnitude;    
}

@property (nonatomic,readwrite) NSTimeInterval time;
@property (nonatomic,readwrite) CGFloat x;
@property (nonatomic,readwrite) CGFloat y;
@property (nonatomic,readwrite) CGFloat z;
@property (nonatomic,readwrite) CGFloat magnitude;

+ (FFAccelerometerSample*) sample;

@end
