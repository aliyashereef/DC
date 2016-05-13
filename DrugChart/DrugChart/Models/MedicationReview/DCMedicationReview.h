//
//  DCMedicationReview.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/22/16.
//
//

#import <Foundation/Foundation.h>
#import "DCReviewInterval.h"
#import "DCReviewDate.h"
#import "DCWarningPeriod.h"

@interface DCMedicationReview : NSObject

@property (nonatomic, strong) NSString *reviewType;
@property (nonatomic, strong) DCReviewInterval *reviewInterval;
@property (nonatomic, strong) DCReviewDate *reviewDate;
@property (nonatomic, strong) DCWarningPeriod *warningPeriod;

@end
