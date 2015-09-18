//
//  DCTestCaseUtility.h
//  DrugChart
//
//  Created by aliya on 07/07/15.
//
//

#import <Foundation/Foundation.h>

@interface DCTestCaseUtility : NSObject

+ (BOOL)waitFor:(BOOL *)flag timeout:(NSTimeInterval)timeoutSecs;

@end
