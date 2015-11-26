//
//  DCCalendarNavigationTitleView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/25/15.
//
//

#import "DCCalendarNavigationTitleView.h"

@interface DCCalendarNavigationTitleView ()

@property (weak, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nhsLabel;
@property (weak, nonatomic) IBOutlet UILabel *dobLabel;

@end

@implementation DCCalendarNavigationTitleView


- (void)layoutSubviews {
    
    [self configurePatientNameContentAlignmentProperty];
    [super layoutSubviews];
}

- (void)configurePatientNameContentAlignmentProperty {
    
    NSInteger horizontalClass = self.traitCollection.horizontalSizeClass;
    switch (horizontalClass) {
        case UIUserInterfaceSizeClassCompact :
            _patientNameLabel.textAlignment = [DCUtility mainWindowSize].width < HALF_WIDTH_LIMIT ?
            NSTextAlignmentLeft : NSTextAlignmentCenter;
            break;
        default :
            _patientNameLabel.textAlignment = NSTextAlignmentRight;
            break;
    }
}

- (void)populateViewWithPatientName:(NSString *)patientName
                          nhsNumber:(NSString *)nhs
                        dateOfBirth:(NSDate *)dob
                                age:(NSString *)age{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:BIRTH_DATE_FORMAT];
    NSString *dobDateString =  [dateFormatter stringFromDate:dob];
    _patientNameLabel.text = patientName;
    _nhsLabel.text = nhs;
    _dobLabel.text = [NSString stringWithFormat:@"%@ (%@ years)",dobDateString,age];
}

@end
