//
//  DCPODStatus.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/31/16.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ePatientOwnDrugs,
    ePatientOwnDrugsHome,
    ePatientOwnDrugsAndPatientOwnDrugsHome
} PODStatusType;


@interface DCPODStatus : NSObject

@property (nonatomic) PODStatusType podStatusType;

@end
