//
//  DCPatientMedicationHomeViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 04/03/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatient.h"
#import "DCMedicationScheduleDetails.h"
#import "DCAdministerMedicationViewController.h"

typedef enum : NSUInteger {
    kSectionRegular,
    kSectionOnce,
    kSectionWhenInNeed,
} MedicationTableSection;

@interface DCPatientMedicationHomeViewController : DCBaseViewController

@property (nonatomic, strong) DCPatient *patient;
@property (nonatomic, strong) DCAdministerMedicationViewController *administerMedicationViewController;
@property (nonatomic) BOOL hasAdministerChanges;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property BOOL isAdministerViewPresented;

- (void)setMedicationListForCalendarChart:(DCMedicationScheduleDetails *)medication;
- (void)displayAdministerMedicationViewController:(id)medication;
- (void)cancelMedicationAdministration;
- (void)doneTappedForMedicationAdministration;
- (void)editSelectedMedication:(DCMedicationScheduleDetails *)medicationList;
- (void)calendarSwipeInitiated;
- (void)fetchMedicationListForPatient;

- (void)keyBoardActionInAdministerMedicationView:(NSDictionary *)keyBoardDetails;
- (NSMutableArray *)getAllRegularMedicationList:(NSMutableArray *)listArray;
- (NSMutableArray *)getAllOnceMedicationList:(NSMutableArray *)listArray;
- (NSMutableArray *)getAllWhenRequiredMedicationList:(NSMutableArray *)listArray;


@end
