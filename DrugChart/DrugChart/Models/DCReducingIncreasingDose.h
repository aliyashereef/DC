//
//  DCReducingIncreasingDose.h
//  DrugChart
//
//  Created by Felix Joseph on 12/01/16.
//
//

#import <Foundation/Foundation.h>
#import "DCConditions.h"

@interface DCReducingIncreasingDose : NSObject

@property (nonatomic, strong) NSString *startingDose;
@property (nonatomic, strong) NSString *changeOver;
@property (nonatomic, strong) NSMutableArray *conditionsArray;
@property (nonatomic, strong) DCConditions *conditions;

@end
