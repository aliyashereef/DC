//
//  DCAddMedicationPopOverViewController.h
//  DrugChart
//
//  Created by aliya on 25/08/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatient.h"

@protocol DCAddMedicationViewControllerDelegate <NSObject>

- (void)addedNewMedicationForPatient;

@end

@interface DCAddMedicationInitialViewController : UIViewController

@property (nonatomic, assign) id <DCAddMedicationViewControllerDelegate> delegate;
@property (nonatomic, strong) DCPatient *patient;

@end
