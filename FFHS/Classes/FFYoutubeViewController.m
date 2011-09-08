//
//  FFYoutubeViewController.m
//  FreefallHighscore
//
//  Created by Jim on 9/7/11.
//  Copyright 2011 FlightPhase. All rights reserved.
//

#import "FFYoutubeViewController.h"


@implementation FFYoutubeViewController
@synthesize youtubeView;
@synthesize youtubeURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
            NSLog(@"youtube view controller did init");
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//	[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight];
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
//    return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[self.youtubeView loadYoutubeURL:self.youtubeURL];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end
