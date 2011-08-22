//
//  FFFlipsideHighscoresController.h
//  FreefallHighscore
//
//  Created by James George on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFFlipsideController.h"

@class FFHighscoresProvider;

@interface FFFlipsideHighscoresController : FFFlipsideController<UITableViewDelegate> {
    FFHighscoresProvider* scores;

}

@property(nonatomic, assign) IBOutlet UITableView* tableView; 
@property(nonatomic, retain) FFHighscoresProvider* scores;

@end
