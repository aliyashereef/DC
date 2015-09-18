//
//  DCWarningsTableCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/21/15.
//
//

#import <UIKit/UIKit.h>
#import "DCWarning.h"

@interface DCWarningsTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleHeightConstraint;

- (void)configureWarningsCellForWarningsObject:(DCWarning *)warning;
- (void)configureCellForNoWarnings:(NSString *)message;

@end
