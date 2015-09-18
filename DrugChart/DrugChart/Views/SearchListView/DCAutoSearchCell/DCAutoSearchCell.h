//
//  DCAUtoSearchCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/2/15.
//
//

#import <UIKit/UIKit.h>

@interface DCAutoSearchCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *searchNameLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *nameLabelHeightConstraint;
@property (nonatomic, weak) NSString *searchValue;

@end
