//
//  DCPatientAllergyNotificationTableViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 29/04/15.
//
//

#import <UIKit/UIKit.h>

@interface DCPatientAllergyNotificationTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *allergiesArray;

- (CGFloat)getTableViewHeight;

@end
