//
//  DCWarningsTableCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/21/15.
//
//

#import "DCWarningsTableCell.h"

#define TITLE_MAX_WIDTH                     257.0f
#define NO_WARNING_TITLE_LEADING            15.0f
#define NO_WARNING_TITLE_TOP                20.0f
#define DEFAULT_WARNING_TITLE_LEADING       28.0f
#define DEFAULT_WARNING_TITLE_TOP           5.0f

@interface DCWarningsTableCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleTopConstraint;


@end

@implementation DCWarningsTableCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (void)configureWarningsCellForWarningsObject:(DCWarning *)warning {
    
    _titleLeadingConstraint.constant = DEFAULT_WARNING_TITLE_LEADING;
    _titleTopConstraint.constant = DEFAULT_WARNING_TITLE_TOP;
    _titleLabel.text = warning.title;
    _titleHeightConstraint.constant = [DCUtility getRequiredSizeForText:_titleLabel.text
                                                                   font:[DCFontUtility getLatoBoldFontWithSize:13.0f]
                                                               maxWidth:TITLE_MAX_WIDTH].height + 5;
    _descriptionLabel.text =  warning.detail;
    [self layoutIfNeeded];
}

- (void)configureCellForNoWarnings:(NSString *)message {
    
    _titleLeadingConstraint.constant = NO_WARNING_TITLE_LEADING;
    _titleTopConstraint.constant = NO_WARNING_TITLE_TOP;
     _titleLabel.text = message;
    _descriptionLabel.text =  EMPTY_STRING;
}

@end
