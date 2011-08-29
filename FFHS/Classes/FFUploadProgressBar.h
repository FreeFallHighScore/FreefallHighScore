//
//  FFUploadProgressBar.h
//  FreefallHighscore
//
//  Created by James George on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FFUploadProgressBar : NSObject {
    
}

@property(nonatomic, assign) IBOutlet UIView* view;
@property(nonatomic, assign) IBOutlet UIImageView* bar;
@property(nonatomic, assign) IBOutlet UIImageView* flasher;
@property(nonatomic, assign) IBOutlet UIImageView* endcap;
@property(nonatomic, readwrite) CGFloat progress;

- (void) startProgress;
- (void) flasherOff;
- (void) flasherOn;

@end
