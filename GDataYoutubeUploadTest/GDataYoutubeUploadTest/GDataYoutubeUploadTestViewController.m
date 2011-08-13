//
//  GDataYoutubeUploadTestViewController.m
//  GDataYoutubeUploadTest
//
//  Created by James George on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GDataYoutubeUploadTestViewController.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GDataEntryYouTubeUpload.h"

@implementation GDataYoutubeUploadTestViewController

@synthesize keychainItemName;
@synthesize clientID;
@synthesize clientSecret;
@synthesize developerKey;
@synthesize authorizeButton;
@synthesize uploadButton;
@synthesize logoutButton;
@synthesize authorizedUserLabel;
@synthesize uploadProgressView;
@synthesize uploadTicket;

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    //[authorizeButton setHidden:YES];
    //[uploadButton setHidden:YES];
    //[[self authorizedUserLabel] setText:@""];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    //load keys
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"secret_developerkeys.plist"];
    NSDictionary *keydict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    self.keychainItemName = [keydict objectForKey:@"kKeychainItemName"];
    self.clientID = [keydict objectForKey:@"kClientID"];
    self.clientSecret = [keydict objectForKey:@"kClientSecret"];
    self.developerKey = [keydict objectForKey:@"kDeveloperKey"];
    
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:keychainItemName
                                                              clientID:clientID
                                                          clientSecret:clientSecret];
    
    [uploadProgressView setProgress:0.0];
    
    if ([auth canAuthorize]) {
        [authorizedUserLabel setText:[auth userEmail]];
        [authorizedUserLabel setHidden:NO];
        [uploadButton setHidden:NO];
        [logoutButton setHidden:NO];
        [authorizeButton setHidden:YES];
    } else {
        [authorizeButton setHidden:NO];
        [logoutButton setHidden:YES];
        [uploadButton setHidden:YES];
    }
    [[self youTubeService] setAuthorizer:auth];
    
    [super viewDidLoad];
}

- (GDataServiceGoogleYouTube *)youTubeService {
    
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

- (void)getVideoAsset
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    NSURL *fileUrl = [NSURL URLWithString:@"assets-library://asset/asset.MOV?id=1000000711&ext=MOV"];
    
    [library assetForURL:fileUrl
             resultBlock:^(ALAsset *asset) {
                 NSAssert(asset != nil, @"Asset shouldn't be nil");
                 [self startUpload:asset];
             }
            failureBlock:^(NSError *error) {
                NSLog(@"ERROR: %@", error);
            }];

}

-(void)startUpload:(ALAsset*)asset
{
    NSURL* assetUrl = [[asset defaultRepresentation] url];
    NSLog(@"Asset found: %@", asset);
    NSLog(@"Asset url: %@", assetUrl);

    GDataServiceGoogleYouTube *service = [self youTubeService];

    NSString *filename = @"asset.MOV";
    NSString *mimeType = @"video/mp4";
//    NSString *filename = [path lastPathComponent];
    
    NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:kGDataServiceDefaultUser];
    
    // Media data
    NSString *titleStr = @"Testing: title";
    GDataMediaTitle *title = [GDataMediaTitle textConstructWithString:titleStr];
    
    NSString *descStr = @"Testing: description";
    GDataMediaDescription *desc = [GDataMediaDescription textConstructWithString:descStr];
    
    NSString *categoryStr = @"Sports";
    GDataMediaCategory *category = [GDataMediaCategory mediaCategoryWithString:categoryStr];
    [category setScheme:kGDataSchemeYouTubeCategory];
    
    GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup mediaGroup];
    [mediaGroup setMediaTitle:title];
    [mediaGroup setMediaDescription:desc];
    [mediaGroup addMediaCategory:category];
    
    //NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:assetUrl
    //                                           defaultMIMEType:@"video/mov"];

    ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
    Byte *buf = malloc([assetRepresentation size]);  // will be freed automatically when associated NSData is deallocated
    NSError *err = nil;
    NSUInteger bytes = [assetRepresentation getBytes:buf fromOffset:0LL 
                              length:[assetRepresentation size] error:&err];
    
    NSData* videoData;
    if (err || bytes == 0) {
        // Are err and bytes == 0 redundant? Doc says 0 return means 
        // error occurred which presumably means NSError is returned.
        
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
//    [entry setUploadFileHandle:fileHandle];
    [entry setUploadData:videoData];
    
    
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

// progress callback
- (void)ticket:(GDataServiceTicket *)ticket hasDeliveredByteCount:(unsigned long long)numberOfBytesRead ofTotalByteCount:(unsigned long long)dataLength {
    
    float progress = (float)numberOfBytesRead/(float)dataLength;
    [uploadProgressView setProgress:progress];
}

// upload callback
- (void)uploadTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
               error:(NSError *)error {
    if (error == nil) {
        UIAlertView* alertView = nil; 
        @try { 
            alertView = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                   message:@"Your video has been uploaded successfully!"
                                                  delegate:self cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil]; 
            [alertView show]; 
        } @finally { 
            if (alertView)
                [alertView release]; 
        }
    } else {
        UIAlertView* alertView = nil; 
        @try { 
            alertView = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                   message:@"Your video was not uploaded."
                                                  delegate:self cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil]; 
            [alertView show]; 
        } @finally { 
            if (alertView)
                [alertView release]; 
        }
        
    }
    
    [uploadProgressView setProgress:0.0];
    [self setUploadTicket:nil];
}

- (IBAction) upload:(id)sender
{
    [self getVideoAsset];
}

- (IBAction) logout:(id)sender
{
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:keychainItemName];
    [authorizeButton setHidden:NO];
    [logoutButton setHidden:YES];
    [uploadButton setHidden:YES];
    [authorizedUserLabel setText:@""];
    
}

- (IBAction) authorize:(id)sender
{
    NSString *scope = [GDataServiceGoogleYouTube authorizationScope];
    
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                 clientID:clientID
                                                             clientSecret:clientSecret
                                                         keychainItemName:keychainItemName
                                                                 delegate:self
                                                         finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];
    
    [viewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [viewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentModalViewController:(UIViewController*)viewController animated:YES];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {

    if (error != nil) {
        // Authentication failed
        [authorizedUserLabel setText:@""];

        UIAlertView* alertView = nil; 
        @try { 
            alertView = [[UIAlertView alloc] initWithTitle:@"Failure Authenticating"
                                                   message:@"You might want to wait a bit before pressing 'Allow Access'."
                                                  delegate:self cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil]; 
            [alertView show]; 
        } @finally { 
            if (alertView)
                [alertView release]; 
        }
    } else {
        // Authentication succeeded
        [authorizedUserLabel setText:[auth userEmail]];
        [uploadButton setHidden:NO];
        [uploadButton setEnabled:YES];
        [logoutButton setHidden:NO];
        [logoutButton setEnabled:YES];
        [authorizeButton setHidden:YES];
        [authorizeButton setEnabled:NO];
        
        // Store authorization
        [[self youTubeService] setAuthorizer:auth];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

/*
- (void) GDataLoginDialogSucceeded: (GDataLoginDialog *) loginDialogauthenticatedWithUserInfo: (GDataOAuthAuthentication*) authInfo
    
    NSString *devKey = YOUTUBE_DEVELOPER_KEY;
    mService = [[GDataServiceGoogleYouTube alloc] init];
    [mService setShouldCacheDatedData:YES];
    [mService setServiceShouldFollowNextLinks:YES];
    [mService setServiceUploadChunkSize:500000];
    [mService setYouTubeDeveloperKey:devKey];
    
    if (mAuthObject)
    {
        [mService setAuthorizer: mAuthObject];
    }
    [mService setUserCredentialsWithUsername:nil password:nil];
    
    Code snippet for uploading:
        
        GDataServiceGoogleYouTube *service = [self youtubeService];
    NSURL *url = [GDataServiceGoogleYouTube
                  youTubeUploadURLForUserID:kGDataServiceDefaultUser];
    
    // load the file data
    NSString *path = [mDelegate mediaPath];
    NSString *filename = [path lastPathComponent];
    
    // gather all the metadata needed for the mediaGroup
    NSString *titleStr = [mUploadInfo objectForKey:kTitle];
    GDataMediaTitle *title = [GDataMediaTitle
                              textConstructWithString:titleStr];
    
    NSString *categoryStr = @"Entertainment";
    GDataMediaCategory *category = [GDataMediaCategory
                                    mediaCategoryWithString:categoryStr];
    [category setScheme:kGDataSchemeYouTubeCategory];
    
    NSString *descStr = [mUploadInfo objectForKey:kDescription];
    GDataMediaDescription *desc = [GDataMediaDescription
                                   textConstructWithString:descStr];
    
    GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup
                                          mediaGroup];
    [mediaGroup setMediaTitle:title];
    [mediaGroup setMediaDescription:desc];
    [mediaGroup addMediaCategory:category];
    
    NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:path
                                               defaultMIMEType:@"video/mov"];
    
    NSFileHandle *bigFileHandle = [NSFileHandle
                                   fileHandleForReadingAtPath:path];
    
    // create the upload entry with the mediaGroup and the file data
    GDataEntryYouTubeUpload *entry = [GDataEntryYouTubeUpload entry];
    
    [entry setNamespaces:[GDataYouTubeConstants youTubeNamespaces]];
    
    [entry setMediaGroup:mediaGroup];
    [entry setUploadMIMEType:mimeType];
    [entry setUploadSlug:filename];
    [entry setUploadFileHandle:bigFileHandle];
    
    SEL progressSel =
    @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
    [service setServiceUploadProgressSelector:progressSel];
    
    mTicket = [service fetchEntryByInsertingEntry:entry
                                       forFeedURL:url
                                         delegate:self
               
                                didFinishSelector:@selector(uploadTicket:finishedWithEntry:error:)];
    [mTicket retain];     
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
