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
}

@property (nonatomic, retain) NSMutableArray* spiralLayers;
@property (nonatomic, assign) NSDate* startTime;
@property (nonatomic, readwrite) CGPoint axis;

- (void) createSpiralImages:(NSArray*)fileNames;
- (void) positionSpiralImages;

- (void) setTimerWithStartTime:(NSDate*) theStartTime forDuration:(NSTimeInterval)newDuration;
- (void) removeDropTimer;


- (void) redrawLoop;

- (void) drawInContext:(CGContextRef)theContext;
//- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;

@end
