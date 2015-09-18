//
//  DCMedicationViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/6/15.
//
//

#import <UIKit/UIKit.h>

@interface DCMedicationViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *medicationListArray;
@property (nonatomic, strong) IBOutlet UITableView *medicationTableView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSIndexPath *previousSelectedIndexPath;

- (void) reloadMedicationList;
- (void) toggleSegmentedControlState:(BOOL) administerViewShown ;

@end
