//
//  DCDateTableViewCell.h
//  DrugChart
//
//  Created by aliya on 03/09/15.
//
//

#import <UIKit/UIKit.h>

typedef void(^NoEndDateStatus)(BOOL state);

@interface DCDateTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *dateTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateValueLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateTypeWidth;
@property (weak, nonatomic) IBOutlet UISwitch *noEndDateSwitch;
@property (nonatomic, strong) NoEndDateStatus noEndDateStatus;
@property (nonatomic) BOOL previousSwitchState;

- (void)configureContentCellWithContent:(NSString *)content;
- (void)configureCellWithNoEndDateSwitchState:(BOOL)state;

@end
