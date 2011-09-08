//
//  FFYoutubeViewController.h
//  FreefallHighscore
//
//  Created by Jim on 9/7/11.
//  Copyright 2011 FlightPhase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFYoutubeView.h"

@interface FFYoutubeViewController : UIViewController {
    
}
@property(nonatomic,retain) NSString* youtubeURL; 
@property(nonatomic,assign) IBOutlet FFYouTubeView* youtubeView;

@end
