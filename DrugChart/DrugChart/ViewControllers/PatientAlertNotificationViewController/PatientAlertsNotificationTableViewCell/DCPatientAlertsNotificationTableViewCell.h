//
//  DCPatientAlertsNotificationTableViewCell.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 29/04/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatientAlert.h"

@interface DCPatientAlertsNotificationTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *severityImageVIew;
@property (strong, nonatomic) IBOutlet UILabel *alertTextLabel;
//@property (strong, nonatomic) IBOutlet UILabel *alertDateLabel;

- (void)configurePatientsAlertCell:(DCPatientAlert *)patientAlert;

@end
