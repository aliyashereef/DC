//
//  DCWardsPatientsListingViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 04/06/15.
//
//

#import "DCBaseViewController.h"
#import "DCWard.h"

@interface DCWardsPatientsListingViewController : DCBaseViewController

@property (nonatomic, strong) DCWard *selectedWard;
@property (nonatomic, strong) NSMutableArray *bedsArray;

- (void)recievedPatientListingResponse;

@end
