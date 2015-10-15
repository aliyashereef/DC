//
//  DCSwiftObjCNavigationHelper.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 08/10/15.
//
//

#import <Foundation/Foundation.h>
#import "DCPatient.h"

@protocol AdministrationDelegate<NSObject>

- (void)reloadPrescriberMedicationList;

@end

@interface DCSwiftObjCNavigationHelper : NSObject

@property (nonatomic, strong) id <AdministrationDelegate> delegate;

+ (void)goToPrescriberMedicationViewControllerForPatient:(DCPatient *)patient fromNavigationController:(UINavigationController *)navigationController;

- (void)reloadPrescriberMedicationHomeViewController;

@end
