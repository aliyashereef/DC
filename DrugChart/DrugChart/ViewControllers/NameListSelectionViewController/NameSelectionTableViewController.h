//
//  NameSelectionTableViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 17/03/15.
//
//

#import <UIKit/UIKit.h>

@protocol NamesListDelegate <NSObject>

@optional

- (void)selectedUserEntry:(NSString *)user;

@end

typedef void(^UserSelectionHandlerBlock)(NSString *user);

@interface NameSelectionTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *namesArray;
@property (nonatomic, strong) UserSelectionHandlerBlock userSelectionHandler;
@property (nonatomic, strong) NSString *previousSelectedValue;
@property (nonatomic, weak) id <NamesListDelegate> namesDelegate;

@end
