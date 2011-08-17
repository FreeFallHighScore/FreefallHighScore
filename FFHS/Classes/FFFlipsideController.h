//
//  FFFlipsideController.h
//  FreefallHighscore
//
//  Created by James George on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFFlipsideViewController;
@interface FFFlipsideController : UIViewController {
    FFFlipsideViewController* flipsideController;
}
@property (nonatomic, assign) FFFlipsideViewController* flipsideController;

- (IBAction)done:(id)sender;
- (IBAction)login:(id)sender;

@end
