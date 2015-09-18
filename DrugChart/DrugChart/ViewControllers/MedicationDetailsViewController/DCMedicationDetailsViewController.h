//
//  DCMedicationDetailsViewController.h
//  DrugChart
//
//  Created by Vineeth  on 22/05/15.
//
//

#import <UIKit/UIKit.h>
#import "DCMedicationScheduleDetails.h"

@interface DCMedicationDetailsViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *medicineNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *dosageLabel;
@property (nonatomic, weak) IBOutlet UILabel *doctorNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *startDateTitleLabel;

@property (nonatomic, strong) DCMedicationScheduleDetails *selectedMedicationList;

@end
