//
//  DCDatePickerViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 5/20/15.
//
//

#import <UIKit/UIKit.h>

typedef void(^SelectedDateHandlerBlock)(NSDate *date);

@interface DCDatePickerViewController : UIViewController

@property (nonatomic, strong ) SelectedDateHandlerBlock dateHandler;
@property (nonatomic) DatePickerType datePickerType;
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *previousDate;

@end
