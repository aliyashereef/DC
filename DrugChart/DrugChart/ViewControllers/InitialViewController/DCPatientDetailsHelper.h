//
//  DCPatientDetailsHelper.h
//  DrugChart
//
//  Created by aliya on 08/10/15.
//
//

#import <Foundation/Foundation.h>
#import "DCWard.h"
#import "DCPatient.h"
#import "DCBedsAndPatientsWebService.h"
#import "DCBed.h"

@interface DCPatientDetailsHelper : NSObject {
    
    NSMutableArray *wardsArray;
    NSMutableArray *sortedPatientsListArray;
    NSMutableArray *bedsArray;
}

@property NSMutableArray *patientsListArray;

- (void)fetchPatientsInWard:(DCWard *)ward ToGetPatientListwithCallBackHandler:(void (^)(NSError *error, NSMutableArray *patientsArray))callBackHandler;
- (NSMutableArray *)categorizePatientListBasedOnEmergency:(NSMutableArray *)contentArray ;
- (void)setBedsArrayToWard:(DCWard *)ward GraphicalViewControllerwithCallBackHandler:(void (^)(NSError *error ,NSMutableArray *array, NSMutableArray *bedsArray))callBackHandler;

- (void)displayAlertWithTitle:(NSString *)title message:(NSString *)message ;

@end
