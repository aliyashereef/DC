//
//  DCOrderSetWebService.h
//  DrugChart
//
//  Created by aliya on 28/07/15.
//
//

#import <Foundation/Foundation.h>
#import "DCHTTPRequestOperationManager.h"

@interface DCOrderSetWebService : NSObject

- (void)getAllOrderSetsWithCallBackHandler:(void (^)(NSArray *orderSetsArray, NSError *error))callBackHandler;
@end
