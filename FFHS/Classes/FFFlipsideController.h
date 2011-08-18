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
    UIBarButtonItem* loginButton;
    BOOL loggedIn;
}
@property (nonatomic, assign) FFFlipsideViewController* flipsideController;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* loginButton;

- (IBAction)done:(id)sender;
- (IBAction)login:(id)sender;
- (void)refreshLoggedInStatus;
- (void)toggleLoginButtonText;

@end
