/*
     File: AVCamViewController.m
 Abstract: A view controller that coordinates the transfer of information between the user interface and the capture manager.
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */
#import <AVFoundation/AVFoundation.h>

#import "FFMainViewController.h"
#import "AVCamCaptureManager.h"
#import "AVCamRecorder.h"
#import "AccelerometerFilter.h"
#import "FFTrackLocation.h"
#import "FFVideoOverlay.h"
#import "FFAccelerometerSample.h"
#import "FFYoutubeUploader.h"
#import "FFWidgetOverlays.h"

#define kUpdateFrequency 120.0
#define kRecordingTimeout 20. 


@interface FFMainViewController () <UIGestureRecognizerDelegate>
@end

@interface FFMainViewController (InternalMethods)

- (void) setupFirstView;
- (void)updateViewFromState:(FFGameState)fromState toState:(FFGameState)toState;

- (void)hideStripeOverlay;
- (void)showStripeOverlay;

- (void) hideElementOffscreenLeft:(UIView*)element;
- (void) hideElementOffscreenRight:(UIView*)element;
- (void) hideElementToTop:(UIView*)element withRoom:(CGFloat)padding;
- (void) hideElementToBottom:(UIView*)element withRoom:(CGFloat)padding;
- (void) revealElementFromLeft:(UIView*)element;
- (void) revealElementFromRight:(UIView*)element;
- (void) revealElementFromTop:(UIView*)element toPosition:(CGFloat)yPos;
- (void) revealElementFromBottom:(UIView*)element;

//- (void) moveWhiteTabToY:(CGFloat)targetY;
//- (void) resizeWhiteTabToFrame:(CGRect)targetFrame;
//- (void) revertWhiteTab;
- (NSString*) scoreText;
- (NSString*) scoreSayingTextLine1;
- (NSString*) scoreSayingTextLine2;

- (void) transitionScoreViewToSubmitMode;

- (void)changeState:(FFGameState)newState;
- (NSString*) stateDescription; 

@end

@interface FFMainViewController (AVCamCaptureManagerDelegate) <AVCamCaptureManagerDelegate>
- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error;
- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager;
- (BOOL)captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager toURL:(NSURL*)temporaryURL;
- (void)captureManagerRecordingSaved:(AVCamCaptureManager *)captureManager toURL:(NSURL*)assetURL;
- (void)captureManagerRecordingCanceled:(AVCamCaptureManager *)captureManager;
- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager;
@end

@interface FFMainViewController (FFYoutubeUploaderDelegate) <FFYoutubeUploaderDelegate>
- (void) userDidSignIn:(NSString*)userName;
- (void) userDidSignOut;
- (void) uploadReachedProgess:(CGFloat)progress;
- (void) uploadCompleted;
- (void) uploadFailedWithError:(NSError*)error;
@end

@implementation FFMainViewController

@synthesize captureManager;
@synthesize videoPreviewView;
@synthesize captureVideoPreviewLayer;
@synthesize filter;

@synthesize freefallDuration;
@synthesize freefallStartTime;
@synthesize freefallEndTime;
@synthesize player;
@synthesize playerLayer;
@synthesize assetForOverlay;

@synthesize dropButton;
@synthesize cancelDropButton;
@synthesize deleteDropButton;
@synthesize retryDropButton;
@synthesize submitButton;
@synthesize infoButton;
@synthesize playVideoButton;
@synthesize whatButton;
@synthesize recordingFlash;

@synthesize leftStripeContainer;
@synthesize bottomStripeContainer;
@synthesize rightStripeContainer;
@synthesize whiteTabView;
@synthesize blackTabView;
@synthesize dropNowTextContainer;
@synthesize scoreTextContainer;
@synthesize blackTabLogo;
@synthesize whiteTabLogo;

@synthesize dropscoreScoreViewLabel;
@synthesize dropscoreSubmitViewLabel;
@synthesize dropscoreSayingLabel;

@synthesize trackLoc;
@synthesize introLoginButton;
@synthesize videoOverlay;
@synthesize acceleromterData;
@synthesize recordStartTime;
@synthesize uploader;
@synthesize currentDropAssetURL;
@synthesize submitScoreView;
@synthesize videoTitle;
@synthesize videoStory;
@synthesize cancelSubmitButton;
@synthesize loginButton;
@synthesize uploadProgressView;
@synthesize uploadProgressBar;
@synthesize widgetOverlayLayer;

- (void)dealloc
{
	[captureManager release];
    [videoPreviewView release];
	[captureVideoPreviewLayer release];
    
    [super dealloc];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft];
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)viewDidLoad
{
    //pixel shows up shifted by one for some reason....
    bottomStripeContainer.frame = CGRectMake(bottomStripeContainer.frame.origin.x+.5, bottomStripeContainer.frame.origin.y, 
                                             bottomStripeContainer.frame.size.width, bottomStripeContainer.frame.size.height);

    UIView *view = [self videoPreviewView];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];

    NSLog(@"view did load G");
    
    if(self.uploader == nil){
        self.uploader = [[FFYoutubeUploader alloc] init];
        self.uploader.delegate = self;
        self.uploader.toplevelController = self;
        [uploader release];
    }
    
    // location stuff
    if(self.trackLoc == nil){
        self.trackLoc = [[FFTrackLocation alloc] init];
        [self.trackLoc setupLocation];
        [trackLoc release];
    }
    
    if(self.videoOverlay == nil){
        self.videoOverlay = [[FFVideoOverlay alloc] init];
        self.videoOverlay.delegate = self;
        [videoOverlay release];
    }
    

	if (self.captureManager == nil) {
		self.captureManager = [[AVCamCaptureManager alloc] init];
		self.captureManager.delegate = self;
		[captureManager release];
		
		if ([[self captureManager] setupSession]) {
            // Create video preview layer and add it to the UI
			AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
			[newCaptureVideoPreviewLayer setFrame:CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.height, bounds.size.width)];
			
            NSLog(@"Preview bounds %f %f %f %f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);

			if ([newCaptureVideoPreviewLayer isOrientationSupported]) {
				//[newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
                [newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationLandscapeLeft];
			}
			
			[newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
			
			[viewLayer insertSublayer:newCaptureVideoPreviewLayer 
                                below:[[viewLayer sublayers] objectAtIndex:0]];

			[self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
            [newCaptureVideoPreviewLayer release];
			
            // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[[self captureManager] session] startRunning];
                CGSize cameraSize = [self.captureManager cameraSize];
                NSLog(@"Capture manager bounds %f %f", cameraSize.width, cameraSize.height);
			});
            
            /*
             fontcolor = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] retain];

            if (YES || launchCount == 1 ){
                NSLog(@"this is the FIRST LAUNCH of the app");
                //LOG IN BUTTON
                self.introLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
                introLoginButton.adjustsImageWhenHighlighted = NO;
                [introLoginButton setTitle:@"LOG IN" forState:(UIControlStateNormal)];
                [introLoginButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
                [introLoginButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 00.0, 0.0, 0.0)];
                
                UIImage* introLogIn = [UIImage imageNamed:@"about_button_base"];
                [introLoginButton setBackgroundImage:introLogIn forState:UIControlStateNormal];
                [introLoginButton setBackgroundImage:introLogIn forState:UIControlStateHighlighted];
                
                introLoginButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:30];
                [introLoginButton setTitleColor:fontcolor 
                                   forState:UIControlStateNormal];
                CGSize introImageSize = [introLogIn size];
                //introLoginButton.frame = CGRectMake(bounds.size.width/2 - introImageSize.width/2 , bounds.size.height*.45, introImageSize.width, introImageSize.height);
                introLoginButton.frame = CGRectMake(0, bounds.size.height*.45, introImageSize.width, introImageSize.height);
                [introLoginButton addTarget:self.uploader 
                                     action:@selector(login:) 
                           forControlEvents:UIControlEventTouchUpInside];
                
                [self.view addSubview:introLoginButton];
            }
            */
            
            /*
            //DROP BUTTON
            self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
            recordButton.adjustsImageWhenHighlighted = NO;
            [recordButton setTitle:@"DROP" forState:(UIControlStateNormal)];
            [recordButton setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
            [recordButton setTitleEdgeInsets:UIEdgeInsetsMake(10.0, 00.0, 0.0, 0.0)];

            recordButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:30];
            
            //recordButton.titleLabel.font = [UIFont fontWithName:@"G.B.BOOT" size:60];
            [recordButton setTitleColor:fontcolor 
                               forState:UIControlStateNormal];
            recordButton.titleLabel.textAlignment = UITextAlignmentCenter;
            UIImage* dropButtonImage = [UIImage imageNamed:@"drop_button_base"];
            [recordButton setBackgroundImage:dropButtonImage forState:UIControlStateNormal];
            [recordButton setBackgroundImage:dropButtonImage forState:UIControlStateHighlighted];
            [recordButton addTarget:self
                             action:@selector(startRecording:) 
                   forControlEvents:UIControlEventTouchUpInside];
            
            CGSize imageSize = [dropButtonImage size];
            //recordButton.frame = CGRectMake(bounds.size.width/2 - imageSize.width/2 , bounds.size.height*.6, imageSize.width, imageSize.height);
            recordButton.frame = CGRectMake(0, bounds.size.height*.6, imageSize.width, imageSize.height);
            
            [self.view addSubview:recordButton];			
             */
            
            /*
            //SUBMIT BUTTON
            self.submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
            submitButton.adjustsImageWhenHighlighted = NO;
            [submitButton setTitle:@"SUBMIT" forState:(UIControlStateNormal)];
            submitButton.titleLabel.font = [UIFont fontWithName:@"G.B.BOOT" size:50];
            submitButton.titleLabel.textColor = fontcolor;
            submitButton.titleLabel.textAlignment = UITextAlignmentCenter;
            
            UIImage* submitButtonImage = [UIImage imageNamed:@"submit_button_base"];
            [submitButton setBackgroundImage:submitButtonImage forState:UIControlStateNormal];
            [submitButton setBackgroundImage:submitButtonImage forState:UIControlStateHighlighted];
            submitButton.frame = CGRectMake(0, bounds.size.height*.2, submitButtonImage.size.width, submitButtonImage.size.height);

            [submitButton addTarget:self
                             action:@selector(submitCurrentVideo:) 
                   forControlEvents:UIControlEventTouchUpInside];
            
            submitButton.hidden = YES;
            submitButton.enabled = NO;
            [self.view addSubview:submitButton];			
            
            //DROP AGAIN BUTTON
            self.ignoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
            ignoreButton.adjustsImageWhenHighlighted = NO;

            [ignoreButton setTitle:@"DROP AGAIN" forState:(UIControlStateNormal)];
            ignoreButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:25];
            ignoreButton.titleLabel.textColor = fontcolor;
            ignoreButton.titleLabel.textAlignment = UITextAlignmentCenter;

            UIImage* dropAgainButtonImage = [UIImage imageNamed:@"drop_again_button_base"];
            [ignoreButton setBackgroundImage:dropAgainButtonImage forState:UIControlStateNormal];
            [ignoreButton setBackgroundImage:dropAgainButtonImage forState:UIControlStateHighlighted];
            ignoreButton.frame = CGRectMake(0, bounds.size.height*.75, dropAgainButtonImage.size.width, dropAgainButtonImage.size.height);

            [ignoreButton addTarget:self
                             action:@selector(discardCurrentVideo:) 
                   forControlEvents:UIControlEventTouchUpInside];

            ignoreButton.hidden = YES;
            ignoreButton.enabled = NO;

            [self.view addSubview:ignoreButton];

            //CANCEL BUTTON!!!
            self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelButton.adjustsImageWhenHighlighted = NO;
            [cancelButton setTitle:@"CANCEL" forState:(UIControlStateNormal)];
            
            cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:25];
            [cancelButton setTitleColor:fontcolor 
                               forState:UIControlStateNormal];
            recordButton.titleLabel.textAlignment = UITextAlignmentCenter;
            UIImage* cancelButtonImage = [UIImage imageNamed:@"cancel_button_base"];
            [cancelButton setBackgroundImage:cancelButtonImage forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:cancelButtonImage forState:UIControlStateHighlighted];
            [cancelButton addTarget:self
                             action:@selector(cancelRecording) 
                   forControlEvents:UIControlEventTouchUpInside];
            
            CGSize cancelButtonImageSize = [cancelButtonImage size];
            cancelButton.frame = CGRectMake(bounds.size.width - cancelButtonImageSize.width, bounds.size.height*.8, 
                                            cancelButtonImageSize.width, cancelButtonImageSize.height);
            cancelButton.hidden = YES;
            cancelButton.enabled = NO;
            [self.view addSubview:cancelButton];			
            */

			//YOUR SCORE LABEL     
            /*
            dropscoreLabelTop = [[UILabel alloc] initWithFrame:CGRectMake(0, middle.y-140, bounds.size.width, 140.0)];
            dropscoreLabelTop.text = @"YOUR.SCORE:";
            dropscoreLabelTop.font = [UIFont fontWithName:@"G.B.BOOT" size:30];
            dropscoreLabelTop.backgroundColor = [UIColor clearColor];
            dropscoreLabelTop.textColor = fontcolor;
            dropscoreLabelTop.textAlignment = UITextAlignmentCenter;
            [self.view addSubview:dropscoreLabelTop];

            dropscoreLabelTime = [[UILabel alloc] initWithFrame:CGRectMake(0, middle.y-100, bounds.size.width, 140.0)];
            dropscoreLabelTime.text = @"2.06s";
            dropscoreLabelTime.font = [UIFont fontWithName:@"G.B.BOOT" size:75];
            dropscoreLabelTime.backgroundColor = [UIColor clearColor];
            dropscoreLabelTime.textColor = fontcolor;
            dropscoreLabelTime.textAlignment = UITextAlignmentCenter;
            [self.view addSubview:dropscoreLabelTime];
            */
            

                        
            //timer layer
            
            // Add a single tap gesture to focus on the point tapped, then lock focus
//			UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
//			[singleTap setDelegate:self];
//			[singleTap setNumberOfTapsRequired:1];
//			[view addGestureRecognizer:singleTap];
			
            // Add a double tap gesture to reset the focus mode to continuous auto focus
//			UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
//			[doubleTap setDelegate:self];
//			[doubleTap setNumberOfTapsRequired:2];
//			[singleTap requireGestureRecognizerToFail:doubleTap];
//			[view addGestureRecognizer:doubleTap];
//			
//			[doubleTap release];
//			[singleTap release];
		}		
	}
    
    
    
    NSUserDefaults      *defaults;
    NSInteger           launchCount;
    
    defaults = [NSUserDefaults standardUserDefaults];
    launchCount = [defaults integerForKey:@"launchCount" ] + 1;
    [defaults setInteger:launchCount forKey:@"launchCount"];
    [defaults synchronize];
    
    screenBounds = bounds;
    widgetOverlayLayer = [FFWidgetOverlays layer];
    widgetOverlayLayer.frame = bounds;
    [[self.view layer] addSublayer:widgetOverlayLayer];
    
    NSLog(@"number of times: %i the app has been launched", launchCount);
    firstLoad = (launchCount == 1);
    [self setupFirstView];
    
    //accelerometer stuff    
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / kUpdateFrequency];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
    //filter = [[LowpassFilter alloc] initWithSampleRate:kUpdateFrequency cutoffFrequency:5.0];
    
    [super viewDidLoad];
}

- (void)flipsideViewControllerDidFinish:(FFFlipsideViewController *)controller
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[self captureManager] session] startRunning];
    });        

    [self dismissModalViewControllerAnimated:YES];
    self.uploader.toplevelController = self;
}

- (IBAction)showInfo:(id)sender
{    
    FFFlipsideViewController *controller = [[FFFlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    controller.uploader = uploader;

    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
    self.uploader.toplevelController = controller;
    
    [controller release];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[self captureManager] session] stopRunning];
    });        
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// UIAccelerometerDelegate method, called when the device accelerates.
- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	// Update the accelerometer graph view
    //[filter addAcceleration:acceleration];
    
    
    //NSLog(@"Accelerometer data is %f %f %f", filter.x, filter.y, filter.z);
    
    //...
    //CGFloat accelMagnitude = sqrtf(filter.x*filter.x + filter.y*filter.y + filter.z*filter.z);
    CGFloat accelMagnitude = sqrtf(acceleration.x*acceleration.x + 
                                   acceleration.y*acceleration.y + 
                                   acceleration.z*acceleration.z);
    
    
    if([self listenToAccel]){
        
        if([self isRecording]){
            FFAccelerometerSample* newSample = [FFAccelerometerSample sample];
            newSample.time = [[NSDate date] timeIntervalSinceDate:self.recordStartTime];
            newSample.x = acceleration.x;
            newSample.y = acceleration.y;
            newSample.z = acceleration.z;
            newSample.magnitude = accelMagnitude;
            [acceleromterData addObject:newSample];
            
            if(state != kFFStateInFreeFall){
                if(newSample.time > kRecordingTimeout){
                    NSLog(@"recording timed out!");
                    [self cancelRecording:nil];
                }
            }
        }
        
        if(state == kFFStateInFreeFall){
           freefallDuration = -[freefallStartTime timeIntervalSinceNow];
        }
        
        //check if we are freefall
        if(state != kFFStateInFreeFall){
            if(accelMagnitude < .2 && framesInFreefall++ > 10){
                self.freefallStartTime = [NSDate date];
                
                //Force recording if we arent already
                if(![self isRecording]){
                    [self startRecording:nil];
                }
                
                [widgetOverlayLayer removeDropTimer];                
                [self changeState: kFFStateInFreeFall];
                framesOutOfFreefall = 0;
            }
            else{
//                framesInFreefall = 0;
            }
        }
        else if(state == kFFStateInFreeFall){
            if(accelMagnitude >= .2 && framesOutOfFreefall++ > 10){
	            [self changeState:kFFStateFinishedDropPostroll];
                self.freefallEndTime = [NSDate date];
                [self performSelector:@selector(finishRecordingAfterFall) withObject:self afterDelay:.5];
            }
            else{
                //framesOutOfFreefall = 0;
            }
        }
    }
}

- (void)submitCurrentVideo:(id)sender
{ 
    [self changeState:kFFStateFinishedDropSubmitView];
    /*
    NSLog(@"logged in? %d user name %@ ", self.uploader.loggedIn, self.uploader.accountName);
    
    if(self.uploader.loggedIn){
        //[self.uploader showAlert:@"LOGIN TEXT" withMessage:self.uploader.accountName];
        [self.loginButton setTitle:self.uploader.accountName 
                          forState:UIControlStateNormal];
        [self.loginButton setTitle:self.uploader.accountName 
                          forState:UIControlStateDisabled];

    }
    else {
        //[self.uploader showAlert:@"LOGIN TEXT" withMessage:@"you need to log in"];
        [self.loginButton setTitle:@"Log in"
                          forState:UIControlStateNormal];
    }    
    
    [self.player pause];

    showingScoreView = YES;
    [self updateViewState];
     */
}

- (IBAction) playVideo:(id)sender
{
    if(state == kFFStateFinishedDropScoreView){
        [self.player play];
        [self changeState:kFFStateFinishedDropVideoPlayback];
    }
    else{
        ShowAlert(@"State Error", [NSString stringWithFormat:@"trying to play video without score view shown. %@", [self stateDescription] ]);
    }
}
 


- (void) textFieldShouldReturn:(UITextField*)field
{
    if(field == self.videoTitle){
        [self.videoStory becomeFirstResponder];
    }
    else if(field == self.videoStory){
        if([self.videoTitle.text isEqualToString:@""]){
            [self.videoTitle becomeFirstResponder];    
        }
        if([self.videoStory.text isEqualToString:@""]){
            //do nothing...
        }
        else {
            [self completeSubmit];
        }
    }
}

- (void) completeSubmit
{
    if(!self.uploader.loggedIn){
        NSLog(@"ERROR - Somehow trying to submit when not logged in!");
        return;
    }
    
    if(!libraryAssetURLReceived){
        NSLog(@"ERROR - haven't received library asset yet!");
        return;        
    }
    
    NSLog(@"Starting upload with URL %@", self.currentDropAssetURL);


    [self changeState:kFFStateFinishedDropUploading];
    
    self.uploader.location = trackLoc.location;
    self.uploader.fallDuration = freefallDuration; 
    self.uploader.videoTitle = self.videoTitle.text;
    self.uploader.videoDescription = self.videoStory.text;
    [self.uploader startUploadWithURL:self.currentDropAssetURL];

}

- (IBAction)login:(id)sender
{
    [self.uploader login:sender];
}

- (IBAction)cancelSubmit:(id)sender
{
    if(state == kFFStateFinishedDropUploading){
        [self.uploader cancelUpload:sender];
        [self changeState:kFFStateFinishedDropSubmitView];
    }
    else if(state == kFFStateFinishedDropSubmitView){
        [self changeState:kFFStateFinishedDropScoreView];
    }
    /*
    if(self.uploader.uploading){
        NSLog(@"Cancelling upload!");
        [self.uploader cancelUpload:sender];
        self.loginButton.enabled = YES;
        self.videoTitle.enabled = YES;
        self.videoStory.enabled = YES;
        [self removeUploadProgressView];
        [self.videoTitle becomeFirstResponder];
    }
    else {
         NSLog(@"Removing view!");
        [self removeSubmitView];
    }
     */
}

- (void) removeSubmitView
{
    [self.submitScoreView removeFromSuperview];
    self.submitScoreView = nil;
//    showingScoreView = false;
//    [self updateViewState];
}

- (void) removeUploadProgressView
{
    [self.uploadProgressView removeFromSuperview];
    self.uploadProgressView = nil;    
}

//This is called when the user is done with the video
//either ignore it after a fall, or after it's been submitted
- (void)discardCurrentVideo:(id)sender
{

    if([self hasDropVideo]){
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[self.player currentItem]];
        
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
        self.player = nil;
        timesLooped = 0;
        
        UIView *view = [self videoPreviewView];
        CALayer *viewLayer = [view layer];
        [viewLayer setMasksToBounds:YES];        
        [viewLayer insertSublayer:captureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[[self captureManager] session] startRunning];
        });
        
//        didFall = NO;
        freefallDuration = 0;
        
        [self changeState:kFFStateReadyToDrop];
        
        //TODO delete assets from library
    }
    
}

- (IBAction) prepareToDrop:(id)sender
{
    [self startRecording:sender];
    [self changeState:kFFStatePreDropRecording];
}

- (void)startRecording:(id)sender
{
    if(state == kFFStateReadyToDrop || state == kFFStatePreDropCanceled){   
    	[[self captureManager] startRecording];
        self.recordStartTime = [NSDate date];
        self.acceleromterData = [NSMutableArray arrayWithCapacity:200];
        [widgetOverlayLayer setTimerWithStartTime:self.recordStartTime forDuration:kRecordingTimeout];
    }
    else{
        ShowAlert(@"State Error", [NSString stringWithFormat:@"Started recording with faulty state. %@", [self stateDescription]]);
    }
}

- (void) cancelRecording:(id)sender
{
    if(state == kFFStatePreDropRecording){
        CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
            [self changeState: kFFStatePreDropCancelling];
            [widgetOverlayLayer removeDropTimer];
            [[self captureManager] cancelRecording];
        });
    }
    else{
        ShowAlert(@"State Error", [NSString stringWithFormat:@"Canceling recording with faulty state. %@", [self stateDescription]] );
    }
}

- (void)finishRecordingAfterFall
{   
    //tell the recorder to stop, this will result in the recording stopped callback
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [[self captureManager] stopRecording];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[[self captureManager] session] stopRunning];
        });        
    });    
}

- (BOOL) listenToAccel
{
    return state == kFFStateReadyToDrop || state == kFFStatePreDropRecording || state == kFFStateInFreeFall;
}

- (BOOL) isRecording
{
    return state == kFFStatePreDropRecording || state == kFFStateInFreeFall || state == kFFStateFinishedDropPostroll;
}

- (BOOL) hasDropVideo
{
    return  state == kFFStateFinishedDropVideoPlayback ||
            state == kFFStateFinishedDropScoreView ||
            state == kFFStateFinishedDropSubmitView ||
            state == kFFStateFinishedDropUploading ||
            state == kFFStateFinishedDropUploadComplete;
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if (context == AVCamFocusModeObserverContext) {
//        // Update the focus UI overlay string when the focus mode changes
////		[focusModeLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:(AVCaptureFocusMode)[[change objectForKey:NSKeyValueChangeNewKey] integerValue]]]];
//	} else {
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
//}

//#pragma mark Toolbar Actions
//- (IBAction)toggleCamera:(id)sender
//{
//    // Toggle between cameras when there is more than one
//    [[self captureManager] toggleCamera];
//    
//    // Do an initial focus
//    [[self captureManager] continuousFocusAtPoint:CGPointMake(.5f, .5f)];
//}


- (void) overlayReachedPercent:(CGFloat)percentComplete
{
    widgetOverlayLayer.exportPercent = percentComplete;
}

//JG NOTE THIS IS NO LONGER USED
- (void) overlayComplete:(NSURL*)assetURL
{
    /*
    NSLog(@"overlay complete!! %@", assetURL);

    [widgetOverlayLayer stopDrawingExport];
    
    self.player = [AVPlayer playerWithURL:assetURL];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];    
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone; 
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
    
    //TODO: fix orientation...maybe?
//    [self.player play];
    
    UIView *view = [self videoPreviewView];
    CALayer *viewLayer = [view layer];        
    
    //CGRect bounds = [view bounds];
    CGRect bounds = CGRectMake(-20, 0, 480, 360);//fullscreen it
    //CGRect bounds = CGRectMake(0, -20, 480, 360);//fullscreen it
    [self.playerLayer setFrame:bounds];
    
    [self animateScoreViewOn];    
    [viewLayer insertSublayer:self.playerLayer above:[self captureVideoPreviewLayer] ];
    */

}

- (void) overlayCopyComplete:(NSURL*)assetURL
{
//    self.currentDropAssetURL = assetURL;   
//    libraryAssetURLReceived = YES;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    //LOOP
    if(state == kFFStateFinishedDropVideoPlaybackFirstLoop){
        [self changeState:kFFStateFinishedDropScoreView];
    }
    else {
        AVPlayerItem *p = [notification object];
        [p seekToTime:kCMTimeZero];
        timesLooped++;
    }    
}

@end

@implementation FFMainViewController (InternalMethods)


- (void) setupFirstView
{
    //TODO: play intro animation
    state = kFFStateJustOpened;
    
    //hide all the buttons off screen
    [self hideElementOffscreenLeft:self.introLoginButton];
    [self hideElementOffscreenLeft:self.dropButton];
    [self hideElementOffscreenLeft:self.whatButton];
    [self hideElementOffscreenLeft:self.submitButton];
    [self hideElementOffscreenLeft:self.playVideoButton];
    [self hideElementOffscreenLeft:self.playVideoButton];
    
    [self hideElementOffscreenRight:self.blackTabView];    
    [self hideElementOffscreenRight:self.cancelDropButton];
    [self hideElementOffscreenRight:self.deleteDropButton]; 
    [self hideElementOffscreenRight:self.retryDropButton];    
    
    whiteTabBaseRect = self.whiteTabView.frame;
    dropBaseRect = self.dropButton.frame;
    
    [self moveWhiteTabToY:0];
    
//    BOOL showRightPanel = NO;
    if(!self.uploader.loggedIn || firstLoad){
//        showRightPanel = YES;
        self.whiteTabLogo.alpha = 0;
        self.infoButton.alpha = 0;
    }
    
    [self changeState:kFFStateReadyToDrop];
    
}

- (void) moveWhiteTabToY:(CGFloat)targetY
{
    whiteTabView.frame = CGRectMake(whiteTabView.frame.origin.x, targetY-whiteTabView.frame.size.height, 
                                    whiteTabView.frame.size.width, whiteTabView.frame.size.height);
    bottomStripeContainer.frame = CGRectMake(bottomStripeContainer.frame.origin.x, targetY, 
                                             bottomStripeContainer.frame.size.width, screenBounds.size.height-targetY);
}
     
/*
- (void) resizeWhiteTabToFrame:(CGRect)targetFrame
{
    whiteTabCachedRect = whiteTabView.frame;
    
    whiteTabView.frame = targetFrame;
    
    bottomStripeContainer.frame = CGRectMake(targetFrame.origin.x, targetFrame.size.height, 
                                             targetFrame.size.width, screenBounds.size.height-targetFrame.size.height);
    
    leftStripeContainer.frame = CGRectMake(0, 0, 
                                           targetFrame.origin.x, screenBounds.size.height);
    
    rightStripeContainer.frame = CGRectMake(targetFrame.origin.x+targetFrame.size.width, 0, 
                                            screenBounds.size.width-targetFrame.origin.x+targetFrame.size.width, screenBounds.size.height);
}
*/

/*
- (void) revertWhiteTab
{
    [self resizeWhiteTabToFrame:whiteTabCachedRect];
}
*/

- (void) hideElementToTop:(UIView*)element withRoom:(CGFloat)padding
{
    element.frame = CGRectMake(element.frame.origin.x, padding - element.frame.size.height,
                               element.frame.size.width, element.frame.size.height);
}

- (void) hideElementToBottom:(UIView*)element withRoom:(CGFloat)padding
{
    element.frame = CGRectMake(element.frame.origin.x, screenBounds.size.height - padding,
                               element.frame.size.width, element.frame.size.height);
}

- (void) revealElementFromTop:(UIView*)element toPosition:(CGFloat)yPos
{
    element.frame = CGRectMake(element.frame.origin.x, yPos,
                               element.frame.size.width, element.frame.size.height);
}

- (void) revealElementFromBottom:(UIView*)element
{
    element.frame = CGRectMake(element.frame.origin.x, screenBounds.size.height - element.frame.size.height,
                               element.frame.size.width, element.frame.size.height);    
}

- (void) revealElementFromLeft:(UIView*)element
{
    element.frame = CGRectMake(0, element.frame.origin.y, 
                               element.frame.size.width, element.frame.size.height);
}

- (void) revealElementFromRight:(UIView*)element
{
    element.frame = CGRectMake(screenBounds.size.width-element.frame.size.width, element.frame.origin.y, 
                               element.frame.size.width, element.frame.size.height);    
}

- (void) hideElementOffscreenLeft:(UIView*)element
{
    element.frame = CGRectMake(-element.frame.size.width, element.frame.origin.y, 
                               element.frame.size.width, element.frame.size.height);
}


- (void) hideElementOffscreenRight:(UIView*)element
{
    element.frame = CGRectMake(screenBounds.size.width, element.frame.origin.y, 
                               element.frame.size.width, element.frame.size.height);
    
}


// Update button states based on the number of available cameras and mics
- (void) updateViewFromState:(FFGameState)fromState toState:(FFGameState)toState
{    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {

        switch (toState) {
            case kFFStateReadyToDrop:
                [UIView animateWithDuration:.5
                                 animations: ^{
                                     BOOL showRightPanel = NO;
                                     if(firstLoad || !self.uploader.loggedIn){
                                         [self revealElementFromLeft:self.introLoginButton];
                                         showRightPanel = YES;
                                     }
                                     if(firstLoad){
                                         [self revealElementFromLeft:self.whatButton];
                                         showRightPanel = YES;
                                     }
                                     if(showRightPanel){
                                         [self revealElementFromRight:self.blackTabView];
                                     }
                                     
                                     [self moveWhiteTabToY:whiteTabBaseRect.size.height];
                                     [self revealElementFromLeft:self.dropButton];
                                 }
                                 completion:^(BOOL finished){ 
                                     
                                 }];
                break;
                
            case kFFStatePreDropRecording:
                [UIView animateWithDuration:.25
                                 animations: ^{
                                     BOOL showRightPanel = NO;
                                     if(firstLoad || !self.uploader.loggedIn){
                                         [self hideElementOffscreenLeft:self.introLoginButton];
                                     }
                                     if(firstLoad){
                                         [self hideElementOffscreenLeft:self.whatButton];
                                         showRightPanel = YES;
                                     }
                                     if(showRightPanel){
                                         [self hideElementOffscreenRight:self.blackTabView];
                                     }
                                     self.infoButton.alpha = 0.;
                                     [self moveWhiteTabToY:dropNowTextContainer.frame.size.height];
                                     [self hideElementToTop:self.dropButton withRoom:50]; 
                                     [self revealElementFromRight:self.cancelDropButton];
                                     [self hideStripeOverlay];

                                     self.dropNowTextContainer.alpha = 1.0;
                                 }
                                 completion:^(BOOL finished){ 
                                     //TODO: start flasher loops
                                 }];
                
                break;

            case kFFStatePreDropCancelling:
                [UIView animateWithDuration:.25
                                 animations: ^{
                                     BOOL showRightPanel = NO;
                                     if(firstLoad || !self.uploader.loggedIn){
                                         [self revealElementFromLeft:self.introLoginButton];
                                         showRightPanel = YES;
                                     }
                                     if(firstLoad){
                                         [self revealElementFromLeft:self.whatButton];
                                         showRightPanel = YES;
                                     }
                                     else{
                                        self.infoButton.alpha = 1.;
                                     }
                                     
                                     if(showRightPanel){
                                         [self revealElementFromRight:self.blackTabView];
                                     }
                                     [self showStripeOverlay];
                                     self.dropNowTextContainer.alpha = 0.0;
                                 }
                 
                                 completion:^(BOOL finished){ 

                                 }];
                break;
                
            case kFFStatePreDropCanceled:

                [UIView animateWithDuration:.25
                                 animations: ^{
                                     [self hideElementOffscreenRight:self.cancelDropButton];
                                     [self moveWhiteTabToY:whiteTabBaseRect.size.height];                                     
                                     [self revealElementFromTop:self.dropButton toPosition:dropBaseRect.origin.y];
                                 }
                                 completion:^(BOOL finished){ 
                                     
                                 }];
                
                break;
                
            case kFFStateInFreeFall:
                [UIView animateWithDuration:.25
                                 animations: ^{
                                     self.dropButton.alpha = 0.0;
                                     [self hideElementOffscreenRight:self.cancelDropButton];
                                     [self moveWhiteTabToY:0];
                                     self.dropNowTextContainer.alpha = 0.;
                                 }
                                 completion:^(BOOL finished){ 
                                     
                                 }];
                
                break;
            case kFFStatePreDropTimedOut:
                //CURRENTLY UNUSED!
                break;
            case kFFStateFinishedDropPostroll:
                [UIView animateWithDuration:.25
                                 animations: ^{
//                                     [self showStripeOverlay];
                                 }
                                 completion:^(BOOL finished){ 
                                     
                                 }];
                
                break;
//            case kFFStateFinishedDropProcessing:
//                break;
            case kFFStateFinishedDropVideoPlaybackFirstLoop:
                
                break;
            case kFFStateFinishedDropScoreView:
                self.dropscoreScoreViewLabel.text = [self scoreText];
                //TODO populate comment text
                if(self.submitScoreView != nil){
                    [self.videoTitle resignFirstResponder];
                    [self.videoStory resignFirstResponder];
                }
                [UIView animateWithDuration:.25
                                 animations: ^{
                                     [self moveWhiteTabToY:self.scoreTextContainer.frame.size.height];
                                     [self showStripeOverlay];
                                     self.scoreTextContainer.alpha = 1.0;
                                     [self revealElementFromLeft:self.submitButton];
                                     [self revealElementFromLeft:self.playVideoButton];
                                     [self revealElementFromRight:self.deleteDropButton];
                                     if(self.submitScoreView != nil){
                                         [self hideElementToTop:self.submitScoreView withRoom:0];
                                     }
                                 }
                                 completion:^(BOOL finished){ 
                                     
                                 }];
                
                break;                
            case kFFStateFinishedDropVideoPlayback:
                break;
            case kFFStateFinishedDropSubmitView:
                if(fromState == kFFStateFinishedDropScoreView){
                    [self transitionScoreViewToSubmitMode];
                }
                if(fromState == kFFStateFinishedDropUploading){
                    self.loginButton.enabled = YES;
                    self.videoTitle.enabled = YES;
                    self.videoStory.enabled = YES;
                }                
                [self.videoTitle becomeFirstResponder];
                [UIView animateWithDuration:.25
                                 animations: ^{
                                     [self moveWhiteTabToY:0];
                                     [self hideElementOffscreenLeft:self.submitButton];
                                     [self hideElementOffscreenLeft:self.playVideoButton];
                                     [self hideElementOffscreenRight:self.deleteDropButton];
                                     [self revealElementFromTop:self.submitScoreView toPosition:0];
                                     if(self.uploadProgressView != nil){
                                         [self hideElementToBottom:self.uploadProgressView withRoom:0];
                                     }
                                 }
                                 completion:^(BOOL finished){ 
                                     
                                 }];
                 
                break;
            case kFFStateFinishedDropUploading:
                //show progress bar view...
                [self showUploadProgress];
                
                [self.videoTitle resignFirstResponder];
                [self.videoStory resignFirstResponder];
                
                self.loginButton.enabled = NO;
                self.videoTitle.enabled = NO;
                self.videoStory.enabled = NO;
                
                [UIView animateWithDuration:.25
                                 animations: ^{
                                     [self revealElementFromBottom:self.uploadProgressView];                                     
                                 }
                                 completion:^(BOOL finished){ 
                                     
                                 }];

                break;
            case kFFStateFinishedDropUploadComplete:
//                [self showButton:self.dropAgainButton];
//                break;
            default:
                break;
        }    
    });
}


- (NSString*) scoreText
{
    return [NSString stringWithFormat:@"%.03fs", freefallDuration];
}

- (NSString*) scoreSayingTextLine1
{
    return @"";
}

- (NSString*) scoreSayingTextLine2
{
    return @"";    
}

//- (void) populateScoreView:(UILabel*)scoreView
//{
//    self.dropscoreScoreViewLabel.text = [NSString stringWithFormat:@"SCORE: %.03fs", freefallDuration];   
//}

/*
- (void) animateScoreViewOn
{
    if (self.scoreView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ScoreView" owner:self options:nil];        
    }
    
    //hide all normal labels
    self.cancelSubmitButton.alpha = 0.0;
    self.loginButton.alpha = 0.0;
    self.videoTitle.alpha = 0.0;
    self.videoStory.alpha = 0.0;

    scoreRectWithSubmitControls = self.scoreView.frame;
    baseScoreRect = CGRectMake(scoreRectWithSubmitControls.size.width*.1, 0, 
                               scoreRectWithSubmitControls.size.width*.8, scoreRectWithSubmitControls.size.height*.6);
    
    self.scoreView.frame = CGRectMake(baseScoreRect.origin.x, -baseScoreRect.size.height, 
                                      baseScoreRect.size.width, baseScoreRect.size.height);
    
    self.dropscoreLabel.text = [NSString stringWithFormat:@"SCORE: %.03fs", freefallDuration];   
    self.dropscoreSayingLabel.text = @"That's it?";
    self.dropscoreSayingLabel.hidden = NO;
    self.dropscoreSayingLabel.alpha = 1.0;
    
    [self.videoPreviewView insertSubview:self.scoreView 
                            aboveSubview:[self.videoPreviewView.subviews objectAtIndex:0]];
    
    [UIView animateWithDuration:1.0
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{ self.scoreView.frame = baseScoreRect; }
                     completion:^( BOOL finished){ }];
    
    //showingScoreView = YES;
    [self changeState:kFFStateFinishedDropScoreView];
}
*/

- (void) transitionScoreViewToSubmitMode
{
    
    if (self.submitScoreView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ScoreView" owner:self options:nil];   
        [self.videoPreviewView insertSubview:self.submitScoreView 
                                aboveSubview:[self.videoPreviewView.subviews objectAtIndex:0]];
        self.dropscoreSubmitViewLabel.text = [self scoreText];
    }
    if(self.uploader.loggedIn){
        //[self.uploader showAlert:@"LOGIN TEXT" withMessage:self.uploader.accountName];
        [self.loginButton setTitle:self.uploader.accountName 
                          forState:UIControlStateNormal];
        [self.loginButton setTitle:self.uploader.accountName 
                          forState:UIControlStateDisabled];
        
    }
    else {
        //[self.uploader showAlert:@"LOGIN TEXT" withMessage:@"you need to log in"];
        [self.loginButton setTitle:@"Log in"
                          forState:UIControlStateNormal];
    }    
    
    [self hideElementToTop:self.submitScoreView withRoom:0];
 
    self.whiteTabLogo.alpha = 0.0;
}

- (void) showUploadProgress
{
    if (self.uploadProgressView == nil) {
        //TODO animate
        [[NSBundle mainBundle] loadNibNamed:@"UploadProgress" owner:self options:nil];
        [self.videoPreviewView insertSubview:self.uploadProgressView aboveSubview:[self.videoPreviewView.subviews objectAtIndex:0]];
        CGSize progressViewSize = self.uploadProgressView.frame.size;
        CGSize videoViewSize = self.videoPreviewView.frame.size;
        CGRect newFrame = CGRectMake(0, videoViewSize.height-progressViewSize.height, progressViewSize.width, progressViewSize.height);
        self.uploadProgressView.frame = newFrame;
        [self hideElementToBottom:self.uploadProgressView withRoom:0];
    }
    self.uploadProgressBar.progress = 0;
}

- (void) transitionScoreViewToScoreMode
{

    //TODO: configure animation
//    [UIView animateWithDuration:1.0
//                          delay:0
//                        options: UIViewAnimationCurveEaseOut
//                     animations:^{ self.scoreView.frame = scoreRectWithSubmitControls; }
//                     completion:^( BOOL finished){ }];

    
    [self changeState:kFFStateFinishedDropScoreView];
    
}

//- (void) animateScoreViewOff
//{
//    
//}

//- (void)hideLabels
//{
//    [self hideLabel:self.dropscoreLabelTop];
//    [self hideLabel:self.dropscoreLabelBottom];
//    [self hideLabel:self.dropscoreLabelTime];
//}
//
//- (void)showLabels 
//{ 
//    [self showLabel:self.dropscoreLabelTop];
//    [self showLabel:self.dropscoreLabelBottom];
//    [self showLabel:self.dropscoreLabelTime];
//}

- (void) hideStripeOverlay
{
     leftStripeContainer.alpha = 0.0f;
     bottomStripeContainer.alpha = 0.0f;
     rightStripeContainer.alpha = 0.0f;
}

- (void) showStripeOverlay
{
    leftStripeContainer.alpha = 1.0f;
    bottomStripeContainer.alpha = 1.0f;
    rightStripeContainer.alpha = 1.0f;    
}

- (void)changeState:(FFGameState)newState
{
    NSString* oldStateString = [self stateDescription];
    [self updateViewFromState:state toState:newState];
    state = newState;
    NSLog(@"Switching from state %@ to %@", oldStateString, [self stateDescription]);    
}

- (NSString*) stateDescription
{
    switch (state) {
        case kFFStateReadyToDrop:
            return @"Ready to Drop";
        case kFFStatePreDropRecording:
            return @"Drop Prerecording";            
        case kFFStatePreDropCancelling:
            return @"Drop Cancelling";
        case kFFStatePreDropCanceled:
            return @"Drop Canceled";            
        case kFFStateInFreeFall:
            return @"Freefalling!";            
        case kFFStateFinishedDropPostroll:
            return @"Finished Drop Postroll";            
//        case kFFStateFinishedDropProcessing:
//            return @"Finished Drop Processing Video";            
        case kFFStateFinishedDropVideoPlayback:
            return @"Drop Video Playback";            
        case kFFStateFinishedDropScoreView:
            return @"Showing Score View";
        case kFFStateFinishedDropSubmitView:
            return @"Showing Submit View";
        case kFFStateFinishedDropUploading:
            return @"Uploading Video";
        case kFFStateFinishedDropUploadComplete:
            return @"Uploading Complete!";
        default:
            break;
    }
    
    return @"Invalid State";
}

@end //INTERNAL METHODS

@implementation FFMainViewController (AVCamCaptureManagerDelegate)

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
    });
}

- (void)captureManagerRecordingBegan:(AVCamCaptureManager *)captureManager
{
//    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
//        [[self recordButton] setTitle:NSLocalizedString(@"Stop", @"Toggle recording button stop title")];
//        [[self recordButton] setEnabled:YES];
//    });
}

- (BOOL) captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager toURL:(NSURL*)temporaryURL
{
//    [self changeState: kFFStateFinishedDropProcessing];
  /*  
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        
        ///create an overlay asset
        //REMOVED OVERLAY ASSET:
        NSDictionary* assetOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] 
                                                                 forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        
        self.assetForOverlay = [AVURLAsset URLAssetWithURL:temporaryURL
                                                   options:assetOptions];
        
        [self.assetForOverlay loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler: ^(void){
            NSLog(@"assetURL is %@", assetForOverlay.URL);
            [self.videoOverlay createVideoOverlayWithAsset:self.assetForOverlay
                                               fallStarted:[self.freefallStartTime timeIntervalSinceDate:self.recordStartTime]
                                                 fallEnded:[self.freefallEndTime timeIntervalSinceDate:self.recordStartTime] 
                                         accelerometerData:self.acceleromterData];
        }];
        
        libraryAssetURLReceived = NO;
        [widgetOverlayLayer startDrawingExport];
        
    });
    
    //don't save the asset to the library
    return NO;
   */
    
    //tell the phone to save the asset
    libraryAssetURLReceived = NO;
    
    self.player = [AVPlayer playerWithURL:temporaryURL];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];    
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone; 
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
    
    //TODO: fix orientation...maybe?
    //    [self.player play];
    
    UIView *view = [self videoPreviewView];
    CALayer *viewLayer = [view layer];        
    
    //CGRect bounds = [view bounds];
    CGRect bounds = CGRectMake(0, -20, 480, 360);//fullscreen it
    [self.playerLayer setFrame:bounds];
    
    [viewLayer insertSublayer:self.playerLayer above:[self captureVideoPreviewLayer] ];
    
    [self changeState:kFFStateFinishedDropVideoPlaybackFirstLoop];
    
    [self.player play];
    
    return YES;
}

- (void) captureManagerRecordingSaved:(AVCamCaptureManager *)captureManager toURL:(NSURL*)assetURL
{
    //unused, we never save the items directly from the camera to the asset library.
    self.currentDropAssetURL = assetURL;
    libraryAssetURLReceived = YES;
    NSLog(@"video saved to assets!!");
}

- (void) captureManagerRecordingCanceled:(AVCamCaptureManager *)captureManager
{
    [self changeState:kFFStatePreDropCanceled];
    
}

- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager
{
//    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
//        [[self stillButton] setEnabled:YES];
//    });
}

- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
//	[self updateViewState];
}

@end

@implementation FFMainViewController (FFYoutubeUploaderDelegate)

- (void) userDidSignIn:(NSString*)userName
{ 
    if(state == kFFStateFinishedDropSubmitView){
        [self.loginButton setTitle:userName
                          forState:UIControlStateNormal];
        [self.loginButton setTitle:userName
                          forState:UIControlStateDisabled];
    }
}

- (void) userDidSignOut
{
    NSLog(@"user signed out");    
    if(state == kFFStateFinishedDropSubmitView){
        [self.loginButton setTitle:@"Log in"
                          forState:UIControlStateNormal];
    }
    
    [[self uploader] cancelSignin:nil];
}

- (void) uploadReachedProgess:(CGFloat)progress
{
    if(self.uploadProgressBar == nil){
        NSLog(@"ERROR: Upload progress bar null for progress %f", progress);
    }
    else{
        self.uploadProgressBar.progress = progress;
    }
    NSLog(@"uploaded to %f", progress);  
}

- (void) uploadCompleted
{
    if(state == kFFStateFinishedDropUploading){
        [self removeSubmitView];
        [self removeUploadProgressView];
        [self changeState:kFFStateFinishedDropUploadComplete];
        [self discardCurrentVideo:self];
    }
    else {
        ShowAlert(@"State Error", [NSString stringWithFormat:@"Finished uploading with an invalid state %@", [self stateDescription] ]);
    }
}

- (void) uploadFailedWithError:(NSError*)error
{
    if(state == kFFStateFinishedDropUploading){
        [self cancelSubmit:self];
    }
    else{
        ShowAlert(@"State Error", [NSString stringWithFormat:@"Upload failed with invalid state %@", [self stateDescription] ]);
    }
}

@end
