//
//  DCBed.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 21/04/15.
//
//
#import <Foundation/Foundation.h>
#import "DCPatient.h"

@interface DCBed : NSObject

@property (nonatomic, strong) NSNumber *bedNumber;
@property (nonatomic, strong) DCPatient *patient;
@property (nonatomic, strong) NSString *bedStatus;
@property (nonatomic, strong) NSNumber *bedId;

// for graphical display
@property (nonatomic, strong) UIColor *bedColor;
@property (nonatomic, strong) NSString *bedType;
@property (nonatomic, assign) CGRect bedFrame;
@property (nonatomic, strong) NSString *headDirection;

- (DCBed *)initWithDictionary:(NSDictionary *)bedDictionary;
- (NSString *)getNibFileForHeadDirection;

@end
