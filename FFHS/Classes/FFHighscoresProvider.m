//
//  FFHighscoresProvider.m
//  FreefallHighscore
//
//  Created by James George on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FFHighscoresProvider.h"
#import "FFUtilities.h"
#import "JSON.h"
#import "HJObjManager.h"
#import "HJManagedImageV.h"




@implementation FFHighscoresProvider

@synthesize tableView;
@synthesize queryURL;
@synthesize responseData;
@synthesize highScores;
@synthesize imageManager;
@synthesize scoreCell;
@synthesize highscoreColor;
@synthesize showTitle;

- (id) initWithQueryURL:(NSString*)url
{
    self = [super init];
    if(self){
        self.queryURL = url;
		self.imageManager = (HJObjManager*)[[UIApplication sharedApplication].delegate imageManager];
    }
    return self;
}

- (void) refreshQuery
{
    if(self.queryURL != @""){

        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        self.highScores = [defaults arrayForKey:self.queryURL];
        if(self.highScores != nil && self.highScores.count != 0){
            [self.tableView reloadData];
        }
        self.responseData =  [NSMutableData data];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.queryURL]];
//        [request setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
        
        [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(showingLogin){
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"login"];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"login"];
        }
        cell.textLabel.text = @"Please login to see your drops.";
        return cell;
    }
    else if(self.highScores == nil && indexPath.row == 0){
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"reloading"];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reloading"];
        }
        //TODO: add spinny wheel
        cell.textLabel.text = @"Querying Highscores...";
        return cell;
    }
    else if(self.highScores != nil){
        if(self.highScores.count == 0){
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"no videos"];
            if(cell == nil){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"no videos"];
            }
            cell.textLabel.text = @"You haven't submitted any drops!";
            return cell;
        }
        else if(indexPath.row < self.highScores.count) {
        
            static NSString *MyIdentifier = @"MyIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
            if (cell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"HighscoresTableCell" owner:self options:nil];
                cell = self.scoreCell;
                self.scoreCell = nil;
            }
            
            
            HJManagedImageV* mi = (HJManagedImageV *)[cell viewWithTag:10];
        	UIView* rankView = (UIView*)[cell viewWithTag:11];
            UILabel* rankLabel = (UILabel*)[cell viewWithTag:12];
        	UILabel* timeLabel = (UILabel*)[cell viewWithTag:13];
        	UILabel* nameLabel = (UILabel*)[cell viewWithTag:14];
            
            NSLog(@"rank view? %@ rank label? %@ time label? %@ name label? %@", rankView, rankLabel, timeLabel, nameLabel);
            
            NSDictionary* score = [self.highScores objectAtIndex:indexPath.row];

            NSNumber* rankNum = [score objectForKey:@"rank"];
            NSString* rankString;
            NSInteger rank = [rankNum intValue];

            if(self.highscoreColor == nil){
                self.highscoreColor = rankView.backgroundColor;
            }

            //TODO add stars...
            if(rank == 1){
            	rankString = @"LEADER";
                rankView.backgroundColor = self.highscoreColor;
            }
            else if(rank == 2){
            	rankString = @"SECOND";                
                rankView.backgroundColor = self.highscoreColor;
            }
            else if(rank == 3){
                rankString = @"THIRD";
                rankView.backgroundColor = self.highscoreColor;
            }
            else{
                rankView.backgroundColor = [UIColor grayColor];
                rankString = [NSString stringWithFormat:@"#%d", rank];
            }
            
            rankLabel.text = rankString;
            timeLabel.text = [NSString stringWithFormat:@"%.02fs ",  [[score objectForKey:@"drop_time"] floatValue]/1000.0];
            if(showTitle){
	            nameLabel.text = [NSString stringWithFormat:@"%@ ", [score objectForKey:@"title"]];
            }
            else{
            	nameLabel.text = [NSString stringWithFormat:@"%@ ", [score objectForKey:@"author"]];
            }

            NSString *urlString =  [score objectForKey:@"thumbnail_url"];
            NSLog(@"thumbnail URL %@", urlString);
            mi.url = [NSURL URLWithString:urlString];
            [self.imageManager manage:mi];

            
            return cell;            
        }    
    }
    
    NSLog(@"ERROR! ------------- returning nil for row %d", indexPath.row);
    
    return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.highScores == nil || showingLogin){ 
        return 1;
    }
    else {
        if(self.highScores.count == 0){
        	return 1;
        }
        return self.highScores.count;
    }
}

- (void) showLoginCell
{
	showingLogin = YES;
    self.highScores = nil;
    [tableView reloadData];
}

- (void) hidLoginCell
{
    showingLogin = NO;
}
- (NSString*) youtubeURLForIndex:(NSIndexPath*)indexPath
{
	if(self.highScores != nil && indexPath.row < self.highScores.count){
        NSDictionary* score = [self.highScores objectAtIndex:indexPath.row];        
        NSString* url = [score objectForKey:@"video_url"];
        NSLog(@"selected video URL %@", url);
        return url;
    }
    return nil;
}

- (NSString*) youtubeTitleForIndex:(NSIndexPath*)indexPath
{
    if(self.highScores != nil && indexPath.row < self.highScores.count){
        NSDictionary* score = [self.highScores objectAtIndex:indexPath.row];        
        NSString* title = [score objectForKey:@"title"];
        NSLog(@"selected video title %@", title);
        return title;
    }
    return nil;

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //TODO: handle this error with a message
    ShowAlert(@"Request Error", [NSString stringWithFormat:@"failed to receive data with error @%", [error localizedDescription] ]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

	[connection release];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    self.responseData = nil;
    NSLog(responseString);
	self.highScores = [responseString JSONValue];
    for (int i = 0; i < [highScores count]; i++){
        NSDictionary* score = [highScores objectAtIndex:i];
        NSLog(@"score %d is %f by %@", i, [[score objectForKey:@"drop_time"] floatValue], [score objectForKey:@"author"] );
    }
    
    [tableView reloadData];
    [responseString release];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.highScores forKey:self.queryURL];
    [defaults synchronize];
}

@end
