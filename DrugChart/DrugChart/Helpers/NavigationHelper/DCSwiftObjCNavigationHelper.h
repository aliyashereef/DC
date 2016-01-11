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

- (void)reloadPrescriberMedicationListWithCompletionHandler:(void(^)(BOOL success))completion;

@end

@interface DCSwiftObjCNavigationHelper : NSObject

@property (nonatomic, strong) id <AdministrationDelegate> delegate;

+ (void)goToPrescriberMedicationViewControllerForPatient:(DCPatient *)patient fromNavigationController:(UINavigationController *)navigationController;

- (void)reloadPrescriberMedicationHomeViewControllerWithCompletionHandler:(void(^)(BOOL success))completion;

@end
