//
//  DCSpecificTimes.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 12/8/15.
//
//

#import <Foundation/Foundation.h>
#import "DCRepeat.h"

@interface DCSpecificTimes : NSObject

@property (nonatomic, strong) DCRepeat *repeatObject;
@property (nonatomic, strong) NSString *specificTimesDescription;

@end
