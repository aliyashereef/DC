//
//  DCPharmacistAction.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/31/16.
//
//

#import <Foundation/Foundation.h>
#import "DCIntervention.h"
#import "DCPODStatus.h"

@interface DCPharmacistAction : NSObject

@property (nonatomic) BOOL clinicalCheck;
@property (nonatomic, strong) DCIntervention *intervention;
@property (nonatomic, strong) DCPODStatus *podStatus;

@end
