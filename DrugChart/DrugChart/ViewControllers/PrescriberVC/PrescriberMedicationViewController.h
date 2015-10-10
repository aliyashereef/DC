//
//  PrescriberMedicationViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 27/09/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatient.h"

@interface PrescriberMedicationViewController : DCBaseViewController

@property (nonatomic, strong) DCPatient *patient;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
- (void)displayAdministrationViewForMedicationSlot:(NSDictionary *)medicationSLotsDictionary
                                       atIndexPath:(NSIndexPath *)indexPath
                                      withWeekDate:(NSDate *)date;
@end
