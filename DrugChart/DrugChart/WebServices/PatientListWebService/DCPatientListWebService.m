//
//  DCPatientListWebService.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 03/03/15.
//
//

#import "DCPatientListWebService.h"

static NSString *const testPlist = @"TestPatientList";

@implementation DCPatientListWebService

- (void)getPatientListForUser:(NSString *)userName
          withCallBackHandler:(void(^)(NSArray *patientListArray, NSDictionary *error))callBackHandler {
    
    //TODO: The webservice call has to be made from here. Currently loading test data from the plist
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSArray *patientArray = [NSArray arrayWithContentsOfFile:[mainBundle pathForResource:testPlist ofType:PLIST]];
    if ([patientArray count] > 0) {
        // call the block after a delay
        double delay = 0.5;
        dispatch_time_t callTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
        dispatch_after(callTime, dispatch_get_main_queue(), ^(void){
            callBackHandler(patientArray,nil);
        });
    }
}

@end
