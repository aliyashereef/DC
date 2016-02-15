//
//  DCDosage.h
//  DrugChart
//
//  Created by Felix Joseph on 12/01/16.
//
//

#import <Foundation/Foundation.h>
#import "DCFixedDose.h"
#import "DCVariableDose.h"
#import "DCReducingIncreasingDose.h"
#import "DCSplitDailyDose.h"

@interface DCDosage : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *doseUnit;
@property (nonatomic, strong) DCFixedDose *fixedDose;
@property (nonatomic, strong) DCVariableDose *variableDose;
@property (nonatomic, strong) DCReducingIncreasingDose *reducingIncreasingDose;
@property (nonatomic, strong) DCSplitDailyDose *splitDailyDose;

@end
