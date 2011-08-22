//
//  FFHighscoresProvider.h
//  FreefallHighscore
//
//  Created by James George on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//provides scores for both "my drops" and global high scores
@interface FFHighscoresProvider : NSObject<UITableViewDataSource> {
    BOOL showingLogin;
}

@property(nonatomic, assign) UITableView* tableView;
@property(nonatomic, retain) NSMutableData* responseData;
@property(nonatomic, retain) NSArray* highScores;
@property(nonatomic, retain) NSString* queryURL;
@property(nonatomic, readonly) BOOL queryComplete;

- (id) initWithQueryURL:(NSString*)url;
- (void) refreshQuery;
- (void) showLoginCell;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@end
