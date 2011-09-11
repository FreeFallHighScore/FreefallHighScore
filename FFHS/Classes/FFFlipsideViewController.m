//
//  FlipsideViewController.m
//  FFHS
//
//  Created by James George on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFFlipsideViewController.h"
#import "HJObjManager.h"

#import "FFFlipsideHighscoresController.h"
#import "FFFlipsideMyDropsController.h"
#import "FFFlipsideInstructionsController.h"
#import "FFYoutubeUploader.h"

@implementation FFFlipsideViewController

@synthesize delegate;
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
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];  
    [self.view addSubview: self.tabBarController.view];

    [[[self.tabBarController viewControllers] objectAtIndex:0] setFlipsideController:self];
    [[[self.tabBarController viewControllers] objectAtIndex:1] setFlipsideController:self];
    [[[self.tabBarController viewControllers] objectAtIndex:2] setFlipsideController:self];
        
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
//    return YES;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)login:(id)sender
{
    FFYoutubeUploader* uploader = (FFYoutubeUploader*)[[UIApplication sharedApplication].delegate uploader];
    [uploader toggleLogin:sender];
}

//
//- (IBAction)logout:(id)sender
//{
//    NSLog(@"logging out");
//    [self.uploader logout:sender];
//}

@end
