//
//  DCInactiveDetails.h
//  DrugChart
//
//  Created by aliya on 26/04/16.
//
//

#import <Foundation/Foundation.h>

@interface DCInactiveDetails : NSObject

@property (nonatomic, strong) NSString *reason;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSString *outstandingDose;
@property (nonatomic, strong) NSString *outstandingSpecificDose;

@end
