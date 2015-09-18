//
//  DCBaseViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/2/15.
//
//

#import <UIKit/UIKit.h>

@interface DCBaseViewController : UIViewController

@property (nonatomic) CGSize keyboardSize;

- (void)displayAlertWithTitle:(NSString *)title
                      message:(NSString *)message;


@end
