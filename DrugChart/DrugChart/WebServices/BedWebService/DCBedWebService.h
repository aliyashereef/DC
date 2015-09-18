//
//  DCBedWebService.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 24/04/15.
//
//

#import <Foundation/Foundation.h>
#import "DCHTTPRequestOperationManager.h"

@interface DCBedWebService : NSObject

- (void)getBedDetailsInWard:(NSString *)wardNumber
        withCallBackHandler:(void (^)(NSArray *bedArray, NSError *error))callBackHandler;

@end
