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
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *restartedDate;
@property (nonatomic, strong) NSString *expiryDate;
@property (nonatomic, strong) DCMedicationSlot *medicationSlot;

@property (nonatomic, weak) id <StatusListDelegate> medicationStatusDelegate;

@end
