//
//  PrescriberMedicationViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 27/09/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatient.h"

#import "DrugChart-Swift.h"


@protocol DCMedicationAdministrationStatusProtocol;

@interface PrescriberMedicationViewController : DCBaseViewController <DCMedicationAdministrationStatusProtocol>

@property (nonatomic, strong) DCPatient *patient;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;


@end
