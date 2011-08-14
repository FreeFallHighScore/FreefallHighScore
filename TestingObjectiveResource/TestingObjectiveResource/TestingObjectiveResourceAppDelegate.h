//
//  TestingObjectiveResourceAppDelegate.h
//  TestingObjectiveResource
//
//  Created by Juan C. Müller on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestingObjectiveResourceViewController;

@interface TestingObjectiveResourceAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet TestingObjectiveResourceViewController *viewController;

@end
