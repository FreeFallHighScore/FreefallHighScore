//
//  FFVideoOverlay.h
//  FreefallHighscore
//
//  Created by James George on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface FFVideoOverlay : NSObject {
	AVComposition *_composition;
	AVVideoComposition *_videoComposition;
    BOOL _exporting;
}

@property (nonatomic, readonly, retain) AVComposition *composition;
@property (nonatomic, readonly, retain) AVVideoComposition *videoComposition;

//building comp
- (BOOL) createVideoOverlay:(AVAsset*)sourceAsset;
- (CALayer *)buildHighscoreOverlay:(CGSize)videoSize;
- (void)buildPassThroughVideoComposition:(AVMutableVideoComposition *)videoComposition forComposition:(AVMutableComposition *)composition;

//exporting comp
- (void)updateProgress:(AVAssetExportSession*)session;
- (void) beginExport;
- (AVAssetExportSession*)assetExportSessionWithPreset:(NSString*)presetName;
- (void) exportDidFinish:(AVAssetExportSession*)session;

@end
