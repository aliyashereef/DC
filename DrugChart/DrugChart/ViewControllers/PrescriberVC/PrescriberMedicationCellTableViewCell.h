//
//  PrescriberMedicationCellTableViewCell.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 28/09/15.
//
//

#import <UIKit/UIKit.h>

@interface PrescriberMedicationCellTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *medicineName;
@property (nonatomic, strong) IBOutlet UILabel *route;
@property (nonatomic, strong) IBOutlet UILabel *instructions;

@end
