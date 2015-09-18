//
//  DCPatientTableViewCell.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 03/03/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatient.h"

@interface DCPatientTableViewCell : UITableViewCell

- (void)configurePatientCellWithPatientDetails:(DCPatient *)patient;

@end
