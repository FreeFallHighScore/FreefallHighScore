//
//  FFVideoOverlay.m
//  FreefallHighscore
//
//  Created by James George on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFVideoOverlay.h"
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FFVideoOverlayLayer.h"

static CGImageRef createStarImage(CGFloat radius)
{
	int i, count = 5;
#if TARGET_OS_IPHONE
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
#else // not TARGET_OS_IPHONE
	CGColorSpaceRef colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
#endif // not TARGET_OS_IPHONE
	CGImageRef image = NULL;
	size_t width = 2*radius;
	size_t height = 2*radius;
	size_t bytesperrow = width * 4;
	CGContextRef context = CGBitmapContextCreate((void *)NULL, width, height, 8, bytesperrow, colorspace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
	CGContextClearRect(context, CGRectMake(0, 0, 2*radius, 2*radius));
	CGContextSetLineWidth(context, radius / 15.0);
	
	for( i = 0; i < 2 * count; i++ ) {
		CGFloat angle = i * M_PI / count;
		CGFloat pointradius = (i % 2) ? radius * 0.37 : radius * 0.95;
		CGFloat x = radius + pointradius * cos(angle);
		CGFloat y = radius + pointradius * sin(angle);
		if (i == 0)
			CGContextMoveToPoint(context, x, y);
		else
			CGContextAddLineToPoint(context, x, y);
	}
	CGContextClosePath(context);
	
	CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
	//CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextDrawPath(context, kCGPathFill);
	CGColorSpaceRelease(colorspace);
	image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	return image;
}

@implementation FFVideoOverlay
@synthesize composition = _composition;
@synthesize videoComposition =_videoComposition;
@synthesize session = _session;
@synthesize delegate = _delegate;

/*
- (CALayer *)buildHighscoreOverlay:(CGSize)videoSize
{
	// Create a layer for the overall title animation.
	CALayer *animatedTitleLayer = [CALayer layer];
	
	// Create a layer for the text of the title.
	CATextLayer *titleLayer = [CATextLayer layer];
	//titleLayer.string = @"title text";
    titleLayer.string = [NSString stringWithFormat:@"%.03fs", fallend - fallstart];
//	titleLayer.font = @"Helvetica";
    titleLayer.font = @"G.B.BOOT";
	titleLayer.fontSize = videoSize.height / 6;
    
//    titleLayer.foregroundColor = CGColorCreate(colorSpace, components);
    
	//?? titleLayer.shadowOpacity = 0.5;
	titleLayer.alignmentMode = kCAAlignmentCenter;
	titleLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height / 6);
    titleLayer.frame = CGRectMake(0, 0, videoSize.width/2, videoSize.height / 2);
	
	// Add it to the overall layer.
	[animatedTitleLayer addSublayer:titleLayer];
	
	// Create a layer that contains a ring of stars.
	CALayer *ringOfStarsLayer = [CALayer layer];
    
	NSInteger starCount = 3, s;
	CGFloat starRadius = videoSize.height / 10;
	CGFloat ringRadius = videoSize.height * 0.8 / 2;
	CGImageRef starImage = createStarImage(starRadius);
	
    CALayer *starLayer = [CALayer layer];
    CGFloat angle = s * 2 * M_PI / starCount;
    starLayer.bounds = CGRectMake(0, 0, 2 * starRadius, 2 * starRadius);
    starLayer.position = CGPointMake(ringRadius * cos(angle), ringRadius * sin(angle));
    starLayer.contents = (id)starImage;
    [ringOfStarsLayer addSublayer:starLayer];
	
	CGImageRelease(starImage);
	
	// Move the ring of stars.
	CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
	//rotationAnimation.repeatCount = 10; 
	rotationAnimation.fromValue = [NSNumber numberWithFloat:videoSize.height];
	rotationAnimation.toValue = [NSNumber numberWithFloat:0.0];// NSNumber numberWithFloat:0.0
	rotationAnimation.duration = fallend-fallstart; // repeat every 10 seconds
	//rotationAnimation.additive = YES;
	rotationAnimation.removedOnCompletion = NO;
	rotationAnimation.beginTime = fallstart;
   
   // rotationAnimation.timeOffset = fallstart;
    // CoreAnimation automatically replaces zero beginTime with CACurrentMediaTime().  The constant AVCoreAnimationBeginTimeAtZero is also available.
	[ringOfStarsLayer addAnimation:rotationAnimation forKey:nil];
	
	// Add the ring of stars to the overall layer.
	animatedTitleLayer.position = CGPointMake(videoSize.width / 2.0, 0);
	[animatedTitleLayer addSublayer:ringOfStarsLayer];
	
	// Animate the opacity of the overall layer so that it fades out from 3 sec to 4 sec.
	//CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	//fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
	//fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
	//fadeAnimation.additive = NO;
	//fadeAnimation.removedOnCompletion = NO;
	//fadeAnimation.beginTime = 0.5;
	//fadeAnimation.duration = 2.0;
	//fadeAnimation.fillMode = kCAFillModeBoth;
	//[animatedTitleLayer addAnimation:fadeAnimation forKey:nil];
	
	return animatedTitleLayer;
}

 */

- (BOOL) createVideoOverlayWithAsset:(AVAsset*)sourceAsset 
                         fallStarted:(NSTimeInterval)fallStartTime
                           fallEnded:(NSTimeInterval)fallEndedTime
                   accelerometerData:(NSArray*)accelData
{
    
    fallstart = fallStartTime;
    fallend= fallEndedTime;
    
    NSLog(@"creating overlay with start time %f end time %f and %d accel samples", fallStartTime, fallEndedTime, [accelData count]);
    
    CALayer *animatedOverlay = nil;
    CGSize videoSize = [sourceAsset naturalSize];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
	AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    //CMTimeRange duration = CMTimeRangeMake(kCMTimeZero, [sourceAsset duration]);
    CMTimeRange duration = CMTimeRangeMake(kCMTimeZero, [sourceAsset duration]);
    
    AVAssetTrack *clipVideoTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [compositionVideoTrack insertTimeRange:duration ofTrack:clipVideoTrack atTime:kCMTimeZero error:nil];
    
    AVAssetTrack *clipAudioTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [compositionAudioTrack insertTimeRange:duration ofTrack:clipAudioTrack atTime:kCMTimeZero error:nil];

    animatedOverlay = [self buildHighscoreOverlay:videoSize];

    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:animatedOverlay];
    parentLayer.delegate = self;
    
	// Make a "pass through video track" video composition.
	AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
	passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [composition duration]);
	
	AVAssetTrack *videoTrack = [[composition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
	
	passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
	videoComposition.instructions = [NSArray arrayWithObject:passThroughInstruction];
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];

    videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
    videoComposition.renderSize = videoSize;

    NSLog(@"beginning overlay export video size is %f %f", videoSize.width, videoSize.height);
    
    //retain the objects
    self.composition = composition;
    self.videoComposition = videoComposition;
    
    [self beginExport];    
    return YES;
}

- (AVAssetExportSession*)assetExportSessionWithPreset:(NSString*)presetName
{
	AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:self.composition presetName:presetName];
	session.videoComposition = self.videoComposition;
//	session.audioMix = self.audioMix;
	return session;
}

#pragma mark -
#pragma mark Export

- (void) beginExport
{
	_exporting = YES;
//	_showSavedVideoToAssestsLibrary = NO;
	
//	NSIndexPath *exportCellIndexPath = [NSIndexPath indexPathForRow:2 inSection:kProjectSection];
//	ExportCell *cell = (ExportCell*)[self.tableView cellForRowAtIndexPath:exportCellIndexPath];
//	cell.progressView.progress = 0.0;
//	[cell setProgressViewHidden:NO animated:YES];
//	[self updateCell:cell forRowAtIndexPath:exportCellIndexPath];
	
//	[self.editor buildCompositionObjectsForPlayback:NO];
	self.session = [self assetExportSessionWithPreset:AVAssetExportPresetHighestQuality];
    
	NSString *filePath = nil;
	NSUInteger count = 0;
	do {
		filePath = NSTemporaryDirectory();
		
		NSString *numberString = count > 0 ? [NSString stringWithFormat:@"-%i", count] : @"";
		filePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"Output-%@.mov", numberString]];
		count++;
	} while([[NSFileManager defaultManager] fileExistsAtPath:filePath]);      
	
    NSLog(@"Found temp file path %@", filePath);
    
	self.session.outputURL = [NSURL fileURLWithPath:filePath];
	self.session.outputFileType = AVFileTypeQuickTimeMovie;
	
	[self.session exportAsynchronouslyWithCompletionHandler:^(void){
        NSLog(@"Export handler finished");
         dispatch_async(dispatch_get_main_queue(), ^{
             [self exportDidFinish:self.session];
         });
     }];
	
	NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
	[self performSelector:@selector(updateProgress:) withObject:self.session afterDelay:1.0/15.0 inModes:modes];
}

- (void)updateProgress:(AVAssetExportSession*)session
{
    if(self.delegate != nil){
        NSLog(@"Export reached percent %f", session.progress);
        [self.delegate overlayReachedPercent:session.progress];
    }
    
	if (session.status == AVAssetExportSessionStatusExporting) {
		//NSIndexPath *exportCellIndexPath = [NSIndexPath indexPathForRow:2 inSection:kProjectSection];
		//ExportCell *cell = (ExportCell*)[self.tableView cellForRowAtIndexPath:exportCellIndexPath];
		//cell.progressView.progress = session.progress;	
		NSLog(@"EXPORT PROGRESS %f", session.progress);
        
		NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
		[self performSelector:@selector(updateProgress:) withObject:session afterDelay:0.5 inModes:modes];
	}
    else{
        NSLog(@"EXPORT STATUS OFF %d", session.status);
    }
}

- (void) exportDidFinish:(AVAssetExportSession*)session
{
	NSURL *outputURL = session.outputURL;
	
    NSLog(@"Export did finsish to URL %@", session.outputURL);
    
	_exporting = NO;
	
    if(self.delegate != nil){
        [self.delegate overlayComplete:session.outputURL];
    }
 
    //then copy
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
		[library writeVideoAtPathToSavedPhotosAlbum:outputURL
									completionBlock:^(NSURL *assetURL, NSError *error){
										dispatch_async(dispatch_get_main_queue(), ^{
											if (error) {
												NSLog(@"writeVideoToAssestsLibrary failed: %@", error);
												UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
																									message:[error localizedRecoverySuggestion]
																								   delegate:nil
																						  cancelButtonTitle:@"OK"
																						  otherButtonTitles:nil];
												[alertView show];
												[alertView release];
											}
											else {
                                                NSLog(@"EXPORT SUCCESS");
                                                if(self.delegate != nil){
                                                    //TODO call a new method saying the copy has been done
                                                    //we need to use that copy for exporting and potentially
                                                    //going back to videos to export.
                                                    [self.delegate overlayCopyComplete:assetURL];
                                                }
											}
										});
									}];
	}
	[library release];
}

- (void)dealloc 
{
    [_composition release];
    [_videoComposition release];
    
    [super dealloc];
}


#pragma mark Core Animation methods


- (CALayer *)buildHighscoreOverlay:(CGSize)videoSize
{
    
	// Create a layer for the overall title animation.
	CALayer *animatedTitleLayer = [CALayer layer];
	
	// Create a layer for the text of the title.
	FFVideoOverlayLayer *titleLayer = [FFVideoOverlayLayer layer];
	//titleLayer.string = @"title text";
//    titleLayer.string = [NSString stringWithFormat:@"%.03fs", fallstart];
//	titleLayer.font = @"Helvetica";
//	titleLayer.fontSize = videoSize.height / 6;
//	//?? titleLayer.shadowOpacity = 0.5;
//	titleLayer.alignmentMode = kCAAlignmentCenter;
	titleLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height / 6);
	[titleLayer setNeedsDisplay];
	// Add it to the overall layer.
	[animatedTitleLayer addSublayer:titleLayer];
	
	// Create a layer that contains a ring of stars.
	CALayer *ringOfStarsLayer = [CALayer layer];
    NSInteger s;
	NSInteger starCount = 3;
	CGFloat starRadius = videoSize.height / 10;
	CGFloat ringRadius = videoSize.height * 0.8 / 2;
	CGImageRef starImage = createStarImage(starRadius);
	
    CALayer *starLayer = [CALayer layer];
    CGFloat angle = s * 2 * M_PI / starCount;
    starLayer.bounds = CGRectMake(0, 0, 2 * starRadius, 2 * starRadius);
    starLayer.position = CGPointMake(ringRadius * cos(angle), ringRadius * sin(angle));
    starLayer.contents = (id)starImage;
    [ringOfStarsLayer addSublayer:starLayer];
	
	CGImageRelease(starImage);
	
	// Move the ring of stars.
	CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
	//rotationAnimation.repeatCount = 10; 
	rotationAnimation.fromValue = [NSNumber numberWithFloat:videoSize.height];
	rotationAnimation.toValue = [NSNumber numberWithFloat:0.0];// NSNumber numberWithFloat:0.0
	rotationAnimation.duration = fallend-fallstart; // repeat every 10 seconds
	//rotationAnimation.additive = YES;
	rotationAnimation.removedOnCompletion = NO;
	rotationAnimation.beginTime = 1e-100+fallstart;
    
    // rotationAnimation.timeOffset = fallstart;
    // CoreAnimation automatically replaces zero beginTime with CACurrentMediaTime().  The constant AVCoreAnimationBeginTimeAtZero is also available.
	[ringOfStarsLayer addAnimation:rotationAnimation forKey:nil];
	
	// Add the ring of stars to the overall layer.
	animatedTitleLayer.position = CGPointMake(videoSize.width / 2.0, 0);
	[animatedTitleLayer addSublayer:ringOfStarsLayer];
	
	// Animate the opacity of the overall layer so that it fades out from 3 sec to 4 sec.
	//CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	//fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
	//fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
	//fadeAnimation.additive = NO;
	//fadeAnimation.removedOnCompletion = NO;
	//fadeAnimation.beginTime = 0.5;
	//fadeAnimation.duration = 2.0;
	//fadeAnimation.fillMode = kCAFillModeBoth;
	//[animatedTitleLayer addAnimation:fadeAnimation forKey:nil];
//	animatedTitleLayer.delegate = self;
    
	return animatedTitleLayer;
}

- (void)displayLayer:(CALayer *)theLayer
{
    /*
    // check the value of the layer's state key
    if ([[theLayer valueForKey:@"state"] boolValue])
    {
        // display the yes image
        theLayer.contents=[someHelperObject loadStateYesImage];
    }
    else {
        // display the no image
//        theLayer.contents=[someHelperObject loadStateNoImage];
    }
    */
}

/*
- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext
{
 
    NSLog(@"Delegating!!");
    
    CGMutablePathRef thePath = CGPathCreateMutable();
    CGPathMoveToPoint(thePath,NULL,15.0f,15.f);
    CGPathAddCurveToPoint(thePath,
                          NULL,
                          15.f,250.0f,
                          295.0f,250.0f,
                          295.0f,15.0f);
    
    
    CGContextBeginPath(theContext);
    CGContextAddPath(theContext, thePath );
    
    
    CGContextSetLineWidth(theContext,
                          [[theLayer valueForKey:@"lineWidth"] floatValue]);
    CGContextStrokePath(theContext);
    
    // release the path
    CFRelease(thePath);
    
}
*/

@end
