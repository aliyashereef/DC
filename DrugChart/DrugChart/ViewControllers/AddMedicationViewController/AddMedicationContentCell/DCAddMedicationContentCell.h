//
//  DCAddMedicationContentCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/2/15.
//
//

#import <UIKit/UIKit.h>

@interface DCAddMedicationContentCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

- (void)configureMedicationContentCellWithWarningsCount:(NSInteger)warningsCount;
- (void)configureContentCellWithContent:(NSString *)content;
- (void)configureMedicationAdministratingTimeCell;

@end
