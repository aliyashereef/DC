//
//  DCPrescriberDetailsViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 5/12/15.
//
//

#import <UIKit/UIKit.h>
#import "DCMedicationScheduleDetails.h"

@interface DCPrescriberDetailsViewController : UIViewController  <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) DCMedicationScheduleDetails *medicationList;
@property (nonatomic, strong) NSString *displayDateString;
@property (nonatomic, strong) NSArray *slotsArray;

@end
