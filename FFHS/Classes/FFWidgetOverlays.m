//
//  FFDropTimerLayer.m
//  FreefallHighscore
//
//  Created by James George on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFWidgetOverlays.h"


@implementation FFWidgetOverlays

@synthesize startTime;
@synthesize spiralLayers;
@synthesize axis;

- (void) setTimerWithStartTime:(NSDate*) theStartTime forDuration:(NSTimeInterval)newDuration
{
    self.startTime = theStartTime;
    duration = newDuration;
    drawingTimer = YES;
    [self redrawLoop];
    
    bool reversed = NO;
    int i = 0;
    for(CALayer* layer in self.spiralLayers){
        if(i != 1 && i != 7){
            CABasicAnimation* rotationAnimation;
            rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0  * ( (reversed) ? -1 : 1) ];
            rotationAnimation.duration = 3.0 * i;
            rotationAnimation.cumulative = YES;
            rotationAnimation.repeatCount = HUGE_VALF; 
            rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];        
            [layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];   
            reversed = !reversed;
        }
        
        i++;
        
        CABasicAnimation* scaleAnimation;
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:0.0];
        scaleAnimation.toValue   = [NSNumber numberWithFloat:1.0];
        scaleAnimation.duration = 1.25;
        scaleAnimation.repeatCount = 0.0;
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];

        
        CABasicAnimation* opacityAnimation;
        opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = [NSNumber numberWithFloat:0.0];
        opacityAnimation.toValue   = [NSNumber numberWithFloat:1.0];
        opacityAnimation.duration = .25;
        opacityAnimation.repeatCount = 0.0;
        opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [layer addAnimation:opacityAnimation forKey:@"opacityAnimation"];
        
        layer.hidden = NO;
    }
}   

- (void) redrawLoop
{
    [self setNeedsDisplay];
    if(drawingTimer){
        [self performSelector:@selector(redrawLoop) withObject:nil afterDelay:1.0/30.0];
    }
}

- (void) createSpiralImages:(NSArray*)fileNames
{
    //delete old ones
    for(int i = 0; i < self.spiralLayers.count; i++){
        [[self.spiralLayers objectAtIndex:i] removeFromSuperlayer];
    }
    
    self.spiralLayers = [NSMutableArray array];
    
    self.axis = CGPointMake(self.bounds.size.height*.30, self.bounds.size.width*.65);
 
   	for(int i = 0; i < fileNames.count; i++){
        UIImage* image = [UIImage imageNamed:[fileNames objectAtIndex:i]];
        
        CALayer* layer = [CALayer layer];
        layer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
        layer.position = self.axis;
        layer.contents = (id)image.CGImage;
        layer.hidden = YES;
//        NSLog(@"inserting spiral image with size %f %f %f %f", 
//              layer.frame.origin.x, layer.frame.origin.y, 
//              layer.frame.size.width, layer.frame.size.height );
        

        [self addSublayer:layer];
        [self.spiralLayers addObject:layer];
    }
}


- (void)drawInContext:(CGContextRef)theContext
{

    if(drawingTimer){
        CGFloat percentDone = -[self.startTime timeIntervalSinceNow]/duration;
        if(percentDone > 1.0){
            drawingTimer = NO;
            return;
        }
        
        //CGContextSaveGState(theContext);
        //CGPoint midpoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        CGContextSetFillColorWithColor(theContext, [UIColor colorWithRed:1.0 green:0 blue:0 alpha:.25].CGColor );    
        CGContextBeginPath(theContext);
        CGContextMoveToPoint(theContext, self.axis.x, self.axis.y);

        CGFloat radius = 100;
        CGFloat arcPos = M_PI*2*percentDone;
        for(CGFloat i = 0; i < arcPos; i+=.1){
            CGPoint p = CGPointMake(cos(i-M_PI_2)*radius, sin(i-M_PI_2)*radius);
            CGContextAddLineToPoint(theContext, self.axis.x+p.x, self.axis.y+p.y);
        }
        CGPoint p = CGPointMake(cos(arcPos-M_PI_2)*radius, sin(arcPos-M_PI_2)*radius);
        CGContextAddLineToPoint(theContext, self.axis.x+p.x, self.axis.y+p.y);
        
        CGContextAddLineToPoint(theContext, self.axis.x, self.axis.y);
        
        CGContextFillPath(theContext);
    }

//    CGContextFillEllipseInRect(theContext, self.bounds);
        
//    NSLog(@"bounds %f %f %f %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);  
//    NSLog(@"********************** SUBCLASS DRAW CALL ******************************** !!!");
}


- (void) removeDropTimer
{
    drawingTimer = NO;
}

//- (void) startDrawingExport
//{
//    drawingExport = YES;
//    exportPercent = 0.0f;
//    [self redrawLoop];
//}
//
//- (void) stopDrawingExport
//{
//    drawingExport = NO;    
//}


@end
