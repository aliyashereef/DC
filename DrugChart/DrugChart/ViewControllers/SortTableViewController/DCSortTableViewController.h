//
//  DCSortTableViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/19/15.
//
//

#import <UIKit/UIKit.h>

typedef void(^ SortCriteria)(NSString *criteria);

@interface DCSortTableViewController : UITableViewController

@property (nonatomic, strong) SortCriteria criteria;
@property (nonatomic) SortView sortView;
@property (nonatomic, strong) NSString *previousSelectedCategory;
@property BOOL showDiscontinuedMedications;//bool to identify stopped medications

@end
