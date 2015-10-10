//
//  DCSwiftObjCNavigationHelper.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 08/10/15.
//
//

#import <Foundation/Foundation.h>
#import "DCPatient.h"

@interface DCSwiftObjCNavigationHelper : NSObject

+ (void)goToPrescriberMedicationViewControllerForPatient:(DCPatient *)patient fromNavigationController:(UINavigationController *)navigationController;

@end
