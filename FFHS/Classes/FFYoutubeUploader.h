//
//  FFYoutubeUploader.h
//  FreefallHighscore
//
//  Created by James George on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataYouTube.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

@protocol FFYoutubeUploaderDelegate <NSObject>
@optional
- (void) userDidSignIn:(NSString*)userName;;
- (void) userDidSignOut;
- (void) uploadReachedProgess:(CGFloat)progress;
- (void) uploadCompleted;
- (void) uploadFailedWithError:(NSError*)error;
@end


@class GTMOAuth2ViewControllerTouch;
@class GTMOAuth2Authentication;

@interface FFYoutubeUploader : NSObject {
    NSString* keychainItemName;
    NSString* clientID;
    NSString* clientSecret;
    NSString* developerKey;
    UIViewController* toplevelController;
    
    CGFloat progress;
    id<FFYoutubeUploaderDelegate> _delegate;
    GDataServiceTicket *uploadTicket;
    
    NSString* videoTitle;
    NSString* videoDescription;
    NSTimeInterval fallDuration;
    CLLocation* location;
}

@property (nonatomic,retain) GDataServiceTicket *uploadTicket;
@property (nonatomic,assign) GTMOAuth2ViewControllerTouch* loginView;
@property (nonatomic,assign) UIViewController* toplevelController;
@property (nonatomic,assign) id<FFYoutubeUploaderDelegate> delegate;
@property (nonatomic,retain) NSString* keychainItemName;
@property (nonatomic,retain) NSString* clientID;
@property (nonatomic,retain) NSString* clientSecret;
@property (nonatomic,retain) NSString* developerKey;

@property (nonatomic, assign) IBOutlet UIView* signinView;
@property (nonatomic, readonly) BOOL loggedIn;
@property (nonatomic, readonly) NSString* accountName;

@property (nonatomic, readonly) BOOL uploading;
@property (nonatomic, readonly) CGFloat uploadProgress;

//VIDEO PROPERTIES:
@property (nonatomic, retain) NSString* videoTitle;
@property (nonatomic, retain) NSString* videoDescription;
@property (nonatomic, readwrite) NSTimeInterval fallDuration;

@property (nonatomic, assign) CLLocation* location;

- (GDataServiceGoogleYouTube *)youTubeService;

- (IBAction) cancelSignin:(id)sender;
- (IBAction) login:(id)sender;
- (IBAction) logout:(id)sender;

- (void)showAlert:(NSString*)title withMessage:(NSString*)message;

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error;

- (void)startUploadWithURL:(NSURL*)assetURL;
- (void)startUploadWithAsset:(ALAsset*)asset;
- (IBAction)cancelUpload:(id)sender;

- (void)ticket:(GDataServiceTicket *)ticket hasDeliveredByteCount:(unsigned long long)numberOfBytesRead ofTotalByteCount:(unsigned long long)dataLength;

- (void)uploadTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
               error:(NSError *)error;


@end


