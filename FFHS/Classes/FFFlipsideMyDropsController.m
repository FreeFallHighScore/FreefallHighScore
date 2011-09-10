//
//  FFFlipsideMyDropsController.m
//  FreefallHighscore
//
//  Created by James George on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFFlipsideMyDropsController.h"
#import "FFHighscoresProvider.h"

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
//    if(self.loggedIn){
//        NSString* queryURL = [NSString stringWithFormat:@"http://freefallhighscore.com/api/hiscores_mobile/?oauthid=%@", [self fullAccountName]];
//        NSLog(@"querying personal movies! %@", queryURL);
//        self.scores.queryURL = queryURL;
//        [scores refreshQuery];
//    }
//    else{
//        [self.scores showLoginCell];
//    }
}
                          
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
