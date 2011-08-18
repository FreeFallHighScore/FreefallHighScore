//
//  FFDropTimerLayer.h
//  FreefallHighscore
//
//  Created by James George on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface FFDropTimerLayer : CALayer {
    NSDate* startTime;
    NSTimeInterval duration;
    BOOL drawing;
}

@property (nonatomic, assign) NSDate* startTime;

- (void) setTimerWithStartTime:(NSDate*) theStartTime forDuration:(NSTimeInterval)newDuration;
- (void) fallStarted;

- (void) drawInContext:(CGContextRef)theContext;

@end
