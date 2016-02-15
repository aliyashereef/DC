//
//  DCWardsGraphicalDisplayViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 04/06/15.
//
//

#import "DCBaseViewController.h"
#import "DCWard.h"

@interface DCWardsGraphicalDisplayViewController : DCBaseViewController

@property (nonatomic, strong) DCWard *wardDisplayed;
@property (nonatomic, strong) NSMutableArray *bedsArray;

- (void)configureGraphicalView;

@end
