//
//  DCAdministrationStatusTableViewController.h
//  DrugChart
//
//  Created by aliya on 14/10/15.
//
//

#import <UIKit/UIKit.h>

@protocol StatusListDelegate <NSObject>

@optional

- (void)selectedMedicationStatusEntry:(NSString *)status;

@end

@interface DCAdministrationStatusTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *namesArray;
@property (nonatomic, strong) NSString *previousSelectedValue;
@property (nonatomic, weak) id <StatusListDelegate> medicationStatusDelegate;

@end