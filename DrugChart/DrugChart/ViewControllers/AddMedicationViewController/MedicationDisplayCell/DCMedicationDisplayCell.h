//
//  DCMedicationDisplayCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/20/15.
//
//

#import <UIKit/UIKit.h>
#import "DCMedicationScheduleDetails.h"

@interface DCMedicationDisplayCell : UITableViewCell

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *medicationNameLabelTopSpaceConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *discontinuedLabelHeightConstraint;
- (void)configureCellWithMedicationDetails:(DCMedicationScheduleDetails *)medicationList;
- (void)configureCellForNoMedicationDetails:(NSString *)message;

@end
