//
//  GDataYoutubeUploadTestViewController.m
//  GDataYoutubeUploadTest
//
//  Created by James George on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GDataYoutubeUploadTestViewController.h"

@implementation GDataYoutubeUploadTestViewController

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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (IBAction) upload
{

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
