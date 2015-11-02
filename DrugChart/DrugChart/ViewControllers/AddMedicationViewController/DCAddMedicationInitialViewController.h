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

@optional
- (void)addedNewMedicationForPatient;
- (void)medicationEditCancelledForIndexPath:(NSIndexPath *)editIndexPath;

@end

@interface DCAddMedicationInitialViewController : DCBaseViewController <UIPopoverPresentationControllerDelegate>

@property (nonatomic, assign) id <DCAddMedicationViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *patientId;
@property (nonatomic, strong) DCMedicationScheduleDetails *selectedMedication;
@property (nonatomic, assign) BOOL isEditMedication;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentedContolTopLayoutViewHeight;
@property (nonatomic, strong) NSIndexPath *medicationEditIndexPath;



@end
