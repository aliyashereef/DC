//
//  Intervention.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/31/16.
//
//

#import <Foundation/Foundation.h>

@interface DCIntervention : NSObject

@property (nonatomic, strong) NSString *createdBy;
@property (nonatomic, strong) NSString *createdOn;
@property (nonatomic, strong) NSString *reason;
@property (nonatomic, strong) NSString *resolution;
@property BOOL toResolve; // TODO: temporarly set the bool, should be corrected on api integration

@end
