//
//  FFVideoOverlayLayer.m
//  FreefallHighscore
//
//  Created by James George on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFVideoOverlayLayer.h"


@implementation FFVideoOverlayLayer

- (void)drawInContext:(CGContextRef)theContext

{
    
    /*
    CGMutablePathRef thePath = CGPathCreateMutable();
    
    
    
    CGPathMoveToPoint(thePath,NULL,15.0f,15.f);
    
    CGPathAddCurveToPoint(thePath,
                          
                          NULL,
                          
                          15.f,250.0f,
                          
                          295.0f,250.0f,
                          
                          295.0f,15.0f);
    
    
    
    CGContextBeginPath(theContext);
    
    CGContextAddPath(theContext, thePath );
    
    
    
    CGContextSetLineWidth(theContext,
                          
                          self.lineWidth);
    
    CGContextSetStrokeColorWithColor(theContext,
                                     
                                     self.lineColor);
    
    CGContextStrokePath(theContext);
    
    CFRelease(thePath);
    */
    
    NSLog(@"SUBCLASS DRAW CALL!!!");
}

@end
