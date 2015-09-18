//
//  DCMedicineNameCellTableViewCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 5/28/15.
//
//

#import <UIKit/UIKit.h>

@interface DCMedicineNameCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *medicineNameLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelHeightConstraint;
@property (nonatomic, strong) NSString *medicineName;

@end
