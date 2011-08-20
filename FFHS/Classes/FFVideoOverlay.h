//
//  FFVideoOverlay.h
//  FreefallHighscore
//
//  Created by James George on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@protocol FFVideoOverlayDelegate<NSObject>
- (void) overlayReachedPercent:(CGFloat)percentComplete;
- (void) overlayComplete:(NSURL*)assetURL;
- (void) overlayCopyComplete:(NSURL*)assetURL;
@end 


@interface FFVideoOverlay : NSObject{
	AVComposition *_composition;
	AVVideoComposition *_videoComposition;
    AVAssetExportSession* _session;
    BOOL _exporting;
    id<FFVideoOverlayDelegate> _delegate; 
    NSTimeInterval fallstart;
    NSTimeInterval fallend;
}


@property (nonatomic, retain) AVComposition *composition;
@property (nonatomic, retain) AVVideoComposition *videoComposition;
@property (nonatomic, retain) id<FFVideoOverlayDelegate> delegate;
@property (nonatomic, retain) AVAssetExportSession* session;

- (BOOL) createVideoOverlayWithAsset:(AVAsset*)sourceAsset 
                         fallStarted:(NSTimeInterval)fallStartTime
                           fallEnded:(NSTimeInterval)fallEndedTime
                   accelerometerData:(NSArray*)accelData;
                     
- (CALayer *)buildHighscoreOverlay:(CGSize)videoSize;

//exporting comp
- (void) updateProgress:(AVAssetExportSession*)session;
- (void) beginExport;
- (AVAssetExportSession*)assetExportSessionWithPreset:(NSString*)presetName;
- (void) exportDidFinish:(AVAssetExportSession*)session;

//CA stuff
- (void)drawLayer:(CALayer *)theLayer inContext:(CGContextRef)theContext;

@end
