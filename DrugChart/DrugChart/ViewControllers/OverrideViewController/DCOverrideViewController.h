//
//  DCOverrideViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 5/29/15.
//
//

#import <UIKit/UIKit.h>
#import "DCBaseViewController.h"

typedef void (^ ReasonSubmitted)(BOOL hasReason);

@interface DCOverrideViewController : DCBaseViewController

@property (nonatomic, strong) ReasonSubmitted reasonSubmitted;

@end
