//
//  DCPatientListCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/18/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatient.h"

@interface DCPatientListCell : UITableViewCell

- (void)populatePatientCellWithPatientDetails:(DCPatient *)patient;

@end
