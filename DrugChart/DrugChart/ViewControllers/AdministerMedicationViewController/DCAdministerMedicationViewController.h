//
//  DCAdministerMedicationViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 16/03/15.
//
//

#import "DCBaseViewController.h"
#import "DCAdministerMedication.h"

typedef void (^AdministerMedicationHandlerBlock) (DCAdministerMedication *administerMedication);

@interface DCAdministerMedicationViewController : DCBaseViewController

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topYConstraintToAdministerView;
@property (nonatomic, strong) DCAdministerMedication *administerMedication;
@property (nonatomic, strong) AdministerMedicationHandlerBlock administerMedicationHandler;
@property (nonatomic) BOOL hasChanges;

@property (nonatomic, strong) NSString *patientId;
@property (nonatomic, strong) NSString *scheduleId;
- (IBAction)cancelButtonTapped:(UIButton *)sender;

@end
