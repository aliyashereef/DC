//
//  DCPatientAllergy.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/5/15.
//
//

#import <Foundation/Foundation.h>

@interface DCPatientAllergy : NSObject

@property (nonatomic, strong) NSString *allergyName;
@property (nonatomic, strong) NSString *warningType;
@property (nonatomic, strong) NSString *reaction;

- (DCPatientAllergy *)initWithAllergyDictionary:(NSDictionary *)allergyDictionary;

@end
