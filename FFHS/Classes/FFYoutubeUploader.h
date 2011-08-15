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
}

@property (nonatomic,assign) UIViewController* toplevelController;
@property (nonatomic,assign) id<FFYoutubeUploaderDelegate> delegate;
@property (nonatomic,retain) NSString* keychainItemName;
@property (nonatomic,retain) NSString* clientID;
@property (nonatomic,retain) NSString* clientSecret;
@property (nonatomic,retain) NSString* developerKey;

@property (nonatomic,retain) GDataServiceTicket *uploadTicket;

@property (nonatomic, readonly) BOOL loggedIn;
@property (nonatomic, readonly) NSString* accountName; //returns nil if not logged in

@property (nonatomic, readonly) BOOL uploading;
@property (nonatomic, readonly) CGFloat uploadProgress;

- (GDataServiceGoogleYouTube *)youTubeService;

- (IBAction)login:(id)sender;
- (IBAction)logout:(id)sender;

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
