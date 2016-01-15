//
//  DCMedicationListViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/2/15.
//
//

#import <UIKit/UIKit.h>
#import "DCBaseViewController.h"
#import "DCMedicationDetails.h"

typedef void(^SelectedMedicationDetails)(DCMedication *medication, NSArray *warnings);

@interface DCMedicationListViewController : DCBaseViewController

@property (nonatomic, strong) SelectedMedicationDetails selectedMedication;
@property (nonatomic, strong) NSString *patientId;
@property (nonatomic)BOOL isLoadingForFirstTimeInHalfScreen;
@property (nonatomic) CGFloat valueForTableTopConstraint;

@end
