//
//  DCPharmacistAction.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/31/16.
//
//

#import "DCPharmacistAction.h"

@implementation DCPharmacistAction

- (id)init {
    
    if (self == [super init]) {
        self.clinicalCheck = false;
        self.intervention = [[DCIntervention alloc] init];
        self.podStatus = [[DCPODStatus alloc] init];
    }
    return self;
}

@end
