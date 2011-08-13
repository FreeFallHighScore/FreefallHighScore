//
//  GDataYoutubeUploadTestViewController.h
//  GDataYoutubeUploadTest
//
//  Created by James George on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataYouTube.h"

//TODO put in private plist
#define kKeychainItemName @"OAuth: YouTube FreeFallHighScore"
#define kClientID         @"1045440843497.apps.googleusercontent.com"
#define kClientSecret     @"Nz6Ytrwzqr5tnD_E8-QzJ4Sh"
#define kDeveloperKey     @"AI39si7H3MXz-tQpyTjyqa5BnHlNVqVWB9YAubils0HqAbETSafztzK1-_nGM5pg5Lv9xcATljHho5VCEP40lnm-kjWRvVNxZQ"

@class GTMOAuth2ViewControllerTouch;
@class GTMOAuth2Authentication;

@interface GDataYoutubeUploadTestViewController : UIViewController {
    GDataServiceGoogleYouTube* mService;
}

- (GDataServiceGoogleYouTube *)youTubeService;

- (IBAction) upload:(id)sender;

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error;

@end
