//
//  FFHighscoresProvider.h
//  FreefallHighscore
//
//  Created by James George on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class HJObjManager;
//provides scores for both "my drops" and global high scores
@interface FFHighscoresProvider : NSObject<UITableViewDataSource> {
    BOOL showingLogin;
    HJObjManager* imageViewManager;
    
}

@property(nonatomic, assign) UITableView* tableView;
@property(nonatomic, assign) IBOutlet UITableViewCell* scoreCell;
@property(nonatomic, retain) NSMutableData* responseData;
@property(nonatomic, retain) NSArray* highScores;
@property(nonatomic, retain) NSString* queryURL;
@property(nonatomic, assign) HJObjManager* imageManager;

- (id) initWithQueryURL:(NSString*)url;
- (void) refreshQuery;
- (void) showLoginCell;
- (void) hidLoginCell;
- (NSString*) youtubeURLForIndex:(NSIndexPath*)indexPath;
- (NSString*) youtubeTitleForIndex:(NSIndexPath*)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@end
