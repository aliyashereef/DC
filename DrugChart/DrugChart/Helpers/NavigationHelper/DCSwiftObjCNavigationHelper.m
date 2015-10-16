//
//  DCSwiftObjCNavigationHelper.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 08/10/15.
//
//

#import "DCSwiftObjCNavigationHelper.h"

#import "PrescriberMedicationViewController.h"


@implementation DCSwiftObjCNavigationHelper

+ (void)goToPrescriberMedicationViewControllerForPatient:(DCPatient *)patient fromNavigationController:(UINavigationController *)navigationController {
    
    UIStoryboard *prescriberStoryBoard = [UIStoryboard storyboardWithName:PRESCRIBER_DETAILS_STORYBOARD
                                                                   bundle:nil];
    PrescriberMedicationViewController *prescriberMedicationViewController = [prescriberStoryBoard instantiateViewControllerWithIdentifier:PRESCRIBER_MEDICATION_SBID];
    prescriberMedicationViewController.patient = patient;
    [navigationController pushViewController:prescriberMedicationViewController animated:YES];
}

- (void)reloadPrescriberMedicationHomeViewController {
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadPrescriberMedicationList)]) {
        [self.delegate reloadPrescriberMedicationList];
    }
}

@end
