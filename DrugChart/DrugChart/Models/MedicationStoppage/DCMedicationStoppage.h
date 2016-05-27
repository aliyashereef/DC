//
//  DCMedicationStoppage.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 24/05/16.
//
//

#import <Foundation/Foundation.h>
#import "DCUser.h"

@interface DCMedicationStoppage : NSObject

@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) DCUser *stoppedBy;

@end
