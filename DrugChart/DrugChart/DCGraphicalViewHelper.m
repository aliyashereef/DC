//
//  DCGraphicalViewHelper.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 02/07/15.
//
//

#import "DCGraphicalViewHelper.h"

#define OPERATIONAL @"Operational"
#define CLOSED_FOR_CLEANING @"ClosedForCleaning"
#define CLOSED_FOR_REPAIR @"ClosedForRepair"


@implementation DCGraphicalViewHelper

+ (UIImage *)bedImageForBedType:(NSString *)bedType
             bedOperationStatus:(NSString *)bedStatus
                containsPatient:(BOOL)hasPatient {
    
    if (hasPatient) {
        NSString *imageNameString = [NSString stringWithFormat:@"Occupied%@",bedType];
        return [UIImage imageNamed:imageNameString];
    }
    else {
        if ([bedStatus isEqualToString:OPERATIONAL]) {
            NSString *imageNameString = [NSString stringWithFormat:@"Empty%@",bedType];
            return [UIImage imageNamed:imageNameString];
        }
        else {
            NSString *imageNameString = [NSString stringWithFormat:@"%@%@", bedStatus, bedType];
            return [UIImage imageNamed:imageNameString];
        }
    }
}

@end
