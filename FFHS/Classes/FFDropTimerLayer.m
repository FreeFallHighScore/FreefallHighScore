//
//  FFDropTimerLayer.m
//  FreefallHighscore
//
//  Created by James George on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFDropTimerLayer.h"


@implementation FFDropTimerLayer

@synthesize startTime;

- (void) setTimerWithStartTime:(NSDate*) theStartTime forDuration:(NSTimeInterval)newDuration
{
    self.startTime = theStartTime;
    duration = newDuration;
    drawing = YES;
}   

- (void)drawInContext:(CGContextRef)theContext
{

    if(drawing){
        CGFloat percentDone = -[self.startTime timeIntervalSinceNow]/duration;
        if(percentDone > 1.0){
            drawing = NO;
            return;
        }
        
        CGContextSetFillColorWithColor(theContext, [UIColor colorWithRed:1.0 green:0 blue:0 alpha:.25].CGColor );    
        CGContextBeginPath(theContext);
        CGPoint midpoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        CGContextMoveToPoint(theContext, midpoint.x, midpoint.y);

        CGFloat radius = 100;
        CGFloat arcPos = M_PI*2*percentDone;
        for(CGFloat i = 0; i < arcPos; i+=.1){
            CGPoint p = CGPointMake(cos(i-M_PI_2)*radius, sin(i-M_PI_2)*radius);
            CGContextAddLineToPoint(theContext, midpoint.x+p.x, midpoint.y+p.y);
        }
        CGPoint p = CGPointMake(cos(arcPos-M_PI_2)*radius, sin(arcPos-M_PI_2)*radius);
        CGContextAddLineToPoint(theContext, midpoint.x+p.x, midpoint.y+p.y);
        
        CGContextAddLineToPoint(theContext, midpoint.x, midpoint.y);
        
        CGContextFillPath(theContext);

    }
    
//    CGContextFillEllipseInRect(theContext, self.bounds);
     
    
//    NSLog(@"bounds %f %f %f %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);  
//    NSLog(@"********************** SUBCLASS DRAW CALL ******************************** !!!");
}

- (void) fallStarted
{
    drawing = NO;
}

@end
