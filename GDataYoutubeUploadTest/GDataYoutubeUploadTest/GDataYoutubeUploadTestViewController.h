//
//  GDataYoutubeUploadTestViewController.h
//  GDataYoutubeUploadTest
//
//  Created by James George on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataYouTube.h"

@class GTMOAuth2ViewControllerTouch;
@class GTMOAuth2Authentication;

@interface GDataYoutubeUploadTestViewController : UIViewController {
    GDataServiceGoogleYouTube* mService;
    NSString* keychainItemName;
    NSString* clientID;
    NSString* clientSecret;
    NSString* developerKey;
}

@property(nonatomic,retain) NSString* keychainItemName;
@property(nonatomic,retain) NSString* clientID;
@property(nonatomic,retain) NSString* clientSecret;
@property(nonatomic,retain) NSString* developerKey;

- (GDataServiceGoogleYouTube *)youTubeService;

- (IBAction) upload:(id)sender;

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error;

@end
