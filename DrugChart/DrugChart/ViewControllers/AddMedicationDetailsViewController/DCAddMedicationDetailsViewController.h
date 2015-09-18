//
//  DCAddMedicationDetailsViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/23/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatient.h"
#import "DCBaseViewController.h"
#import "DCMedicationScheduleDetails.h"

@interface DCAddMedicationDetailsViewController : DCBaseViewController

@property (nonatomic, strong) DCPatient *patient;
@property (nonatomic, strong) DCMedicationScheduleDetails *medicationList;
@property (nonatomic) BOOL isLoadingOrderSet;
@property (nonatomic, strong) NSMutableArray *medicationsInOrderSet;
@property (nonatomic) int orderSetSelectedIndex;

- (void)doneButtonAction;
- (void)parentViewTapped;
- (void)loadOrderSetMedicationAtIndex:(int)selectedIndex;
- (void)populateOrderSetMedicationDetailsAtIndex:(int)index;
- (void)displayWarningsViewOnAddSubstituteCancel;

@end
