//
//  DCAlertsWebService.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 29/06/15.
//
//

#import <Foundation/Foundation.h>
#import "DCHTTPRequestOperationManager.h"

@interface DCAlertsWebService : NSObject

- (void)patientAlertsForId:(NSString *)patientId
        withCallBackHandler:(void (^)(NSArray *alertsArray, NSError *error))callBackHandler;

@end