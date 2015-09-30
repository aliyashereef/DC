//
//  DCMedicationSchedulesWebService.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 07/07/15.
//
//

#import <Foundation/Foundation.h>

@interface DCMedicationSchedulesWebService : NSObject

- (void)getMedicationSchedulesForPatientId:(NSString *)patientId
                       withCallBackHandler:(void(^)(NSArray *medicationListArray, NSError *error))completionHandler;

- (void)getMedicationSchedulesForPatientId:(NSString *)patientId
                                 fromStartDate:(NSString *)startDate
                                   toEndDate:(NSString *)endDate
                       withCallBackHandler:(void (^)(NSArray *, NSError *))completionHandler;
    
- (void)cancelPreviousRequest;

@end
