//
//  DCTestCaseUtility.m
//  DrugChart
//
//  Created by aliya on 07/07/15.
//
//

#import "DCTestCaseUtility.h"

@implementation DCTestCaseUtility

#pragma mark - Wait Function to handle asynchronous call

+ (BOOL)waitFor:(BOOL *)flag timeout:(NSTimeInterval)timeoutSecs  {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    }
    while (!*flag);
    return *flag;
}

@end
