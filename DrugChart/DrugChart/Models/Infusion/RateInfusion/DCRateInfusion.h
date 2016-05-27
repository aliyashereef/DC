//
//  DCRateInfusion.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/14/16.
//
//

#import <Foundation/Foundation.h>
#import "DCInjection.h"

@interface DCRateInfusion : DCInjection

@property (nonatomic, strong) NSString *startingRate;
@property (nonatomic, strong) NSString *unit;
@property (nonatomic, strong) NSString *minimumRate;
@property (nonatomic, strong) NSString *maximumRate;

@end
