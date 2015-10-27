//
//  DCAddMedicationPopOverViewController.h
//  DrugChart
//
//  Created by aliya on 25/08/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatient.h"
#import "DCMedicationScheduleDetails.h"


@protocol DCAddMedicationViewControllerDelegate <NSObject>

- (void)addedNewMedicationForPatient;

@end

@interface DCAddMedicationInitialViewController : DCBaseViewController <UIPopoverPresentationControllerDelegate>

@property (nonatomic, assign) id <DCAddMedicationViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *patientId;
@property (nonatomic, strong) DCMedicationScheduleDetails *selectedMedication;


@end
