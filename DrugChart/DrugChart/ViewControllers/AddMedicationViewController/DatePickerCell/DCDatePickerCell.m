//
//  DCDatePickerCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/4/15.
//
//

#import "DCDatePickerCell.h"

@implementation DCDatePickerCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureDatePickerProperties {
    
    //configure picker properties
    _datePicker.date = [NSDate date];
    _datePicker.timeZone = [NSTimeZone timeZoneWithAbbreviation:GMT];
}

- (IBAction)datePickerValueChanged:(id)sender {
    
    self.selectedDate (_datePicker.date);
}

@end
