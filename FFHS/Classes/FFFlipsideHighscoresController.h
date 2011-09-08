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
@class HJObjManager;
@interface FFFlipsideHighscoresController : FFFlipsideController<UITableViewDelegate> {
    HJObjManager* imageViewManager;

}

@property(nonatomic, assign) IBOutlet UITableView* tableView; 
@property(nonatomic, retain) FFHighscoresProvider* scores;
@property (nonatomic, assign) HJObjManager * imageViewManager;

@end
