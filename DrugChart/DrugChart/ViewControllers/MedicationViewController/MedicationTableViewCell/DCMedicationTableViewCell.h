//
//  DCMedicationTableViewCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/6/15.
//
//

#import <UIKit/UIKit.h>
#import "DCMedicationScheduleDetails.h"

@interface DCMedicationTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *medicineNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *dosageLabel;
@property (nonatomic, weak) IBOutlet UILabel *doctorNameLabel;
@property (nonatomic, weak) IBOutlet UIView *selectionView;
@property (nonatomic, weak) DCMedicationScheduleDetails *medicationList;
@property (nonatomic, weak) IBOutlet UIButton *statusButton;
@property (nonatomic, weak) IBOutlet UILabel *medicationCategoryLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *medicineNameHeightConstraint;


- (void)configureMedicationCellWithMedicationDetails:(DCMedicationScheduleDetails *)medicationList
                                    forMenuSelection:(NSInteger)selection;
- (void)configureSelectedStateForSelection:(BOOL)isSelected;

@end
