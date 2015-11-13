//
//  DCPrescriberMedicationViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 27/09/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatient.h"

@interface DCPrescriberMedicationViewController : DCBaseViewController

@property (nonatomic, strong) DCPatient *patient;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic) BOOL isLoading;

- (void)displayAdministrationViewForMedicationSlot:(NSDictionary *)medicationSLotsDictionary
                                       atIndexPath:(NSIndexPath *)indexPath
                                      withWeekDate:(NSDate *)date;
- (void)modifyStartDayAndWeekDates:(BOOL)isNextWeek;
- (void)updatePrescriberMedicationListDetails;
- (void)loadCurrentWeekDate ;
//- (void)reloadAndUpdatePrescriberMedicationDetails;
- (void)modifyWeekDatesInCalendarTopPortion;
- (void)reloadCalendarTopPortion;
- (void)fetchMedicationListForPatient;
- (void)cancelPreviousMedicationListFetchRequest;
- (void)modifyWeekDatesViewConstraint:(CGFloat)leadingConstraint;
- (void)showActivityIndicationOnViewRefresh:(BOOL)show;

@end
