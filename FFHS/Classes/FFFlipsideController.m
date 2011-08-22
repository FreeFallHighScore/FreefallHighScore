//
//  FFFlipsideController.m
//  FreefallHighscore
//
//  Created by James George on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFFlipsideController.h"
#import "FFFlipsideViewController.h"

@implementation FFFlipsideController

@synthesize flipsideController;
@synthesize loginButton;
@synthesize loggedIn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

- (IBAction)done:(id)sender
{
    [self.flipsideController done:sender];
}

- (IBAction)login:(id)sender
{
    [self.flipsideController login:sender];
}

- (void) refreshLoginButton
{
    loggedIn = [[[self flipsideController] uploader] loggedIn];
    
    NSLog(@"User is logged in: %d", loggedIn);
    if (loggedIn) {        
        [loginButton setTitle:[self shortAccountName]];
    }
    else{
        [loginButton setTitle:@"Log in"];
    }
}

- (NSString*) shortAccountName
{
    NSString *accountName = [self fullAccountName];
    return (NSString*)[[accountName componentsSeparatedByString:@"@"] objectAtIndex:0];
}

- (NSString*) fullAccountName
{
    return [[[self flipsideController] uploader] accountName];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshLoginButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshLoginButton];
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

@end
