//
//  DCAddMedicationSevereWarningViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/21/15.
//
//

#import <UIKit/UIKit.h>

typedef void (^OverrideAction)(BOOL override);

@interface DCAddMedicationSevereWarningViewController : UIViewController

@property (nonatomic, strong) OverrideAction overrideAction;


- (void)populateViewWithWarningsDetails:(NSArray *)warningsArray;

@end
