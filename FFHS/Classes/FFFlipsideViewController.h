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

@interface FFFlipsideViewController : UIViewController<UITabBarControllerDelegate> {
    FFYoutubeUploader* uploader; //weak reference
}

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, assign) id <FFFlipsideViewControllerDelegate> delegate;
@property (nonatomic, assign) FFYoutubeUploader* uploader;

- (IBAction)done:(id)sender;
- (IBAction)login:(id)sender;

@end


@protocol FFFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FFFlipsideViewController *)controller;
@end
