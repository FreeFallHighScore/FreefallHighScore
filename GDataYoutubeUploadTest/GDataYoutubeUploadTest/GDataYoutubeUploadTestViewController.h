//
//  GDataYoutubeUploadTestViewController.h
//  GDataYoutubeUploadTest
//
//  Created by James George on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataYouTube.h"
#import <AssetsLibrary/AssetsLibrary.h>

@class GTMOAuth2ViewControllerTouch;
@class GTMOAuth2Authentication;

@interface GDataYoutubeUploadTestViewController : UIViewController {
    GDataServiceGoogleYouTube* mService;
    NSString* keychainItemName;
    NSString* clientID;
    NSString* clientSecret;
    NSString* developerKey;
    
    UIButton* uploadButton;
    UIButton* stopUploadButton;
    UIButton* authorizeButton;
    UIButton* logoutButton;
    UILabel* authorizedUserLabel;
    UIProgressView* uploadProgressView;
    
    GDataServiceTicket *uploadTicket;
}

@property(nonatomic,retain) NSString* keychainItemName;
@property(nonatomic,retain) NSString* clientID;
@property(nonatomic,retain) NSString* clientSecret;
@property(nonatomic,retain) NSString* developerKey;

@property(nonatomic,retain) GDataServiceTicket *uploadTicket;

@property(nonatomic,retain) IBOutlet UIButton* uploadButton;
@property(nonatomic,retain) IBOutlet UIButton* stopUploadButton;
@property(nonatomic,retain) IBOutlet UIButton* authorizeButton;
@property(nonatomic,retain) IBOutlet UIButton* logoutButton;
@property(nonatomic,retain) IBOutlet UILabel* authorizedUserLabel;
@property(nonatomic,retain) IBOutlet UIProgressView* uploadProgressView;

- (void)showAlert:(NSString*)title withMessage:(NSString*)message;

- (GDataServiceGoogleYouTube *)youTubeService;

- (IBAction)authorize:(id)sender;
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error;
- (IBAction)upload:(id)sender;

- (IBAction)logout:(id)sender;
- (void)startUpload:(ALAsset*)asset;
- (IBAction)stopUpload:(id)sender;

- (void)getVideoAsset;

- (void)ticket:(GDataServiceTicket *)ticket hasDeliveredByteCount:(unsigned long long)numberOfBytesRead ofTotalByteCount:(unsigned long long)dataLength;
- (void)uploadTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
               error:(NSError *)error;

@end
