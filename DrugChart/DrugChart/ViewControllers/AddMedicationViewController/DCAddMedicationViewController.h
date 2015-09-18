//
//  DCAddMedicationViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/16/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatient.h"
#import "DCBaseViewController.h"
#import "DCOrderSetInitialViewController.h"
#import "DCMedicationScheduleDetails.h"



@interface DCAddMedicationViewController : DCBaseViewController

@property (nonatomic, strong) DCPatient *patient;
@property (nonatomic, strong) DCMedicationScheduleDetails *medicationList;
@property (nonatomic) BOOL isLoadingOrderSet;
@property (nonatomic, strong) NSMutableArray *activeOrderSetArray;
@property (nonatomic) int selectedMedicineIndex;
@property (nonatomic, strong) DCOrderSetInitialViewController *orderSetViewController;
@property (nonatomic, strong) NSMutableArray *operationsArray;

- (void)dismissView;
- (void)animateViewUpwardsOnEditingText:(BOOL)moveUp;
- (void)loadActiveOrderSetMedicationDetailsView:(NSArray *)activeMedicationArray
                          loadMedicationAtIndex:(NSInteger)index;
- (void)selectedOrderSetMedicineAtIndex:(int)selectedIndex;
- (void)updateActiveOrderSetArray:(NSMutableArray *)orderSetArray
                   withCompletion:(void(^)(BOOL completed))callBackHandler;
- (void)loadAddMedicationDetailsViewAtIndex:(int)index;
- (void)configureOrderSetScrollViewOnSuperviewTap;
- (void)endMedicineButtonsWobbleAnimation;
- (void)addMedicationServiceCallWithParamaters:(NSDictionary *)medicationDictionary
                             forMedicationType:(NSString *)medicationType;
- (void)updateWarningsArray:(NSArray *)warningsArray;
- (void)displayWarningsAccordionSection:(BOOL)show;
- (void)deleteMedicineInOrderSetViewTag:(int)viewTag;
- (void)updateOrderSetMedicineViewAtIndex:(NSInteger)index
                         withMedicineName:(NSString *)medicine;
- (void)updateOrderSetOperationsArray;

@end
