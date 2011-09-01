//
//  FFFlipsideHighscoresController.m
//  FreefallHighscore
//
//  Created by James George on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFFlipsideHighscoresController.h"
#import "FFHighscoresProvider.h"
#import "HJObjManager.h"

@implementation FFFlipsideHighscoresController

@synthesize tableView;
@synthesize scores;
@synthesize imageViewManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scores = [[FFHighscoresProvider alloc] initWithQueryURL:@"http://freefallhighscore.heroku.com/videos.json"];
    self.scores.tableView = tableView;
    self.scores.imageViewManager = [self.flipsideController imageViewManager];
    [scores refreshQuery];
    tableView.dataSource = self.scores;
}

                   
-(void)viewWillAppear:(BOOL)animated
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
