//
//  DCMedicationSchedule.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 15/07/15.
//
//

#import <Foundation/Foundation.h>

@interface DCMedicationSchedule : NSObject

@property (nonatomic, strong) NSString *scheduleId;
@property (nonatomic, strong) NSMutableArray *scheduleTimes;

@end
