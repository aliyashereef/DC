//
//  DCPositionableGraphics.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 14/06/15.
//
//

#import "DCPositionableGraphics.h"

#define DIVIDER @"Divider"
#define NURSE_STATION @"NurseStation"

#define GRAPHICAL_ITEM_TYPE @"graphicalItemType"
#define HEAD_DIRECTION @"headDirection"
#define COORDINATES @"wardLocation"

#define TOP_DIRECTION @"Top"
#define BOTTOM_DIRECTION @"Bottom"
#define LEFT_DIRECTION @"Left"
#define RIGHT_DIRECTION @"Right"

//#define X_COORDINATE @"xCoordinate"
//#define Y_COORDINATE @"yCoordinate"
//#define WIDTH @"width"
//#define HEIGHT @"height"
//#define ITEM_TYPE @"itemType"

@implementation DCPositionableGraphics

- (id)initWithPositionDetailsDictionary:(NSDictionary *)positionDictionary {
    
    self = [super init];
    if (self) {
        @try {
            NSString *graphicalItemString = [positionDictionary objectForKey:GRAPHICAL_ITEM_TYPE];
            self.positionableGraphicsType = [self getPosititionableGraphicsTypeForString:graphicalItemString];
            self.headDirection = [positionDictionary objectForKey:HEAD_DIRECTION];
            NSString *coordinateString = [positionDictionary objectForKey:COORDINATES];
            CGPoint wardCoordinates = [DCUtility getCoordinatesFromString:coordinateString];
            if (self.positionableGraphicsType == kNurseStation) {
                self.viewFrame = [self getNurseStationFrameFromCoordinates:wardCoordinates];
            }
            else if (self.positionableGraphicsType == kDivider) {
                self.viewFrame = [self getDividerGraphicsFrameFromCoordinates:wardCoordinates];
            }
        }
        @catch (NSException *exception) {
             NSLog(@"Excpetion found in setting POSITION graphics model: %@",exception.description);
        }
    }
    return self;
}

//- (id)initWithPositionDetailsDictionary:(NSDictionary *)positionDictionary {
//    
//    self = [super init];
//    if (self) {
//        @try {
//            NSNumber *xCoordinate = [positionDictionary objectForKey:X_COORDINATE];
//            NSNumber *yCoordinate = [positionDictionary objectForKey:Y_COORDINATE];
//            NSNumber *width = [positionDictionary objectForKey:WIDTH];
//            NSNumber *height = [positionDictionary objectForKey:HEIGHT];
//            CGRect graphicsFrame = CGRectMake([xCoordinate floatValue], [yCoordinate floatValue], [width floatValue], [height floatValue]);
//            
//            //set the values.
//            self.viewFrame = graphicsFrame;
//            self.positionableGraphicsType = [self getPosititionableGraphicsTypeForString:[positionDictionary objectForKey:ITEM_TYPE]];
//        }
//        @catch (NSException *exception) {
//           
//        }
//    }
//    return self;
//}

- (PositionableGraphicsType)getPosititionableGraphicsTypeForString:(NSString *)typeString {
    
    if ([typeString isEqualToString:DIVIDER]) {
        return kDivider;
    }
    else if ([typeString isEqualToString:NURSE_STATION]){
        return kNurseStation;
    }
    return kUnknownTypes;
}

- (CGRect)getNurseStationFrameFromCoordinates:(CGPoint)coordinates {
    
    if ([self.headDirection isEqualToString:TOP_DIRECTION] ||
        [self.headDirection isEqualToString:BOTTOM_DIRECTION]) {
        return CGRectMake(coordinates.x, coordinates.y, 90.0, 180.0);
    }
    else {
        return CGRectMake(coordinates.x, coordinates.y, 180.0, 90.0);
    }
    return CGRectZero;
}

- (CGRect)getDividerGraphicsFrameFromCoordinates:(CGPoint)coordinates {
    
    if ([self.headDirection isEqualToString:TOP_DIRECTION] ||
        [self.headDirection isEqualToString:BOTTOM_DIRECTION]) {
        return CGRectMake(coordinates.x, coordinates.y, 6.0, 180.0);
    }
    else {
        return CGRectMake(coordinates.x, coordinates.y, 180.0, 6.0);
    }
    return CGRectZero;
}


@end
