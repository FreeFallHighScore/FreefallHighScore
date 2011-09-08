//
//  FFFlipsideController.m
//  FreefallHighscore
//
//  Created by James George on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFFlipsideController.h"
#import "FFFlipsideViewController.h"
#import "FFUtilities.h"

@implementation FFFlipsideController

@synthesize flipsideController;
@synthesize loginButton;
@synthesize loggedIn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    BOOL accountLinked = [[[self flipsideController] uploader] accountLinked];
    loggedIn = [[[self flipsideController] uploader] loggedIn];
    
    NSLog(@"User is logged in: %d", loggedIn);
    if (loggedIn) {
        if(accountLinked){
        	[loginButton setTitle:[self.flipsideController.uploader youtubeUserName]];
        }
        else{
	        [loginButton setTitle:@"Setup Youtube"];
        }
    }
    else{
        [loginButton setTitle:@"Log in"];
    }
}

- (void) userDidLogIn:(id)sender
{
	[self refreshLoginButton] ;
}

- (void) userDidLogOut:(id)sender
{
    [self refreshLoginButton];
}

/*
- (NSString*) shortAccountName
{
    return [[[self flipsideController] uploader] accountNameShort];
}

- (NSString*) fullAccountName
{
    return [[[self flipsideController] uploader] accountName];
}
*/

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
    NSLog(@"******** showing the view named");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogIn:)
                                                 name:kFFUserDidLogin
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogOut:)
                                                 name:kFFUserDidLogout
                                               object:nil];

    [self refreshLoginButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshLoginButton];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFFUserDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFFUserDidLogout object:nil];

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
