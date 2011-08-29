//
//  FFUploadProgressBar.m
//  FreefallHighscore
//
//  Created by James George on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFUploadProgressBar.h"


@implementation FFUploadProgressBar
@synthesize view;
@synthesize bar;
@synthesize flasher;
@synthesize endcap;
@synthesize progress;

- (void) startProgress
{
    [self flasherOn];
    self.endcap.alpha = 0.0f;
    self.progress = 0;
}

- (void) setProgress:(CGFloat)p
{
    progress = p;
    
    [UIView animateWithDuration:.2
                     animations: ^{
                         self.bar.frame = CGRectMake(-432 + 365*p, self.bar.frame.origin.y,
                                                     self.bar.frame.size.width, self.bar.frame.size.height);
                         
                         self.flasher.frame = CGRectMake(2 + 365*p, self.flasher.frame.origin.y, 
                                                         self.flasher.frame.size.width, self.flasher.frame.size.height);
                         if (progress == 1.0) {
                             self.endcap.alpha = 1.0f;
                         }
                     }     
                     completion:^(BOOL finished){ 
                     }];

}

- (void) flasherOn
{
 
     self.flasher.alpha = 1.0f;
     if(progress != 1.0){
         NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
         [self performSelector:@selector(flasherOff) withObject:nil afterDelay:.75 inModes:modes];
     }
   
}

- (void) flasherOff
{
     self.flasher.alpha = .0f;
     NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
     [self performSelector:@selector(flasherOn) withObject:nil afterDelay:.75 inModes:modes];                         
    
}

- (void) endProgress
{
    
}

@end
