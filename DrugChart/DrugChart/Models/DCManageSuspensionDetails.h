//
//  DCManageSuspensionDetails.h
//  DrugChart
//
//  Created by Felix Joseph on 11/05/16.
//
//

#import <Foundation/Foundation.h>

@interface DCManageSuspensionDetails : NSObject

@property (nonatomic, strong) NSString *reason;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSString *manageSuspensionFromType;
@property (nonatomic, strong) NSString *fromDate;
@property (nonatomic, strong) NSString *manageSuspensionUntilType;
@property (nonatomic, strong) NSString *specifiedUntilDate;
@property (nonatomic, strong) NSString *specifiedDose;

@end
