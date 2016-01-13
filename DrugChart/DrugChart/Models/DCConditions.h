//
//  DCConditions.h
//  DrugChart
//
//  Created by Felix Joseph on 12/01/16.
//
//

#import <Foundation/Foundation.h>

@interface DCConditions : NSObject

@property (nonatomic, strong) NSString *change;
@property (nonatomic, strong) NSString *dose;
@property (nonatomic, strong) NSString *every;
@property (nonatomic, strong) NSString *until;
@property (nonatomic, strong) NSString *conditionDescription;

@end
