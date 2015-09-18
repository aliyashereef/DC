//
//  DCAlergyDisplayCell.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 20/04/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatientAllergy.h"

@interface DCAlergyDisplayCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *warningLabel;

- (void)configurePatientAllergyCell:(DCPatientAllergy *)patientAllergy;
- (void)configurePatientAllergyCellForNoAllergies:(NSString *)message;

@end
