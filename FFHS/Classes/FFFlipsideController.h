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
@class FFYoutubeUploader;

@interface FFFlipsideController : UIViewController {
    FFFlipsideViewController* flipsideController;
    UIBarButtonItem* loginButton;
    BOOL loggedIn;
}

@property (nonatomic, assign) FFFlipsideViewController* flipsideController;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* loginButton;
@property(nonatomic, readwrite) BOOL loggedIn;


- (IBAction)done:(id)sender;
- (IBAction)login:(id)sender;

- (void)refreshLoginButton;
- (void) dismissVideo;
- (void)showYoutubeVideo:(NSString*)youtubeURL;

//- (NSString*) shortAccountName; //everything before the @gmail.com
//- (NSString*) fullAccountName; //contains @gmail.com as well

- (void) userDidLogIn:(id)sender;
- (void) userDidLogOut:(id)sender;

@end
