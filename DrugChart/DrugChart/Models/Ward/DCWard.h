//
//  DCWard.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 21/04/15.
//
//

#import <Foundation/Foundation.h>

@interface DCWard : NSObject

@property (nonatomic, strong) NSString *wardName;
@property (nonatomic, strong) NSNumber *wardNumber;
@property (nonatomic, strong) NSString *wardId;

@property (nonatomic, strong) NSNumber *capacity;
@property (nonatomic, strong) NSNumber *occupiedBedCount;
@property (nonatomic, strong) NSNumber *availableBedCount;
@property (nonatomic, strong) NSNumber *closedBedCount;

@property (nonatomic, assign) CGSize wardDimensions;
@property (nonatomic, strong) NSArray *positionableGraphicsArray;

@property (nonatomic, strong) NSString *bedsUrl;
@property (nonatomic, strong) NSString *patientsUrl;

- (DCWard *)initWithDicitonary:(NSDictionary *)wardsDictionary;

@end
