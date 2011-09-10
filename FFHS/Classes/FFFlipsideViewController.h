//
//  FlipsideViewController.h
//  FFHS
//
//  Created by James George on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FFFlipsideViewControllerDelegate;
@class FFYoutubeUploader;
@class HJObjManager;

@interface FFFlipsideViewController : UIViewController<UITabBarControllerDelegate, UIActionSheetDelegate> {
    HJObjManager* imageViewManager;
}

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, assign) id <FFFlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) HJObjManager *imageViewManager;

- (IBAction)done:(id)sender;
- (IBAction)login:(id)sender;
//- (IBAction)logout:(id)sender;

@end


@protocol FFFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FFFlipsideViewController *)controller;
@end
