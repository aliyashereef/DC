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

@implementation DCPositionableGraphics

- (id)initWithPositionDetailsDictionary:(NSDictionary *)positionDictionary {
    
    self = [super init];
    if (self) {
        @try {
            NSString *graphicalItemString = [positionDictionary objectForKey:GRAPHICAL_ITEM_TYPE];
            self.positionableGraphicsType = [self posititionableGraphicsTypeForString:graphicalItemString];
            self.headDirection = [positionDictionary objectForKey:HEAD_DIRECTION];
            NSString *coordinateString = [positionDictionary objectForKey:COORDINATES];
            CGPoint wardCoordinates = [DCUtility coordinatesFromString:coordinateString];
            if (self.positionableGraphicsType == kNurseStation) {
                self.viewFrame = [self nurseStationFrameFromCoordinates:wardCoordinates];
            }
            else if (self.positionableGraphicsType == kDivider) {
                self.viewFrame = [self dividerGraphicsFrameFromCoordinates:wardCoordinates];
            }
        }
        @catch (NSException *exception) {
             DDLogError(@"Excpetion found in setting POSITION graphics model: %@",exception.description);
        }
    }
    return self;
}

- (PositionableGraphicsType)posititionableGraphicsTypeForString:(NSString *)typeString {
    
    if ([typeString isEqualToString:DIVIDER]) {
        return kDivider;
    }
    else if ([typeString isEqualToString:NURSE_STATION]){
        return kNurseStation;
    }
    return kUnknownTypes;
}

- (CGRect)nurseStationFrameFromCoordinates:(CGPoint)coordinates {
    
    if ([self.headDirection isEqualToString:TOP_DIRECTION] ||
        [self.headDirection isEqualToString:BOTTOM_DIRECTION]) {
        return CGRectMake(coordinates.x, coordinates.y, 90.0, 180.0);
    }
    else {
        return CGRectMake(coordinates.x, coordinates.y, 180.0, 90.0);
    }
    return CGRectZero;
}

- (CGRect)dividerGraphicsFrameFromCoordinates:(CGPoint)coordinates {
    
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
