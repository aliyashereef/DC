//
//  DCOrderSetInitialViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/30/15.
//
//

#import <UIKit/UIKit.h>

@interface DCOrderSetInitialViewController : DCBaseViewController

@property (nonatomic, strong) NSMutableArray *activeMedicationArray;

- (void)updateActiveMedicationList:(NSArray *)activeMedications
             withCompletionHandler:(void(^)(BOOL completed))callBackHandler;
- (void)updateInActiveMedicationListWithContents:(NSArray *)inactiveMedications;
- (BOOL)isOrderSetNameFieldValid;
- (void)displayValidationView:(BOOL)show;
- (void)updateAddMedicationsOperationsArray:(NSArray *)operationsArray;

@end
