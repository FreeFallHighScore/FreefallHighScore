//
//  FFYoutubeUploader.m
//  FreefallHighscore
//
//  Created by James George on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFYoutubeUploader.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GDataEntryYouTubeUpload.h"

//add cancel sign in

@implementation FFYoutubeUploader

@synthesize keychainItemName;
@synthesize clientID;
@synthesize clientSecret;
@synthesize developerKey;
@synthesize uploadTicket;
@synthesize uploadProgress = progress;
@synthesize toplevelController;
@synthesize delegate = _delegate;
@synthesize videoTitle;
@synthesize videoDescription;
@synthesize fallDuration;
@synthesize location;
@synthesize signinView;
@synthesize loginView;

- (id) init
{
    self = [super init];
    if(self){
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:@"secret_developerkeys.plist"];
        NSDictionary *keydict = [NSDictionary dictionaryWithContentsOfFile:finalPath];

        self.keychainItemName = [keydict objectForKey:@"kKeychainItemName"];
        self.clientID = [keydict objectForKey:@"kClientID"];
        self.clientSecret = [keydict objectForKey:@"kClientSecret"];
        self.developerKey = [keydict objectForKey:@"kDeveloperKey"];
        
        NSLog(@"keys? %@", keydict);
        
        GTMOAuth2Authentication *auth;
        auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:keychainItemName
                                                                     clientID:clientID
                                                                 clientSecret:clientSecret];
        
        [[self youTubeService] setAuthorizer:auth];
        
        if(self.loggedIn){
            NSLog(@"Authorized SUCCESS on start up!!");
        }
        else{
            NSLog(@"Authorized FAILED on start up.");
        }
    }
    return self;
}


#pragma mark - YouTube API stuff
- (GDataServiceGoogleYouTube *)youTubeService
{
    static GDataServiceGoogleYouTube* service = nil;
    
    if (!service) {
        service = [[GDataServiceGoogleYouTube alloc] init];
        
        [service setShouldCacheResponseData:YES];
        [service setServiceShouldFollowNextLinks:YES];
        [service setIsServiceRetryEnabled:YES];
    }
    
    [service setYouTubeDeveloperKey:developerKey];
    
    return service;
}

- (IBAction) logout:(id)sender
{
    if(self.uploading){
        [self cancelUpload:self];
    }
    
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:keychainItemName];
    if(self.delegate && [self.delegate respondsToSelector:@selector(userDidSignOut)]){
        [self.delegate userDidSignOut];
    }
    NSLog(@"signed out. canAuthorize: %d", [[self youTubeService] authorizer] != nil &&
          [[[self youTubeService] authorizer] canAuthorize]);
}

- (IBAction) login:(id)sender
{
    //We want to use this function for switching users as well!
//    if(self.loggedIn){
//        NSLog(@"ERROR -- trying to login when already logged in!");
//        return;
//    }
    
//    [self showAlert:@"LOGIN"
//        withMessage:[NSString stringWithFormat:@"toplevel %@", self.toplevelController] ];
     
    NSString *scope = [GDataServiceGoogleYouTube authorizationScope];
    
    //GTMOAuth2ViewControllerTouch *viewController;
    self.loginView = [[[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                 clientID:clientID
                                                             clientSecret:clientSecret
                                                         keychainItemName:keychainItemName
                                                                 delegate:self
                                                         finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];

    //[viewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    //add signin canceler;
    
    [[NSBundle mainBundle] loadNibNamed:@"SigninAccessory" owner:self options:nil];
    UIView* authView = [self.loginView view];
    [authView insertSubview:self.signinView aboveSubview:[[authView subviews] objectAtIndex:0]];
    
    CGRect authViewFrame = [authView frame];
    CGRect signinViewFrame = [self.signinView frame];
    self.signinView.frame = CGRectMake(0, authViewFrame.size.height-signinViewFrame.size.height, signinViewFrame.size.width, signinViewFrame.size.height);
    
    [self.loginView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.loginView setModalPresentationStyle:UIModalPresentationPageSheet];
    [self.toplevelController presentModalViewController:(UIViewController*)self.loginView animated:YES];

}

- (IBAction) cancelSignin:(id)sender
{
    [self.loginView cancelSigningIn];
    [self.toplevelController dismissModalViewControllerAnimated:YES];
    self.loginView = nil;
    [self.signinView removeFromSuperview];
    self.signinView = nil;
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error
{
    
    if (error != nil) {
        NSLog(@"login error %@", [error description]);
        [self showAlert:@"Failure Authenticating" 
            withMessage:@"Careful to wait until the confirmation page is completely loaded before pressing 'Allow Access'."];
    } else {
        
        // Store authorization
        [[self youTubeService] setAuthorizer:auth];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(userDidSignIn:)]){
            [self.delegate userDidSignIn:self.accountName];
        }
    }
    
    [self.toplevelController dismissModalViewControllerAnimated:YES];
}

- (void)startUploadWithURL:(NSURL*)assetURL
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
    [library assetForURL:assetURL
             resultBlock:^(ALAsset *asset) {
                 NSAssert(asset != nil, @"Asset shouldn't be nil");
                 [self startUploadWithAsset:asset];
             }
            failureBlock:^(NSError *error) {
                NSLog(@"ERROR: %@", error);
            }];
    
    [library release];
}

- (void)startUploadWithAsset:(ALAsset*)asset
{
    if(!self.loggedIn){
        NSLog(@"Error -- Trying to start upload without being logged in");
        return;    
    }

    if(self.uploading){
        NSLog(@"Error -- Starting upload with upload already in progress");
        return;
    }
    
    //[GTMHTTPUploadFetcher setLoggingEnabled:YES];
    //[GTMHTTPFetcher setLoggingEnabled:YES];
    
    NSURL* assetURL = [[asset defaultRepresentation] url];

    NSLog(@"Asset url: %@", assetURL);
    
    GDataServiceGoogleYouTube *service = [self youTubeService];
    
    NSString *filename = @"asset.MOV";
    NSString *mimeType = @"video/mp4";
    
    NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:kGDataServiceDefaultUser];
    
    // Media data
    GDataMediaTitle *title = [GDataMediaTitle textConstructWithString:self.videoTitle];
    
    //TODO: generate description
    GDataMediaDescription *desc = [GDataMediaDescription textConstructWithString:self.videoDescription];

    NSString *categoryStr = @"Sports";
    GDataMediaCategory *category = [GDataMediaCategory mediaCategoryWithString:categoryStr];
    [category setScheme:kGDataSchemeYouTubeCategory];
    
    NSString *keywordsStr = @"FreeFallHighScore";
    GDataMediaKeywords *keywords = [GDataMediaKeywords keywordsWithString:keywordsStr];
    
    GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup mediaGroup];
    [mediaGroup setMediaTitle:title];
    [mediaGroup setMediaDescription:desc];
    [mediaGroup addMediaCategory:category];    
    [mediaGroup setMediaKeywords:keywords];
    [mediaGroup setIsPrivate:NO];
    
    // Asset stuff
    ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
    Byte *buf = malloc([assetRepresentation size]);  // will be freed automatically when associated NSData is deallocated
    NSError *err = nil;
    NSUInteger bytes = [assetRepresentation getBytes:buf fromOffset:0LL 
                                              length:[assetRepresentation size] error:&err];
    
    NSData* videoData;
    if (err || bytes == 0) {
        NSLog(@"error from getBytes: %@", err);
        videoData = nil;
        return;
    } 
    videoData = [NSData dataWithBytesNoCopy:buf length:[assetRepresentation size] 
                               freeWhenDone:YES];  // YES means free malloc'ed buf that backs this when deallocated
    
    // create the upload entry with the mediaGroup and the file data
    GDataEntryYouTubeUpload *entry = [GDataEntryYouTubeUpload entry];
    
    [entry setNamespaces:[GDataYouTubeConstants youTubeNamespaces]];    
    [entry setMediaGroup:mediaGroup];
    [entry setUploadMIMEType:mimeType];
    [entry setUploadSlug:filename];
    [entry setUploadData:videoData];
    
    // Set dev tags
    // Developer tags
    NSString* devTagSchemeUrl = @"http://gdata.youtube.com/schemas/2007/developertags.cat";
    
    // FreeFallHighScore
    NSString *devTagFFHSStr = @"freefallhighscore";
    GDataMediaCategory *devTagFFHS = [GDataMediaCategory mediaCategoryWithString:devTagFFHSStr];
    [devTagFFHS setScheme:devTagSchemeUrl];
    [mediaGroup addMediaCategory:devTagFFHS];

    // Duration
    NSLog(@"Duration of drop: %fs, %dms", fallDuration, (NSInteger)(fallDuration*1000));

    NSString *devTagDurationStr = [NSString stringWithFormat:@"dur:%d", (NSInteger)(fallDuration*1000)]; 
    GDataMediaCategory *devTagDuration = [GDataMediaCategory mediaCategoryWithString:devTagDurationStr];
    [devTagDuration setScheme:devTagSchemeUrl];
    [mediaGroup addMediaCategory:devTagDuration];

    // Location
    if(location != nil){
        GDataMediaCategory *devTagLatitude, *devTagLongitude;
        NSString *devTagLatString, *devTagLonString;
        devTagLatString = [NSString stringWithFormat: @"lat:%+.6f", location.coordinate.latitude];
        devTagLonString = [NSString stringWithFormat: @"lon:%+.6f", location.coordinate.longitude];
        
        devTagLatitude  = [GDataMediaCategory mediaCategoryWithString:devTagLatString];
        devTagLongitude = [GDataMediaCategory mediaCategoryWithString:devTagLonString];
        [devTagLatitude  setScheme:devTagSchemeUrl];
        [devTagLongitude setScheme:devTagSchemeUrl];
        
        [mediaGroup addMediaCategory:devTagLatitude];
        [mediaGroup addMediaCategory:devTagLongitude];
    }
    
    // Device
    NSString *devTagDeviceString = [NSString stringWithFormat: @"mak:%@,sys:%@,ver:%@", [UIDevice currentDevice].model, [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
    GDataMediaCategory *devTagDevice = [GDataMediaCategory mediaCategoryWithString:devTagDeviceString];
    [devTagDevice setScheme:devTagSchemeUrl];
    [mediaGroup addMediaCategory:devTagDevice];
    
    
    // UI Updates
//    [uploadProgressView setHidden:NO];
//    [stopUploadButton setHidden:NO];
//    [uploadButton setHidden:YES];
    
    SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
    [service setServiceUploadProgressSelector:progressSel];
    
    // YouTube's upload URL is not yet https; we need to explicitly set the
    // authorizer to allow authorizing an http URL
    [[service authorizer] setShouldAuthorizeAllRequests:YES];
    
    GDataServiceTicket *ticket;
    ticket = [service fetchEntryByInsertingEntry:entry
                                      forFeedURL:url
                                        delegate:self
                               didFinishSelector:@selector(uploadTicket:finishedWithEntry:error:)];
    
    [self setUploadTicket:ticket];
}


- (IBAction)cancelUpload:(id)sender;
{
    if(self.uploading){
        [self.uploadTicket cancelTicket];
        self.uploadTicket = nil;
    }
    
    
//    [uploadProgressView setProgress:0.0];
//    [uploadProgressView setHidden:YES];
    
//    [stopUploadButton setHidden:YES];
//    [uploadButton setHidden:NO];
}

// upload callback
- (void) uploadTicket:(GDataServiceTicket *)ticket
    finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
                error:(NSError *)error
{
    if (error == nil){
        [self showAlert:@"Success!" withMessage:@"Your video has been uploaded successfully!"];
        if(self.delegate && [self.delegate respondsToSelector:@selector(uploadCompleted)]){
            [self.delegate uploadCompleted];
        }
    }
    else{
        [self showAlert:@"Failure" withMessage:@"Your video was not uploaded."];
        if(self.delegate && [self.delegate respondsToSelector:@selector(uploadFailedWithError:)]){
            [self.delegate uploadFailedWithError:error];
        }
    }
    
    NSLog(@"Ticket: %@", ticket);
    NSLog(@"Video Entry: %@", videoEntry);
    NSLog(@"Error: %@", error);
    
//    [uploadProgressView setProgress:0.0];
//    [uploadProgressView setHidden:YES];
    
    
    self.uploadTicket = nil;
}

- (BOOL) loggedIn
{
    return [[self youTubeService] authorizer] != nil && [[[self youTubeService] authorizer] canAuthorize];
}

- (BOOL) uploading
{
    return self.uploadTicket != nil;
}

- (NSString*) accountName
{    
    if(!self.loggedIn){
        return @"(not logged in)";
    }
    return [[[self youTubeService] authorizer] userEmail];
}

// progress callback
- (void)ticket:(GDataServiceTicket *)ticket hasDeliveredByteCount:(unsigned long long)numberOfBytesRead ofTotalByteCount:(unsigned long long)dataLength
{    
    progress = (CGFloat)numberOfBytesRead/(CGFloat)dataLength;
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(uploadReachedProgess:)]){
        [self.delegate uploadReachedProgess:progress];
    }
                                
//    [uploadProgressView setProgress:(float)numberOfBytesRead/(float)dataLength];
}

- (void)showAlert:(NSString*)title withMessage:(NSString*)message
{
    UIAlertView* alertView = nil; 
    @try { 
        alertView = [[UIAlertView alloc] initWithTitle:title
                                               message:message
                                              delegate:self cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil]; 
        [alertView show]; 
    } @finally { 
        if (alertView)
            [alertView release]; 
    }
}

@end
