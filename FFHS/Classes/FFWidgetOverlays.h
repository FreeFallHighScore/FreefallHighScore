//
//  FFDropTimerLayer.h
//  FreefallHighscore
//
//  Created by James George on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface FFWidgetOverlays : CALayer {
    BOOL drawingTimer;
    NSDate* startTime;
    NSTimeInterval duration;
    
    BOOL drawingExport;
    CGFloat exportPercent;
}

@property (nonatomic, assign) NSDate* startTime;

@property (nonatomic, readwrite) CGFloat exportPercent;

- (void) setTimerWithStartTime:(NSDate*) theStartTime forDuration:(NSTimeInterval)newDuration;
- (void) fallStarted;

- (void) startDrawingExpot;
- (void) stopDrawingExport;

- (void) redrawLoop;

- (void) drawInContext:(CGContextRef)theContext;


@end
