//
//  DCMedicationListWebService.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 06/03/15.
//
//

#import "DCMedicationListWebService.h"

#define PLIST_NAME @"plistName"

@implementation DCMedicationListWebService

- (void)getMedicationListForPatientDemo:(NSString *)patientId
          withCallBackHandler:(void(^)(NSArray *medicationList, NSDictionary *error))callBackHandler {
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    if (![patientId isEqualToString:INACTIVE]) {
        patientId = @"IPRJ2623512";
    }
    
//    if ([mainBundle pathForResource:patientId ofType:PLIST] == nil) {
//        patientId = @"IPRJ2623512";
//    }
    
    NSArray *medicationArray = [NSArray arrayWithContentsOfFile:[mainBundle pathForResource:patientId ofType:PLIST]];
    if ([medicationArray count] > 0) {
        // call the block after a delay
        double delay = 0.0;
        dispatch_time_t callTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
        dispatch_after(callTime, dispatch_get_main_queue(), ^(void){
            callBackHandler(medicationArray, nil);
        });
    }
}

@end
