//
//  FlipsideViewController.m
//  FFHS
//
//  Created by James George on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFFlipsideViewController.h"
#import "FFYoutubeUploader.h"

#import "FFFlipsideHighscoresController.h"
#import "FFFlipsideMyDropsController.h"
#import "FFFlipsideInstructionsController.h"

@implementation FFFlipsideViewController

@synthesize delegate=_delegate;
@synthesize uploader;
@synthesize tabBarController;

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];  
    [self.view addSubview: self.tabBarController.view];

    [[[self.tabBarController viewControllers ]objectAtIndex:0] setFlipsideController:self];
    [[[self.tabBarController viewControllers ]objectAtIndex:1] setFlipsideController:self];
    [[[self.tabBarController viewControllers ]objectAtIndex:2] setFlipsideController:self];
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

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)login:(id)sender
{
    NSLog(@"logging in");
    [self.uploader login:sender];
}

- (IBAction)logout:(id)sender
{
    NSLog(@"logging out");
    [self.uploader logout:sender];
}

@end
