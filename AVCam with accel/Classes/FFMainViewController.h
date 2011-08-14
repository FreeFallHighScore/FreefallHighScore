/*
     File: AVCamViewController.h
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

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class AVCamCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer,AccelerometerFilter, AVPlayer, AVPlayerLayer, FFTrackLocation;

@interface FFMainViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate,
UIAccelerometerDelegate,CLLocationManagerDelegate> {
	AccelerometerFilter *filter;
    BOOL freefalling;
    BOOL recording;
    NSTimeInterval longestTimeInFreefall;
    NSDate* freefallStartTime; 
    NSInteger framesInFreefall;
    NSInteger framesOutOfFreefall;
    BOOL didFall;
    AVPlayer* player;
    AVPlayerLayer* playerLayer;
    NSInteger timesLooped;
    UIButton* ignoreButton;
    UIButton* submitButton;
    UIButton* recordButton;
    UILabel* dropscoreLabelTop;
    UILabel* dropscoreLabelBottom;
    UILabel* dropscoreLabelTime;
    UIColor* fontcolor;
    FFTrackLocation *trackLoc;

}

//camera related stuff
@property (nonatomic,retain) AVCamCaptureManager *captureManager;
@property (nonatomic,retain) IBOutlet UIView *videoPreviewView;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,retain) UIButton *ignoreButton;
@property (nonatomic,retain) UIButton *submitButton;
@property (nonatomic,retain) UIButton *recordButton;

@property (nonatomic,retain) UILabel* dropscoreLabelTop;
@property (nonatomic,retain) UILabel* dropscoreLabelBottom;
@property (nonatomic,retain) UILabel* dropscoreLabelTime;

//you tube stuff
@property (nonatomic,retain) UIButton *loginButton;

//accel related stuff
@property (nonatomic,retain) AccelerometerFilter* filter;
@property (nonatomic,readwrite) BOOL freefalling;
@property (nonatomic,readwrite) NSTimeInterval longestTimeInFreefall;
@property (nonatomic,retain) NSDate* freefallStartTime;
@property (nonatomic,readwrite) CGFloat lowestMagnitude;

//playback stuff
@property (nonatomic, retain) AVPlayer* player;
@property (nonatomic, retain) AVPlayerLayer* playerLayer;

- (void)playerItemDidReachEnd:(NSNotification *)notification;
- (void)submitLastVideo:(id)sender;
- (void)ignoreLastVideo:(id)sender;
- (void)manualRecord:(id)sender;

- (void)hideButton:(UIButton *)button;
- (void)showButton:(UIButton *)button;
- (void)hideLabel:(UILabel *)label;
- (void)showLabel:(UILabel *)label;
- (void)hideLabels;
- (void)showLabels;

// location stuff
@property (nonatomic,retain) FFTrackLocation *trackLoc;
//@property (nonatomic, retain) CLLocationManager *locationManager;


//#pragma mark Toolbar Actions
//- (IBAction)toggleRecording:(id)sender;
//- (IBAction)captureStillImage:(id)sender;
//- (IBAction)toggleCamera:(id)sender;

@end

