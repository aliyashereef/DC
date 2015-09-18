//
//  DCMedicationSearchWebService.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/2/15.
//
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@interface DCMedicationSearchWebService : NSObject

@property (nonatomic, strong) NSString *searchString;

- (void)getCompleteMedicationListWithCallBackHandler:(void (^) (id response, id error))callBackHandler;
- (void)cancelPreviousRequest;

@end
