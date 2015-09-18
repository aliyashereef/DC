//
//  DCWarningsPopoverCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/23/15.
//
//

#import <UIKit/UIKit.h>
#import "DCWarning.h"

@interface DCWarningsPopoverCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView *separatorView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionHeightConstraint;

- (void)configureWarningsCellForWarningsObject:(DCWarning *)warning;

@end
