//
//  FFFlipsideMyDropsController.m
//  FreefallHighscore
//
//  Created by James George on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFFlipsideMyDropsController.h"
#import "FFHighscoresProvider.h"
#import "FFYoutubeUploader.h"

@implementation FFFlipsideMyDropsController

@synthesize scores;
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scores = [[FFHighscoresProvider alloc] initWithQueryURL:@""];
    self.scores.tableView = tableView;
    [self refreshScoresTable];
    tableView.dataSource = self.scores;
    
}

//We need a way for this to get called when the login changes.
- (void) refreshScoresTable
{
    FFYoutubeUploader* uploader = (FFYoutubeUploader*)[[UIApplication sharedApplication].delegate uploader];
    if(uploader.loggedIn && uploader.accountLinked){
        [self.scores hidLoginCell];
        NSString* queryURL = 
        	[NSString stringWithFormat:@"http://freefallhighscore.com/staging/users/%@/videos.json", uploader.youtubeUserName];
        self.scores.queryURL = queryURL;
        [self.scores refreshQuery];        
    }
    else{
        [self.scores showLoginCell];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* videoURL = [self.scores youtubeURLForIndex:indexPath];
    if(videoURL != nil){
        [self showYoutubeVideo:videoURL];
    }
    return nil;
}

- (void) userDidLogIn:(id)sender;
{
	[self refreshScoresTable];
    [super userDidLogIn:sender];    
}

- (void) userDidLogOut:(id)sender
{
    [self refreshScoresTable];
    [super userDidLogOut:sender];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshScoresTable];
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
