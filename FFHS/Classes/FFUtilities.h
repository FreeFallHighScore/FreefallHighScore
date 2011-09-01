#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kFFUserDidLogin @"kUFFserDidLogin"
#define kFFUserDidLogout @"kUFFserDidLogout"

static void ShowAlert(NSString*title, NSString* message)
{
    UIAlertView* alertView = nil; 
    @try { 
        alertView = [[UIAlertView alloc] initWithTitle:title
                                               message:message
                                              delegate:nil 
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil]; 
        [alertView show]; 
    } @finally { 
        if (alertView)
            [alertView release]; 
    }

}

