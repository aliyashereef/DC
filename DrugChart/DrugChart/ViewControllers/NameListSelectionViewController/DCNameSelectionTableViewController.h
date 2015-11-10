//
//  DCNameSelectionTableViewController
//  DrugChart
//
//  Created by Muhammed Shaheer on 17/03/15.
//
//

#import <UIKit/UIKit.h>

@protocol NamesListDelegate <NSObject>

@optional

- (void)selectedUserEntry:(DCUser *)user;

@end

typedef void(^UserSelectionHandlerBlock)(DCUser *user);

@interface DCNameSelectionTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *namesArray;
@property (nonatomic, strong) UserSelectionHandlerBlock userSelectionHandler;
@property (nonatomic, strong) NSString *previousSelectedValue;
@property (nonatomic, weak) id <NamesListDelegate> namesDelegate;

@end
