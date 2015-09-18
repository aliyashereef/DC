//
//  DCCalendarNavigationTitleView.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/25/15.
//
//

#import <UIKit/UIKit.h>

@interface DCCalendarNavigationTitleView : UIView

- (void)populateViewWithPatientName:(NSString *)patientName
                          nhsNumber:(NSString *)nhs
                        dateOfBirth:(NSDate *)dob
                                age:(NSString *)age;


@end
