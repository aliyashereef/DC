//
//  DCAutoSearchView.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/1/15.
//
//

#import <UIKit/UIKit.h>
#import "DCOrderSet.h"
#import "DCMedication.h"

@protocol DCAutoSearchDelegate <NSObject>

@optional

- (void)selectedOrderSet:(DCOrderSet *)orderSet;
- (void)selectedMedication:(DCMedication *)medication;

@end

@interface DCAutoSearchView : UIView 

@property (nonatomic, weak) IBOutlet UITableView *autoFillTableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSMutableArray *searchListArray;
@property (nonatomic, strong) NSMutableArray *searchedContentsArray;
@property (nonatomic, strong) NSMutableArray *favouriteContentsArray;
@property (nonatomic, weak) id <DCAutoSearchDelegate> searchDelegate;
@property (nonatomic) AutoSearchType autoSearchType;
@property (nonatomic) BOOL minimumLimit;
@property (nonatomic) CGFloat searchTableViewCellHeight;

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring ;

@end
