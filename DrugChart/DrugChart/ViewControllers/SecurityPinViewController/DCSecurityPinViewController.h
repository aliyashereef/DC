//
//  DCSecurityPinViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/30/15.
//
//

#import <UIKit/UIKit.h>
#import "DCBaseViewController.h"

typedef void (^SecurityPinEntered)(NSString *pin);

@interface DCSecurityPinViewController : DCBaseViewController

@property (nonatomic, strong) SecurityPinEntered securityPinEntered;

@end
