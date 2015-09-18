//
//  NameSelectionTableViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 17/03/15.
//
//

#import <UIKit/UIKit.h>

typedef void(^UserSelectionHandlerBlock)(NSString *user);

@interface NameSelectionTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *namesArray;
@property (nonatomic, strong) UserSelectionHandlerBlock userSelectionHandler;

@end
