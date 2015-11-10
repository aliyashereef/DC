//
//  DCAddMedicationRightViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/3/15.
//
//

#import <UIKit/UIKit.h>

@interface DCAddMedicationRightViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *medicationArray;
@property (nonatomic, strong) NSMutableArray *allergiesArray;

- (void)displayWarningsSection:(BOOL)show;
- (void)populateViewWithWarningsArray:(NSArray *)warnings;

@end
