//
//  DCScheduling.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 11/11/15.
//
//

#import <Foundation/Foundation.h>
#import "DCRepeat.h"

@interface DCScheduling : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *schedulingDescription;
@property (nonatomic, strong) DCRepeat *repeat;

@end
