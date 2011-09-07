//
//  FFLinkYoutubeAccountController.h
//  FreefallHighscore
//
//  Created by Jim on 9/6/11.
//  Copyright 2011 FlightPhase. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FFLinkYoutubeAccountDelegate

- (void) userSignaledLinkedFinished;
- (void) userSignaledLinkedCanceled;

@end

@interface FFLinkYoutubeAccountController : UIViewController {
	
}

@property(nonatomic, assign) id<FFLinkYoutubeAccountDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIWebView* linkYoutubeWebview;
@property (nonatomic, retain) NSURLRequest* request;


- (IBAction) accountLinked:(id)sender;
- (IBAction) cancelLink:(id)sender;


@end
