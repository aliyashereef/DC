//
//  DCSwiftObjCNavigationHelper.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 08/10/15.
//
//

#import "DCSwiftObjCNavigationHelper.h"

#import "DCPrescriberMedicationViewController.h"


@implementation DCSwiftObjCNavigationHelper

+ (void)goToPrescriberMedicationViewControllerForPatient:(DCPatient *)patient
                                fromNavigationController:(UINavigationController *)navigationController {
    
    UIStoryboard *prescriberStoryBoard = [UIStoryboard storyboardWithName:PRESCRIBER_DETAILS_STORYBOARD
                                                                   bundle:nil];
    DCPrescriberMedicationViewController *prescriberMedicationViewController = [prescriberStoryBoard instantiateViewControllerWithIdentifier:PRESCRIBER_MEDICATION_SBID];
    prescriberMedicationViewController.patient = patient;
    [navigationController pushViewController:prescriberMedicationViewController animated:YES];
}

- (void)reloadPrescriberMedicationHomeViewControllerWithCompletionHandler:(void(^)(BOOL success))completion {
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadPrescriberMedicationListWithCompletionHandler:)]) {
        [self.delegate reloadPrescriberMedicationListWithCompletionHandler:^(BOOL success) {
            completion(success);
        }];
    }
}

@end
