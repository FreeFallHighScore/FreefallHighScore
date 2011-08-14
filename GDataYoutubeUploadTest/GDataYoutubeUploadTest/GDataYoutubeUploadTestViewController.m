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
@synthesize stopUploadButton;
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
    
    if ([auth canAuthorize])
    {
        [authorizedUserLabel setText:[auth userEmail]];
        [authorizedUserLabel setHidden:NO];
        [uploadButton setHidden:NO];
        [logoutButton setHidden:NO];
        [authorizeButton setHidden:YES];
    }
    else
    {
        [authorizeButton setHidden:NO];
        [logoutButton setHidden:YES];
        [uploadButton setHidden:YES];
    }
    [uploadProgressView setHidden:YES];
    [stopUploadButton setHidden:YES];
    
    [[self youTubeService] setAuthorizer:auth];
    
    [super viewDidLoad];
}

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

#pragma mark - UI helpers
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

#pragma mark - Auth stuff
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
                 error:(NSError *)error
{
    
    if (error != nil) {
        // Authentication failed
        [authorizedUserLabel setText:@""];
        [self showAlert:@"Failure Authenticating" withMessage:@"You might want to wait a bit before pressing 'Allow Access'."];
        [self authorize:nil];
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

#pragma mark - Uploading!
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

- (IBAction) upload:(id)sender
{
    [self getVideoAsset];
}

-(void)startUpload:(ALAsset*)asset
{
    [GTMHTTPUploadFetcher setLoggingEnabled:YES];
    [GTMHTTPFetcher setLoggingEnabled:YES];
    
    NSURL* assetUrl = [[asset defaultRepresentation] url];
    NSLog(@"Asset found: %@", asset);
    NSLog(@"Asset url: %@", assetUrl);
    
    GDataServiceGoogleYouTube *service = [self youTubeService];
    
    NSString *filename = @"asset.MOV";
    NSString *mimeType = @"video/mp4";
    
    NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:kGDataServiceDefaultUser];
    
    // Media data
    NSString *titleStr = @"Testing: title";
    GDataMediaTitle *title = [GDataMediaTitle textConstructWithString:titleStr];
    
    NSString *descStr = @"Testing: description";
    GDataMediaDescription *desc = [GDataMediaDescription textConstructWithString:descStr];
    
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
    [mediaGroup setIsPrivate:NO]; // CHANGE!
    
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
    
    // Duration
    NSString *devTagDurationStr = @"dur:234"; // Store duration in milliseconds?
    GDataMediaCategory *devTagDuration = [GDataMediaCategory mediaCategoryWithString:devTagDurationStr];
    [devTagDuration setScheme:devTagSchemeUrl];
    
    // Location
    NSString *devTagLocationString = @"loc:+40.714945-73.936432";
    GDataMediaCategory *devTagLocation = [GDataMediaCategory mediaCategoryWithString:devTagLocationString];
    [devTagLocation setScheme:devTagSchemeUrl];
    
    // Device
    NSString *devTagDeviceString = @"dev:iphone:3";
    GDataMediaCategory *devTagDevice = [GDataMediaCategory mediaCategoryWithString:devTagDeviceString];
    [devTagDevice setScheme:devTagSchemeUrl];
        
    // Add them
    [mediaGroup addMediaCategory:devTagFFHS];
    [mediaGroup addMediaCategory:devTagDuration];
    [mediaGroup addMediaCategory:devTagLocation];
    [mediaGroup addMediaCategory:devTagDevice];
        
    // UI Updates
    [uploadProgressView setHidden:NO];
    [stopUploadButton setHidden:NO];
    [uploadButton setHidden:YES];
    
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

- (IBAction)stopUpload:(id)sender
{
    [uploadTicket cancelTicket];
    [self setUploadTicket:nil];
    
    [uploadProgressView setProgress:0.0];
    [uploadProgressView setHidden:YES];
    
    [stopUploadButton setHidden:YES];
    [uploadButton setHidden:NO];
}

// upload callback
- (void)uploadTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
               error:(NSError *)error
{
    if (error == nil)
    {
        [self showAlert:@"Success!" withMessage:@"Your video has been uploaded successfully!"];
    }
    else
    {
        [self showAlert:@"Failure" withMessage:@"Your video was not uploaded."];
    }
    
    NSLog(@"Ticket: %@", ticket);
    NSLog(@"Video Entry: %@", videoEntry);
    NSLog(@"Error: %@", error);
    
    [uploadProgressView setProgress:0.0];
    [uploadProgressView setHidden:YES];
    
    [stopUploadButton setHidden:YES];
    [uploadButton setHidden:NO];

    [self setUploadTicket:nil];
}

// progress callback
- (void)ticket:(GDataServiceTicket *)ticket hasDeliveredByteCount:(unsigned long long)numberOfBytesRead ofTotalByteCount:(unsigned long long)dataLength
{    
    [uploadProgressView setProgress:(float)numberOfBytesRead/(float)dataLength];
}

@end
