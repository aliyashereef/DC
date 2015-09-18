//
//  DCPatientAlertsNotificationTableViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 29/04/15.
//
//

#import <UIKit/UIKit.h>

@interface DCPatientAlertsNotificationTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *patientsAlertsArray;

- (CGFloat)getTableViewHeight;

@end
