//
//  DCWarning.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/22/15.
//
//

#import <Foundation/Foundation.h>

@interface DCWarning : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *resourceType;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *severity;

- (DCWarning *)initWithDictionary:(NSDictionary*)warningDictionary;

@end
