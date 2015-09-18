//
//  DCPrescriberFilterTableViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/1/15.
//
//

#import <UIKit/UIKit.h>

typedef void(^ FilterCriteria)(NSString *criteria);

@protocol DCPrescriberFilterTableViewControllerDelegate <NSObject>
- (void)sortMedicationListSelectionChanged:(NSInteger)currentSelection;
@end

@interface DCPrescriberFilterTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) FilterCriteria filterCriteria;

@property (nonatomic, assign) id <DCPrescriberFilterTableViewControllerDelegate> delegate;

@end
