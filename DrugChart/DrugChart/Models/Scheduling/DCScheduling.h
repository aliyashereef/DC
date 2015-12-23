//
//  DCScheduling.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 11/11/15.
//
//

#import <Foundation/Foundation.h>
#import "DCSpecificTimes.h"
#import "DCInterval.h"

@interface DCScheduling : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) DCSpecificTimes *specificTimes;
@property (nonatomic, strong) DCInterval *interval;

@end
