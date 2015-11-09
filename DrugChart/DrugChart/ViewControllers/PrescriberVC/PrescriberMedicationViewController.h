//
//  PrescriberMedicationViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 27/09/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatient.h"

@interface PrescriberMedicationViewController : DCBaseViewController

@property (nonatomic, strong) DCPatient *patient;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic) BOOL isLoading;

- (void)displayAdministrationViewForMedicationSlot:(NSDictionary *)medicationSLotsDictionary
                                       atIndexPath:(NSIndexPath *)indexPath
                                      withWeekDate:(NSDate *)date;
- (void)modifyStartDayAndWeekDates:(BOOL)isNextWeek;
-(void)reloadAndUpdatePrescriberMedicationDetails;
- (void)modifyWeekDatesInCalendarTopPortion;
- (void)reloadCalendarTopPortion;
- (void)fetchMedicationListForPatientWithCompletionHandler:(void(^)(BOOL success))completion;
- (void)cancelPreviousMedicationListFetchRequest;
- (void)modifyWeekDatesViewConstraint:(CGFloat)leadingConstraint;
- (void)showActivityIndicationOnViewRefresh:(BOOL)show;
- (void)resetMedicationListCellsToOriginalPosition;

@end
