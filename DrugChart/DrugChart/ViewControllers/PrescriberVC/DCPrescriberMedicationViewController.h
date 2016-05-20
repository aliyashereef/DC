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
@property (nonatomic, strong) NSDate *centerDisplayDate;
@property (nonatomic, strong) NSArray *medicationSlotArray;
@property (nonatomic) CGFloat calendarViewWidth;
@property (strong, nonatomic)  NSMutableArray *selectedMedicationListArray;

- (void)displayAdministrationViewForMedicationSlot:(NSDictionary *)medicationSLotsDictionary
                                       atIndexPath:(NSIndexPath *)indexPath
                                      withWeekDate:(NSDate *)date;
- (void)loadCurrentDayDisplayForOneThirdWithDate : (NSDate *)date ;
- (void)currentWeeksDateArrayFromCenterDate: (NSDate *)centerDate ;
- (void)modifyStartDayAndWeekDates:(BOOL)isNextWeek;
- (void)updatePrescriberMedicationListDetails;
- (void)loadCurrentWeekDate ;
- (void)modifyWeekDatesInCalendarTopPortion;
- (void)reloadCalendarTopPortion;
- (void)reloadAdministrationScreenWithMedicationDetails;
- (void)fetchMedicationListForPatientWithCompletionHandler:(void(^)(BOOL success))completion;
- (void)cancelPreviousMedicationListFetchRequest;
- (void)modifyWeekDatesViewConstraint:(CGFloat)leadingConstraint;
- (void)showActivityIndicationOnViewRefresh:(BOOL)show;
- (void)resetMedicationListCellsToOriginalPosition;

@end
