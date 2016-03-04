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

- (void)configureDatePickerPropertiesForAddMedication {
    
    //configure picker properties
    _datePicker = nil;
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    _datePicker.date = [DCDateUtility dateInCurrentTimeZone:[NSDate date]];
    _datePicker.timeZone = [NSTimeZone timeZoneWithAbbreviation:GMT];
}

- (void)configureDatePickerPropertiesForAdministrationDate {
    
    //configure picker properties
    _datePicker = nil;
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    _datePicker.maximumDate = [NSDate date];
    _datePicker.minimumDate = nil;
    _datePicker.date = [DCDateUtility dateInCurrentTimeZone:[NSDate date]];
    _datePicker.timeZone = [NSTimeZone timeZoneWithAbbreviation:GMT];
}

- (void)configureDatePickerPropertiesForexpiryDate  {
    
    //configure picker properties
    _datePicker = nil;
    _datePicker.maximumDate = nil;
    _datePicker.minimumDate = [NSDate date];
    _datePicker.date = [DCDateUtility dateInCurrentTimeZone:[NSDate date]];
}

- (IBAction)datePickerValueChanged:(id)sender {
    
    self.selectedDate ([DCDateUtility dateInCurrentTimeZone:_datePicker.date]);
}

@end
