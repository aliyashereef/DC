//
//  DCDatePickerViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 5/20/15.
//
//

#import "DCDatePickerViewController.h"

#define NETHERLANDS_LOCALE @"NL"

#define TIME_PICKER_TOP_VIEW_FRAME CGRectMake(0, 3, 300, 35)
#define TIME_PICKER_FRAME CGRectMake(0, 33, 300, 149.0f)
#define DATE_PICKER_TOP_VIEW_FRAME CGRectMake(0, 33, 300, 35.0f)
#define DATE_PICKER_FRAME CGRectMake(0, 3, 300, 149.0f)

@interface DCDatePickerViewController () {
    
    __weak IBOutlet UIDatePicker *datePicker;
    __weak IBOutlet UIView *topView;
}

@end

@implementation DCDatePickerViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [datePicker setDate:[NSDate date]];
    [self configureViewElements];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

- (void)configureViewElements {
    
    [self configureDatePickerView];
    [datePicker setMinimumDate:_minimumDate];
    if (_previousDate) {
        [datePicker setDate:_previousDate];
    }
}

- (void)configureDatePickerView {
    
    switch (_datePickerType) {
            
        case eTimePicker: {
            [topView setFrame:TIME_PICKER_TOP_VIEW_FRAME];
            [datePicker setFrame:TIME_PICKER_FRAME];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:NETHERLANDS_LOCALE];
            [datePicker setLocale:locale];
            datePicker.datePickerMode = UIDatePickerModeTime;
        }
             break;
            
        case eDatePicker:
        case eStartDatePicker:
        case eEndDatePicker:
            datePicker.datePickerMode = UIDatePickerModeDateAndTime;
            [topView setFrame:DATE_PICKER_TOP_VIEW_FRAME];
            [datePicker setFrame:DATE_PICKER_FRAME];
            break;
            
        default:
            break;
    }
}

#pragma mark - Action methods

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonPressed:(id)sender {
    
    self.dateHandler (datePicker.date);
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
