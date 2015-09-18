//
//  DCCalendarChartViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/6/15.
//
//

#import <UIKit/UIKit.h>
#import "DCMedicationScheduleDetails.h"
#import "DCAdministerMedication.h"

@interface DCCalendarChartViewController : UIViewController

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *calenderHeaderLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *calenderTableViewLeadingConstraint;


- (void)setDisplayMedicationList:(DCMedicationScheduleDetails *)medicationList;
- (void)getUpdatedAdministerMedicationObject:(DCAdministerMedication *)administerMedication;
- (void)updateViewOnAdministerScreenAppear:(BOOL)shown;
- (void)configureViewIfmedicationListIsEmpty;
- (IBAction)infoButtonPressed:(id)sender;

@end
