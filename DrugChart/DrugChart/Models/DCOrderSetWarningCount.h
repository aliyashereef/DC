//
//  DCOrderSetWarningCount.h
//  DrugChart
//
//  Created by aliya on 11/08/15.
//
//

#import <Foundation/Foundation.h>

@interface DCOrderSetWarningCount : NSObject

@property (nonatomic, strong) NSString *medicationId;
@property (nonatomic, strong) NSNumber *mildWarningCount;
@property (nonatomic, strong) NSNumber *severeWarningCount;

- (DCOrderSetWarningCount *)initWithDictionary:(NSDictionary*)warningDictionary;

@end
