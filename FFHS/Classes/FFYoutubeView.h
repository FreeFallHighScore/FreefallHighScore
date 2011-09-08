//
//  FFYoutubeView.h
//  FreefallHighscore
//
//  Created by Jim on 9/7/11.
//  Copyright 2011 FlightPhase. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FFYouTubeView : UIWebView 
{

}
//- (FFYouTubeView *)initWithStringAsURL:(NSString *)urlString frame:(CGRect)frame;
- (void) loadYoutubeURL:(NSString*)urlString;

@end