//
//  DCConditions.m
//  DrugChart
//
//  Created by Felix Joseph on 12/01/16.
//
//

#import "DCConditions.h"

@implementation DCConditions

- (id)init {
    self = [super init];
    
    if (self) {
        self.every = EMPTY_STRING;
        self.change = EMPTY_STRING;
        self.until = EMPTY_STRING;
        self.dose = EMPTY_STRING;
        self.conditionDescription = EMPTY_STRING;
    }
    return self;
}

@end
