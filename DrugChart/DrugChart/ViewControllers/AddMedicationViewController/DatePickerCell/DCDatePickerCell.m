//
//  DCDatePickerCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/4/15.
//
//

#import "DCDatePickerCell.h"

//@interface DCDatePickerCell () {
//    
//    __weak IBOutlet UIDatePicker *datePicker;
//    
//}
//
//@end

@implementation DCDatePickerCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)datePickerValueChanged:(id)sender {
    
    self.selectedDate (_datePicker.date);
}


@end
