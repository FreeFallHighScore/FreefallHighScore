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

@implementation FFHighscoresProvider

@synthesize tableView;
@synthesize queryURL;
@synthesize queryComplete;
@synthesize responseData;
@synthesize highScores;

- (id) initWithQueryURL:(NSString*)url
{
    self = [super init];
    if(self){
        self.queryURL = url;
    }
    return self;
}

- (void) refreshQuery
{
    if(self.queryURL != @""){
        queryComplete = NO;
        showingLogin = NO;
        self.responseData =  [NSMutableData data];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.queryURL]];
        [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
    }
}

- (void) showLoginCell
{
    showingLogin = YES;
    [tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(showingLogin){
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"login"];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"login"];
        }
        cell.textLabel.text = @"Please login";
        return cell;
    }
    
    if(!self.queryComplete && indexPath.row == 0){
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"reloading"];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reloading"];
        }
        //TODO: add spinny wheel
        cell.textLabel.text = @"Querying Highscores...";
        return cell;
    }
    else if(self.queryComplete && indexPath.row < highScores.count) {
            
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"highscore"];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"highscore"];
        }
        
        NSDictionary* score = [self.highScores objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@" %@:  %.02fs", [score objectForKey:@"author"], [[score objectForKey:@"drop_time"] floatValue]/1000.0];

        return cell;
    }
    
    NSLog(@"ERROR! ------------- returning nil for row %d", indexPath.row);
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!self.queryComplete || showingLogin){ 
        return 1;
    }
    else {
        return self.highScores.count;
    }
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
    
	self.highScores = [responseString JSONValue];
    
	for (int i = 0; i < [highScores count]; i++){
        NSDictionary* score = [highScores objectAtIndex:i];
        NSLog(@"score %d is %f by %@", i, [[score objectForKey:@"drop_time"] floatValue], [score objectForKey:@"author"] );
    }
    
    queryComplete = YES;
    
    [tableView reloadData];
    [responseString release];
}
@end
