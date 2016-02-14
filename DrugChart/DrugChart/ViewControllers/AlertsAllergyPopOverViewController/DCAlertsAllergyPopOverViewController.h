//
//  DCAlertsAllergyPopOverViewController.h
//  DrugChart
//
//  Created by aliya on 25/08/15.
//
//

#import <UIKit/UIKit.h>

typedef void(^ViewDismissed)();

@interface DCAlertsAllergyPopOverViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *patientsAlertsArray;
@property (nonatomic, strong) NSMutableArray *patientsAllergyArray;
@property (nonatomic, strong) ViewDismissed viewDismissed;

- (CGFloat)allergyAndAlertDisplayTableViewHeightForContent:(NSArray *)displayArray ;

@end
