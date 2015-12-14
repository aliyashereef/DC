//
//  DCInterval.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 12/8/15.
//
//

#import <Foundation/Foundation.h>

@interface DCInterval : NSObject

@property (nonatomic, strong) NSString *repeatFrequencyType;
@property (nonatomic, strong) NSString *daysCount;
@property (nonatomic, strong) NSString *hoursCount;
@property (nonatomic, strong) NSString *minutesCount;
@property (nonatomic) BOOL hasStartAndEndDate;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSString *intervalDescription;

@end
