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
#import "FFLinkYoutubeAccountController.h"

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
@synthesize responseData;
@synthesize youtubeUserName;
@synthesize accountLinkViewController;
@synthesize accountLinked;
@synthesize auth;

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
        
        self.auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:keychainItemName
                                                                     clientID:clientID
                                                                 clientSecret:clientSecret];
        
        [[self youTubeService] setAuthorizer:self.auth];
        
        if(self.loggedIn){
            [self queryForYoutubeUsername];
            NSLog(@"Authorized SUCCESS on start up!!");
        }
        else{
            NSLog(@"Authorized FAILED on start up.");
        }
    }
    return self;
}


- (void) queryForYoutubeUsername
{
	//first test to see if we've stored the name
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* userName = [defaults stringForKey:self.accountName];

    if(userName == nil || userName == @""){
        NSString* requestURL = @"https://gdata.youtube.com/feeds/api/users/default";
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
        [request setCachePolicy: NSURLRequestReloadIgnoringCacheData];
		
        NSLog(@"User query auth %@", self.auth);
        
        [self.auth authorizeRequest:request
             completionHandler:^(NSError* error){
                 if(error == nil){                 	
                     self.responseData = [NSMutableData data];
                     [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
                 }
                 else{
                     //TODO: check for no account linked error.
                     NSLog(@"Completed with error %@", error);
                 }
             }];
    }
    else{
        self.youtubeUserName = userName;
        self.accountLinked = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kFFUserDidLogin 
                                                            object:self];
    }
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

- (IBAction) login:(id)sender
{
	if(self.loggedIn && !self.accountLinked){
        [self attemptToLinkAccount];
    }
    else if(!self.loggedIn){
        NSString *scope = [GDataServiceGoogleYouTube authorizationScope];    
        self.loginView = [[[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                     clientID:clientID
                                                                 clientSecret:clientSecret
                                                             keychainItemName:keychainItemName
                                                                     delegate:self
                                                             finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];

//        [[NSBundle mainBundle] loadNibNamed:@"SigninAccessory" owner:self options:nil];
//        UIView* authView = [self.loginView view];
//        [authView insertSubview:self.signinView aboveSubview:[[authView subviews] objectAtIndex:0]];
        
//        CGRect authViewFrame = [authView frame];
//        CGRect signinViewFrame = [self.signinView frame];
//        self.signinView.frame = CGRectMake(0, authViewFrame.size.height - signinViewFrame.size.height, signinViewFrame.size.width, signinViewFrame.size.height);
        
        UINavigationController *navigationController = [[UINavigationController alloc]
                                                        initWithRootViewController:self.loginView];
        UIBarButtonItem* barItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                 target:self 
                                                                                 action:@selector(cancelSignin:)];
         
        [self.loginView setInitialHTMLString:@"<html><body><span style=\"font-size:20px\">Loading Youtube Login...</span></body></html>"];
        [self.loginView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self.loginView setModalPresentationStyle:UIModalPresentationPageSheet];
        [self.toplevelController presentModalViewController:navigationController animated:YES];
        [[self.loginView navigationItem] setLeftBarButtonItem:barItem];
        [[self.loginView navigationItem] setRightBarButtonItem:nil]; //kill the stupid arrows

        [barItem release];
        [navigationController release];
    }

}


- (IBAction) logout:(id)sender
{
    if(!self.loggedIn) return;
    
    if(self.auth == nil) return;
    
    if(self.uploading){
        [self cancelUpload:self];
    }
    
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:keychainItemName];
    
    if([self.auth canAuthorize]){
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
    }
    [self.auth reset];
    
    self.accountLinked = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFFUserDidLogout object:self];
    
   	//NSLog(@"signed out. canAuthorize: %d", [[self youTubeService] authorizer] != nil && [[[self youTubeService] authorizer] canAuthorize]);
    NSLog(@"signed out.");
}

- (BOOL) loggedIn
{
    NSLog(@"LOGIN CHECK: self? %@ Auth? %@ can auth? %d", self, self.auth, [self.auth canAuthorize]);
    
    return self.auth != nil && [self.auth canAuthorize];
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
      finishedWithAuth:(GTMOAuth2Authentication *)newAuth
                 error:(NSError *)error
{
    
    if (error != nil) {
        NSLog(@"login error %@", [error description]);
        //TODO change alert based on the error.
        //could be no interent.. could be auth denied.
        ShowAlert(@"Failure Authenticating", @"Careful to wait until the confirmation page is completely loaded before pressing 'Allow Access'.");
    } else {
        // Store authorization
        self.auth = newAuth;
        [[self youTubeService] setAuthorizer:newAuth];
        [self queryForYoutubeUsername];
    }
    
    [self.toplevelController dismissModalViewControllerAnimated:YES];
}

#pragma mark authentication stuff

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {    
    //TODO: handle this error with a message
    ShowAlert(@"Request Error", [NSString stringWithFormat:@"failed to receive data with error @%", [error localizedDescription] ]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
	[connection release];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"response! %@", responseString);

    NSString *errorString = @"NoLinkedYouTubeAccount";
    NSRange range = [responseString rangeOfString: errorString];
    
    if (range.location != NSNotFound) {
        //PRESENT LOGIN URL
        NSLog(@"Found NO LINKED ACCOUNT!!!!");
        self.accountLinked = NO;
        [self attemptToLinkAccount];
    }
    else{
        //HARVEST USER NAME
    	NSRange startRange = [responseString rangeOfString:@"<name>"];
    	NSRange stopRange = [responseString rangeOfString:@"</name>"];
        if(startRange.location != NSNotFound && stopRange.location != NSNotFound){
            NSInteger startLocation = startRange.location+startRange.length;
            self.youtubeUserName = [responseString substringWithRange:NSMakeRange(startLocation, stopRange.location - startLocation)];
            NSLog(@"youtube user name is... %@", self.youtubeUserName);
            self.accountLinked = YES;

            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.youtubeUserName forKey:self.accountName];
            [defaults synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:kFFUserDidLogin 
                                                                object:self];
            
        }
    }
    [responseString release];
}

- (void) attemptToLinkAccount
{
    NSString* requestURL = @"https://www.youtube.com/create_channel";
    //NSString* requestURL = @"https://www.youtube.com/finish_link_upgrade";
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    [request setCachePolicy: NSURLRequestReloadIgnoringCacheData];

    self.accountLinkViewController = [[FFLinkYoutubeAccountController alloc] initWithNibName:nil bundle:nil];
    self.accountLinkViewController.request = request;
    self.accountLinkViewController.delegate = self;
    [accountLinkViewController release];

    
    [self.auth authorizeRequest:request
              completionHandler:^(NSError* error){
                  if(error == nil){                 	
                      
                      [self.accountLinkViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
                      [self.accountLinkViewController setModalPresentationStyle:UIModalPresentationPageSheet];
                      [self.toplevelController presentModalViewController:(UIViewController*)self.accountLinkViewController animated:YES];
                  }
                  else{
                      //TODO: check for no account linked error.
                      NSLog(@"Completed with error %@", error);
                  }
              }];    

}

- (void) userSignaledLinkedFinished
{
    //requery for name
    [self queryForYoutubeUsername];
}

- (void) userSignaledLinkedCanceled
{
    //display an error...
    ShowAlert(@"Account Link", @"You must setup your YouTube profile in order to submit highscores");
    [self logout:self];
    //TODO attach appropriate UI stuff
}

#pragma mark upload stuff
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

- (void)startUploadWithAsset:(ALAsset*)asset //(AVURLAsset*)
{
    if(!self.loggedIn){
        ShowAlert(@"Upload Error", @"Trying to start upload without being logged in");
        return;    
    }

    if(!self.accountLinked){
        ShowAlert(@"Upload Error", @"Trying to start upload without setting up Youtube Account");
        return;    
        
    }
    
    if(self.uploading){
        ShowAlert(@"Upload Error", @"Trying to start upload with one already in progress");
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
    
//    // GMail account
//    NSString *devTagAccountNameString = [NSString stringWithFormat:@"u:%@", [self accountName]];
//    GDataMediaCategory *devTagAccountName = [GDataMediaCategory mediaCategoryWithString:devTagAccountNameString];
//    [devTagAccountName setScheme:devTagSchemeUrl];
//    [mediaGroup addMediaCategory:devTagAccountName];
    
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
}

// upload callback
- (void) uploadTicket:(GDataServiceTicket *)ticket
    finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
                error:(NSError *)error
{
    if (error == nil){
        ShowAlert(@"Success!", @"Your video has been uploaded successfully!");
        if(self.delegate && [self.delegate respondsToSelector:@selector(uploadCompleted)]){
            [self.delegate uploadCompleted];
        }
    }
    else{
        ShowAlert(@"Failure", @"Your video was not uploaded.");
        if(self.delegate && [self.delegate respondsToSelector:@selector(uploadFailedWithError:)]){
            [self.delegate uploadFailedWithError:error];
        }
    }
    
    NSLog(@"Ticket: %@", ticket);
    NSLog(@"Video Entry: %@", videoEntry);
    NSLog(@"Error: %@", error);
    
    
    self.uploadTicket = nil;
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

- (NSString*) accountNameShort
{    
    if(!self.loggedIn){
        return @"(not logged in)";
    }
    NSString *accountName = [self accountName];
    return (NSString*)[[accountName componentsSeparatedByString:@"@"] objectAtIndex:0];
}

// progress callback
- (void)ticket:(GDataServiceTicket *)ticket hasDeliveredByteCount:(unsigned long long)numberOfBytesRead ofTotalByteCount:(unsigned long long)dataLength
{    
    progress = (CGFloat)numberOfBytesRead/(CGFloat)dataLength;
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(uploadReachedProgess:)]){
        [self.delegate uploadReachedProgess:progress];
    }
}

@end
