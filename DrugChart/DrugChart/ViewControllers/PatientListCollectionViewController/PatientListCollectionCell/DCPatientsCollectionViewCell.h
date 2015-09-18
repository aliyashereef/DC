//
//  DCPatientsCollectionViewCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/19/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatient.h"

@interface DCPatientsCollectionViewCell : UICollectionViewCell

- (void)populatePatientCellWithPatientDetails:(DCPatient *)patient;

@end
