//
//  DCDateTableViewCell.m
//  DrugChart
//
//  Created by aliya on 03/09/15.
//
//

#import "DCDateTableViewCell.h"

@implementation DCDateTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _previousSwitchState = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public Methods

- (void)configureContentCellWithContent:(NSString *)content {
    
    [_dateValueLabel setHidden:NO];
    [_dateValueLabel setText:content];
    [_noEndDateSwitch setHidden:YES];
}

- (void)configureCellWithNoEndDateSwitchState:(BOOL)state {
    
    [_dateTypeLabel setText:NSLocalizedString(@"NO_END_DATE", @"No end date title")];
    [_dateValueLabel setHidden:YES];
    [_noEndDateSwitch setHidden:NO];
    [_noEndDateSwitch setOn:state];
}

#pragma mark - Action Methods

- (IBAction)noEndDateSwitchSelected:(id)sender {
    
    //no end date switch action
    BOOL switchState = [sender isOn];
    if (switchState != _previousSwitchState) {
        _previousSwitchState = switchState;
        self.noEndDateStatus (switchState);
    }
}

@end
