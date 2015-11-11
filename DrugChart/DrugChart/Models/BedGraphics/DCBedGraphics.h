//
//  DCBedGraphics.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 11/06/15.
//
//

#import <Foundation/Foundation.h>

#define TOP_DIRECTION @"Top"
#define BOTTOM_DIRECTION @"Bottom"
#define LEFT_DIRECTION @"Left"
#define RIGHT_DIRECTION @"Right"

@interface DCBedGraphics : NSObject

@property (nonatomic, strong) NSString *headDirection;
@property (nonatomic, assign) CGRect bedFrame;
@property (nonatomic, strong) UIColor *bedColor;

- (id)initWithBedGraphicsDictionary:(NSDictionary *)graphicsDictionary;
- (NSString *)nibFileForHeadDirection;

@end
