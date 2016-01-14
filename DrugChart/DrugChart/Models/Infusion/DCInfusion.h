//
//  DCInfusion.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/13/16.
//
//

#import <Foundation/Foundation.h>
#import "DCBolusInjection.h"

@interface DCInfusion : NSObject

@property (nonatomic, strong) NSString *administerAsOption;
@property (nonatomic, strong) DCBolusInjection *bolusInjection;

@end
