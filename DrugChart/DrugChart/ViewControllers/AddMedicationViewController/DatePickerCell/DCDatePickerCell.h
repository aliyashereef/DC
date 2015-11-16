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

@property BOOL isStartDate;
@property (nonatomic, strong) SelectedDate selectedDate;


@end
