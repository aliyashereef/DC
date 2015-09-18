//
//  DCAlertsAllergyTableViewCell.h
//  DrugChart
//
//  Created by aliya on 25/08/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatientAllergy.h"
#import "DCPatientAlert.h"

@interface DCAlertsAllergyTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *alertsAllergyLabel;

- (void)configurePatientsAlertCell:(DCPatientAlert *)patientAlert ;
- (void)configurePatientsAllergyCell:(DCPatientAllergy *)patientAllergy ;

@end
