//
//  DCAuthorizationViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 04/05/15.
//
//

#import "DCBaseViewController.h"
#import "DCServerChangeViewController.h"

@protocol DCAuthorizationViewControllerDelegate <NSObject>

@optional

- (void)successfulLoginAction;
- (void)loginActionFailed;

@end

@interface DCAuthorizationViewController : DCBaseViewController <UIWebViewDelegate>

@property (nonatomic, assign) id <DCAuthorizationViewControllerDelegate> delegate;


@end
