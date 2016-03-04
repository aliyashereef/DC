//
//  DCDatePickerCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/4/15.
//
//

#import <UIKit/UIKit.h>

typedef void(^SelectedDate)(NSDate *date);

@interface DCDatePickerCell : UITableViewCell

@property (weak)  IBOutlet UIDatePicker *datePicker;
@property BOOL isStartDate;
@property (nonatomic, strong) SelectedDate selectedDate;

- (void)configureDatePickerPropertiesForAddMedication;
- (void)configureDatePickerPropertiesForAdministrationDate;
- (void)configureDatePickerPropertiesForexpiryDate;

@end
