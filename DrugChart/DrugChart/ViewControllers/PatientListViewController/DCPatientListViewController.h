//
//  DCPatientListViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 03/03/15.
//
//

#import <UIKit/UIKit.h>
#import "DCWard.h"

@interface DCPatientListViewController : DCBaseViewController

@property (nonatomic, strong) DCWard *selectedWard;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
