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
#define kRecordingTimeout 10. 

static void *AVCamFocusModeObserverContext = &AVCamFocusModeObserverContext;

@interface FFMainViewController () <UIGestureRecognizerDelegate>
@end

@interface FFMainViewController (InternalMethods)
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
- (void) updateButtonStates;
- (void)hideButton:(UIButton *)button;
- (void)showButton:(UIButton *)button;
- (void)hideLabel:(UILabel *)label;
- (void)showLabel:(UILabel *)label;
- (void)hideLabels;
- (void)showLabels;

- (void)hideOverlay;
- (void)showOverlay;

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
@synthesize freefalling;
@synthesize freefallDuration;
@synthesize freefallStartTime;
@synthesize freefallEndTime;
@synthesize player;
@synthesize playerLayer;
@synthesize assetForOverlay;

@synthesize recordButton;
@synthesize ignoreButton;
@synthesize submitButton;
@synthesize cancelButton;
@synthesize infoButton;
@synthesize stripeOverlay;

@synthesize dropscoreLabelTop;
@synthesize dropscoreLabelBottom;
@synthesize dropscoreLabelTime;

@synthesize trackLoc;
@synthesize introLoginButton;
@synthesize videoOverlay;
@synthesize acceleromterData;
@synthesize recordStartTime;
@synthesize uploader;
@synthesize currentDropAssetURL;
@synthesize submitView;
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
    [recordButton release];

    [introLoginButton release];
	[ignoreButton release];
	[submitButton release];
    [dropscoreLabelTop release];
    [dropscoreLabelBottom release];
    [dropscoreLabelTime release];
    
//    [filter release];
    NSLog(@"releasing view");
    
    [super dealloc];
}

- (void)viewDidLoad
{
 
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
			UIView *view = [self videoPreviewView];
			CALayer *viewLayer = [view layer];
			[viewLayer setMasksToBounds:YES];
			
			CGRect bounds = [view bounds];
			[newCaptureVideoPreviewLayer setFrame:bounds];
			
            NSLog(@"Preview bounds %f %f %f %f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);

			if ([newCaptureVideoPreviewLayer isOrientationSupported]) {
				[newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
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
            
            
            CGPoint middle = CGPointMake(bounds.origin.x + bounds.size.width/2.0, 
                                         bounds.origin.y + bounds.size.height/2.0);
            
            fontcolor = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] retain];
        
            NSUserDefaults      *padFactoids;
            int                 launchCount;
            
            padFactoids = [NSUserDefaults standardUserDefaults];
            launchCount = [padFactoids integerForKey:@"launchCount" ] + 1;
            [padFactoids setInteger:launchCount forKey:@"launchCount"];
            [padFactoids synchronize];
            
            NSLog(@"number of times: %i the app has been launched", launchCount);
            
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
                
                introLoginButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:35];
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
            
            
            //DROP BUTTON
            self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
            recordButton.adjustsImageWhenHighlighted = NO;
            [recordButton setTitle:@"DROP" forState:(UIControlStateNormal)];
            [recordButton setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
            [recordButton setTitleEdgeInsets:UIEdgeInsetsMake(10.0, 00.0, 0.0, 0.0)];

            recordButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:35];
            
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
            
            submitButton.hidden =   YES;
            submitButton.enabled = NO;
            [self.view addSubview:submitButton];			
            
            //DROP AGAIN BUTTON
            self.ignoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
            ignoreButton.adjustsImageWhenHighlighted = NO;
            ignoreButton.frame = CGRectMake(0, middle.y+100, bounds.size.width, 140.0);
            [ignoreButton setTitle:@"DROP..A.GAIN" forState:(UIControlStateNormal)];
            ignoreButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40];
            ignoreButton.titleLabel.textColor = fontcolor;
            ignoreButton.titleLabel.textAlignment = UITextAlignmentCenter;

            [ignoreButton addTarget:self
                             action:@selector(discardCurrentVideo:) 
                   forControlEvents:UIControlEventTouchUpInside];

            [self.view addSubview:ignoreButton];

            //CANCEL BUTTON!!!
            self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelButton.adjustsImageWhenHighlighted = NO;
            [cancelButton setTitle:@"CANCEL" forState:(UIControlStateNormal)];
            
            cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:35];
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
            cancelButton.frame = CGRectMake(bounds.size.width/2 - cancelButtonImageSize.width/2, bounds.size.height*.8, cancelButtonImageSize.width, cancelButtonImageSize.height);
            cancelButton.hidden = YES;
            cancelButton.enabled = NO;
            [self.view addSubview:cancelButton];			
            

			//YOUR SCORE LABEL            
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

            [self updateButtonStates];
                        
            //timer layer
            widgetOverlayLayer = [FFWidgetOverlays layer];
            widgetOverlayLayer.frame = bounds;
            [[self.view layer] addSublayer:widgetOverlayLayer];
            
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
    
    
    if(!didFall){
        
        
        if(recording){
            FFAccelerometerSample* newSample = [FFAccelerometerSample sample];
            newSample.time = [[NSDate date] timeIntervalSinceDate:self.recordStartTime];
            newSample.x = acceleration.x;
            newSample.y = acceleration.y;
            newSample.z = acceleration.z;
            newSample.magnitude = accelMagnitude;
            [acceleromterData addObject:newSample];
            if(!freefalling){
                if(newSample.time > kRecordingTimeout){
                    NSLog(@"recording timed out!");
                    [self cancelRecording];
                }
            }

        }
        
        if(freefalling){
           freefallDuration = -[freefallStartTime timeIntervalSinceNow];
        }
        
        //check if we are freefall
        if(!freefalling && accelMagnitude < .2){
            if(framesInFreefall++ > 10){
                freefalling = YES;
                if(recording){
                    [widgetOverlayLayer fallStarted];
                }
                else {
                    [self startRecording:nil];
                }
                framesOutOfFreefall = 0;
                self.freefallStartTime = [NSDate date];
            }
        }
        else if(freefalling && accelMagnitude >= .2){
            if(framesOutOfFreefall++ > 10){
	            freefalling = NO;
                self.freefallEndTime = [NSDate date];
                [self performSelector:@selector(finishRecordingAfterFall) withObject:self afterDelay:.5];
            }
        }
    }
}

- (void)submitCurrentVideo:(id)sender
{
    if (self.submitView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SubmitView" owner:self options:nil];        
    }
    
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
    
    //TODO animate showing view
    /*
    //animate the view on
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    textView.frame = newTextViewFrame;
    
    [UIView commitAnimations];
     */
    
    [self.videoPreviewView insertSubview:self.submitView aboveSubview:[self.videoPreviewView.subviews objectAtIndex:0]];
            
    [self.videoTitle becomeFirstResponder];

    showingSubmitView = YES;
    [self updateButtonStates];
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
    }
    self.uploadProgressBar.progress = 0;
    
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
    
    NSLog(@"Starting upload with URL %@", self.currentDropAssetURL);

    self.uploader.location = trackLoc.location;
    self.uploader.fallDuration = freefallDuration; 
    self.uploader.videoTitle = self.videoTitle.text;
    self.uploader.videoDescription = self.videoStory.text;

    //show progress bar view...
    [self showUploadProgress];

    [self.uploader startUploadWithURL:self.currentDropAssetURL];
    
    [self.videoTitle resignFirstResponder];
    [self.videoStory resignFirstResponder];
    
    self.loginButton.enabled = NO;
    self.videoTitle.enabled = NO;
    self.videoStory.enabled = NO;
    
}

- (IBAction)login:(id)sender
{
    [self.uploader login:sender];
}

- (IBAction)cancelSubmit:(id)sender
{
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
}

- (void) removeSubmitView
{
    [self.submitView removeFromSuperview];
    self.submitView = nil;
    showingSubmitView = false;
    [self updateButtonStates];
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

    if(didFall){
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
        
        didFall = NO;
        freefallDuration = 0;
        
        [self updateButtonStates];
        
        //TODO delete assets from library
    }
    
}

- (void)startRecording:(id)sender
{
    if(!recording && !didFall){   

    	[[self captureManager] startRecording];
        recording = YES;
        self.recordStartTime = [NSDate date];
        self.acceleromterData = [NSMutableArray arrayWithCapacity:200];
        [self updateButtonStates];
        
        if(!freefalling){
            [widgetOverlayLayer setTimerWithStartTime:self.recordStartTime forDuration:kRecordingTimeout];
        }
    }
}

- (void) cancelRecording
{
    if(recording && !freefalling){
        CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
            recordingTimedOut = YES;
            recording = NO;
            [[self captureManager] cancelRecording];
        });
    }
    else{
        NSLog(@"Canceling recording with faulty state. recording? %d freefalling? %d", recording, freefalling);
    }
}

- (void)finishRecordingAfterFall
{
    didFall = YES;
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        recording = NO;
        [[self captureManager] stopRecording];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[[self captureManager] session] stopRunning];
        });        
    });    
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

- (void) overlayComplete:(NSURL*)assetURL
{
    NSLog(@"overlay complete!! %@", assetURL);

    [widgetOverlayLayer stopDrawingExport];
    
    self.currentDropAssetURL = assetURL;
    self.player = [AVPlayer playerWithURL:assetURL];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];    
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone; 
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
    
    //TODO: fix orientation...maybe?
    [self.player play];
    
    UIView *view = [self videoPreviewView];
    CALayer *viewLayer = [view layer];        
    
    //CGRect bounds = [view bounds];
    CGRect bounds = CGRectMake(-20, 0, 360, 480);//fullscreen it
    //CGRect bounds = CGRectMake(0, -20, 480, 360);//fullscreen it
    [self.playerLayer setFrame:bounds];
    
    [viewLayer insertSublayer:self.playerLayer above:[self captureVideoPreviewLayer] ];

    [self updateButtonStates];     
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    //LOOP
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    timesLooped++;
    [self updateButtonStates];
}

@end

@implementation FFMainViewController (InternalMethods)

// Convert from view coordinates to camera coordinates, where {0,0} represents the top left of the picture area, and {1,1} represents
// the bottom right in landscape mode with the home button on the right.
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates 
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [[self videoPreviewView] frame].size;
    
    if ([captureVideoPreviewLayer isMirrored]) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }    

    if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
		// Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[[self captureManager] videoInput] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;

                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
						// If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
							// Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
						// If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
							// Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
					// Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

// Update button states based on the number of available cameras and mics
- (void)updateButtonStates
{    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        if(showingSubmitView){
            
            [self hideButton:self.recordButton];
            [self hideButton:self.submitButton];
            [self hideButton:self.ignoreButton];            
            [self hideButton:self.infoButton];
            [self hideButton:self.cancelButton];
            [self hideButton:self.introLoginButton];
            [self showLabels];
        }
        else if(recording){
            [self hideButton:self.recordButton];
            [self hideButton:self.submitButton];
            [self hideButton:self.ignoreButton];            
            [self hideButton:self.infoButton];
            [self hideButton:self.introLoginButton];
            
            [self hideOverlay];
            [self showButton:self.cancelButton];
            
            [self hideLabels];
        }
        //if we are waiting, just show record
        else if(!didFall && !freefalling){
            [self showButton:self.recordButton];
            [self showButton:self.infoButton];            
            [self hideButton:self.submitButton];
            [self hideButton:self.ignoreButton];
            [self hideButton:self.cancelButton];
            [self showOverlay];
            
            if(firstRun && !self.uploader.loggedIn){
                [self hideButton:self.introLoginButton];
            }
            
            [self hideLabels];
        }
        //if we fell and playback has gone a few times, show the submit/ignore
        else if(didFall && timesLooped > 0){
            
            [self hideButton:self.recordButton];
            [self hideButton:self.infoButton];
            [self hideButton:self.cancelButton];
            
            [self showButton:self.submitButton];
            [self showButton:self.ignoreButton];
            [self showLabels];
        }
        
        //need to reset font colors on buttons all the time they get lost
		self.recordButton.titleLabel.textColor = fontcolor;
        self.submitButton.titleLabel.textColor = fontcolor;    
        self.ignoreButton.titleLabel.textColor = fontcolor;
        self.cancelButton.titleLabel.textColor = fontcolor;
    });
}

- (void)hideButton:(UIButton *)button
{
    [button setHidden:YES];
    [button setEnabled:NO];
}

- (void)showButton:(UIButton *)button 
{
    [button setHidden:NO];
    [button setEnabled:YES];
}

- (void)hideLabel:(UILabel *)label
{
    [label setHidden:YES];
}

- (void)showLabel:(UILabel *)label
{
    [label setHidden:NO];
}

- (void)hideLabels
{
    [self hideLabel:self.dropscoreLabelTop];
    [self hideLabel:self.dropscoreLabelBottom];
    [self hideLabel:self.dropscoreLabelTime];
}

- (void)showLabels 
{ 
    [self showLabel:self.dropscoreLabelTop];
    [self showLabel:self.dropscoreLabelBottom];
    [self showLabel:self.dropscoreLabelTime];
}

- (void)hideOverlay
{
    [UIView animateWithDuration:0.25
                     animations:^{stripeOverlay.alpha = 0.0;}
                     completion:^(BOOL finished){ }];
}

- (void)showOverlay
{
    [UIView animateWithDuration:0.25
                     animations:^{stripeOverlay.alpha = .35;}
                     completion:^(BOOL finished){ }];

}

@end

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
        
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        
        ///create an overlay asset
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
                
        self.dropscoreLabelTime.text = [NSString stringWithFormat:@"%.03fs", freefallDuration];
        [widgetOverlayLayer startDrawingExpot];
    });
    
    //don't save the asset to the library
    return NO;
}

- (void) captureManagerRecordingSaved:(AVCamCaptureManager *)captureManager toURL:(NSURL*)assetURL
{
    //unused, we never save the items directly from the camera to the asset library.
}

- (void) captureManagerRecordingCanceled:(AVCamCaptureManager *)captureManager
{
    recordingTimedOut = NO;
    [self updateButtonStates];
}

- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager
{
//    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
//        [[self stillButton] setEnabled:YES];
//    });
}

- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
//	[self updateButtonStates];
}

@end

@implementation FFMainViewController (FFYoutubeUploaderDelegate)

- (void) userDidSignIn:(NSString*)userName
{ 
    if(showingSubmitView){
        [self.loginButton setTitle:userName
                          forState:UIControlStateNormal];
        [self.loginButton setTitle:userName
                          forState:UIControlStateDisabled];
    }
    
}

- (void) userDidSignOut
{
    NSLog(@"user signed out");    
    if(showingSubmitView){
        [self.loginButton setTitle:@"Log in"
                          forState:  (UIControlStateNormal | UIControlStateHighlighted | UIControlStateDisabled | UIControlStateSelected)];
    }
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
    if(!showingSubmitView){
        NSLog(@"ERROR somehow an upload was completed while we were not showing the submit view");
        return;
    }
    
    [self removeSubmitView];
    [self removeUploadProgressView];
    [self discardCurrentVideo:self];
    
    NSLog(@"upload completed!");     
}

- (void) uploadFailedWithError:(NSError*)error
{
    if(!showingSubmitView){
        NSLog(@"ERROR somehow an upload FAILED while we were not showing the submit view");
        return;
    }

    NSLog(@"upload failed :( ");
    
    [self cancelSubmit:self];
}

@end
