//
//  FFFlipsideMyDropsController.h
//  FreefallHighscore
//
//  Created by James George on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFFlipsideController.h"

@class FFHighscoresProvider;
@interface FFFlipsideMyDropsController : FFFlipsideController<UITableViewDelegate> {

}

@property(nonatomic, assign) IBOutlet UITableView* tableView; 
@property(nonatomic, retain) FFHighscoresProvider* scores;

- (void) refreshScoresTable;

@end
