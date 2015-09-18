//
//  DCOrderSetTableCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/30/15.
//
//

#import <UIKit/UIKit.h>
#import "DCMedicationDetails.h"

@interface DCOrderSetTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView *containerView;

- (void)configureOrderSetCellForMedication:(DCMedicationDetails *)medication;

@end
