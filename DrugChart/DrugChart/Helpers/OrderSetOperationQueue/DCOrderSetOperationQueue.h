//
//  DCOrderSetOperationQueue.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/7/15.
//
//

#import <Foundation/Foundation.h>

@interface DCOrderSetOperationQueue : NSOperationQueue

- (void)executeAddMedicationOperationsInOrdersetQueue:(NSArray *)operationsArray
                 withCompletionHandler:(void (^) (id response, id error))callback;

@end
