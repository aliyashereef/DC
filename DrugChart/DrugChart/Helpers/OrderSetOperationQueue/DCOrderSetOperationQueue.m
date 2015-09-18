//
//  DCOrderSetOperationQueue.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/7/15.
//
//

#import "DCOrderSetOperationQueue.h"
#import "DCAddMedicationOperation.h"

@implementation DCOrderSetOperationQueue

- (void)executeAddMedicationOperationsInOrdersetQueue:(NSArray *)operationsArray
                                withCompletionHandler:(void (^) (id response, id error))callback {
    
//TODO: confirm how to handle error medication additions in orderset
    NSMutableArray *successIndices = [[NSMutableArray alloc] init];
    NSMutableArray *failedIndices = [[NSMutableArray alloc] init];
    for (DCAddMedicationOperation *operation in operationsArray) {
        [operation callAddMedicationWebServiceWithCallbackHandler:^(id response, NSError *error) {
            if (!error) {
                [successIndices addObject:[NSNumber numberWithInteger:[operationsArray indexOfObject:operation]]];
            } else {
                [failedIndices addObject:[NSNumber numberWithInteger:[operationsArray indexOfObject:operation]]];
            }
            if ([operationsArray lastObject] == operation) {
                callback(@"success", nil);
            }
        }];
        [self addOperation:operation];
    }
}

@end
