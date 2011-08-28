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
@synthesize exportPercent;
@synthesize spiralImages;
@synthesize spiralLayers;
@synthesize spiralFiles;

- (void) setTimerWithStartTime:(NSDate*) theStartTime forDuration:(NSTimeInterval)newDuration
{
    self.startTime = theStartTime;
    duration = newDuration;
    drawingTimer = YES;
    [self redrawLoop];
    
    self.spiralImages = [NSMutableArray array];
    self.spiralLayers = [NSMutableArray array];
    
    CGPoint midpoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
	for(int i = 0; i < self.spiralFiles.count; i++){
        UIImage* image = [UIImage imageNamed:[self.spiralFiles objectAtIndex:i]];
    	[self.spiralImages addObject:image];
        CALayer* layer = [CALayer layer];
        //layer.frame = CGRectMake(midpoint.x, midpoint.y, image.size.width, image.size.height);
        layer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
        layer.position = midpoint;
        layer.contents = image;
        
        NSLog(@"inserting spiral image with size %f %f %f %f", 
              layer.frame.origin.x, layer.frame.origin.y, 
              layer.frame.size.width, layer.frame.size.height );
		/*        
         CABasicAnimation* rotationAnimation;
         rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
         rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
         rotationAnimation.duration = 1.0*i;
         rotationAnimation.cumulative = YES;
         rotationAnimation.repeatCount = HUGE_VALF; 
         rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];        
         [layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];   
         */
        
        [self addSublayer:layer];
        [self.spiralLayers addObject:layer];
    }
    
    
}   

- (void) redrawLoop
{
    [self setNeedsDisplay];
    if(drawingExport || drawingTimer){
        [self performSelector:@selector(redrawLoop) withObject:nil afterDelay:1.0/30.0];
    }
}

- (void) createSpiralImages:(NSArray*)fileNames
{
    self.spiralFiles = fileNames;
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
        CGPoint midpoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
//        CGContextTranslateCTM(theContext, midpoint.x, midpoint.y);
        
//        for(int i = 0; i < self.spiralImages.count; i++){
//        	CGContextSaveGState(theContext);
//            
//            CGContextRotateCTM(theContext, i*10*(1+percentDone));
//            UIImage* img = [self.spiralImages objectAtIndex:i];
//            CGSize imageSize = img.size;
//        	CGContextDrawImage(theContext, 
//                               CGRectMake(0, 0, imageSize.width, imageSize.height), 
//                               img.CGImage);
//            
//            CGContextRestoreGState(theContext);
//        }
//        
        CGContextSetFillColorWithColor(theContext, [UIColor colorWithRed:1.0 green:0 blue:0 alpha:.25].CGColor );    
        CGContextBeginPath(theContext);
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

- (void) removeDropTimer
{
    drawingTimer = NO;
}

- (void) startDrawingExport
{
    drawingExport = YES;
    exportPercent = 0.0f;
    [self redrawLoop];
}

- (void) stopDrawingExport
{
    drawingExport = NO;    
}


@end
