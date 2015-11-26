//
//  DCAlertsAllergyPopOverViewController.h
//  DrugChart
//
//  Created by aliya on 25/08/15.
//
//

#import <UIKit/UIKit.h>

@interface DCAlertsAllergyPopOverViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *patientsAlertsArray;
@property (nonatomic, strong) NSMutableArray *patientsAllergyArray;

- (CGFloat)allergyAndAlertDisplayTableViewHeightForContent:(NSArray *)displayArray ;

@end
