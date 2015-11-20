//
//  DCRepeat.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 11/12/15.
//
//

#import <Foundation/Foundation.h>

@interface DCRepeat : NSObject

@property (nonatomic, strong) NSString *repeatType;
@property (nonatomic, strong) NSString *frequency;
@property (nonatomic, strong) NSMutableArray *weekDays;
@property (nonatomic, strong) NSString *weekDay;
@property (nonatomic) BOOL isEachValue;
@property (nonatomic, strong) NSString *eachValue;
@property (nonatomic, strong) NSString *onTheValue;

@end
