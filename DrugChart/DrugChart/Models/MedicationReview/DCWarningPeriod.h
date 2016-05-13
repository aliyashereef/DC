//
//  DCWarningPeriod.h
//  DrugChart
//
//  Created by aliya on 11/05/16.
//
//

#import <Foundation/Foundation.h>

@interface DCWarningPeriod : NSObject

@property (nonatomic) BOOL hasWarningPeriod;
@property (nonatomic, strong) NSString *warningPeriodInterval;
@property (nonatomic, strong) NSString *warningPeriodUnit;

@end
