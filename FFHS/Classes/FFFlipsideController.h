//
//  FFFlipsideController.h
//  FreefallHighscore
//
//  Created by James George on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFFlipsideViewController;
@class FFYoutubeViewController;

@interface FFFlipsideController : UIViewController {
    FFFlipsideViewController* flipsideController;
}

@property (nonatomic, assign) IBOutlet FFFlipsideViewController* flipsideController;
@property (nonatomic, retain) UIBarButtonItem* loginButton;


- (IBAction)done:(id)sender;
- (IBAction)login:(id)sender;

- (void)refreshLoginButton;
- (void)showYoutubeVideo:(NSString*)youtubeURL;

- (void) userDidLogIn:(id)sender;
- (void) userDidLogOut:(id)sender;

@end
