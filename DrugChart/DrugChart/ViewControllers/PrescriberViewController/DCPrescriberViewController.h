//
//  DCPrescriberViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/24/15.
//
//

#import <UIKit/UIKit.h>
#import "DCMedicationScheduleDetails.h"
#import "DCBaseViewController.h"

@interface DCPrescriberViewController : DCBaseViewController

@property (nonatomic, strong) NSMutableArray *medicationListArray;

@property BOOL discontinuedMedicationShown;

- (void)reloadPrescriberViewWithMedicationListWithLoadingCompletion:(BOOL)isCompleted;
- (void)todayButtonAction;
- (void)sortCalendarViewBasedOnCriteria:(NSString *)criteriaString;

@end
