//
//  DCPositionableGraphics.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 14/06/15.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kDivider,
    kNurseStation,
    kUnknownTypes
} PositionableGraphicsType;

@interface DCPositionableGraphics : NSObject

@property (nonatomic, assign) PositionableGraphicsType positionableGraphicsType;
@property (nonatomic, strong) NSString *headDirection;
@property (nonatomic, assign) CGRect viewFrame;

- (id)initWithPositionDetailsDictionary:(NSDictionary *)positionDictionary;

@end
