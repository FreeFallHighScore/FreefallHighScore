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
- (void) overlayComplete:(NSURL*)assetURL;
@end 

@interface FFVideoOverlay : NSObject {
	AVComposition *_composition;
	AVVideoComposition *_videoComposition;
    AVAssetExportSession* _session;
    BOOL _exporting;
    id<FFVideoOverlayDelegate> _delegate; 
}

@property (nonatomic, retain) AVComposition *composition;
@property (nonatomic, retain) AVVideoComposition *videoComposition;
@property (nonatomic, retain) id<FFVideoOverlayDelegate> delegate;
@property (nonatomic, retain) AVAssetExportSession* session;

//NSArray of accelerometer data
//Time of freefall start, time of freefall end

//building comp
- (BOOL) createVideoOverlay:(AVAsset*)sourceAsset; //add more parameters
- (CALayer *)buildHighscoreOverlay:(CGSize)videoSize;
- (void)buildPassThroughVideoComposition:(AVMutableVideoComposition *)videoComposition forComposition:(AVMutableComposition *)composition;

//exporting comp
- (void)updateProgress:(AVAssetExportSession*)session;
- (void) beginExport;
- (AVAssetExportSession*)assetExportSessionWithPreset:(NSString*)presetName;
- (void) exportDidFinish:(AVAssetExportSession*)session;

@end
