//
//  TestingObjectiveResourceViewController.h
//  TestingObjectiveResource
//
//  Created by Juan C. Müller on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestingObjectiveResourceViewController : UIViewController
{
    UIButton *doShit;
}

@property(nonatomic,retain) IBOutlet UIButton* doShit;

-(IBAction)doShitPressed:(id)sender;

@end
