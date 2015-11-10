//
//  DCBedGraphics.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 11/06/15.
//
//

#import "DCBedGraphics.h"

#define X_COORDINATE @"xCoordinate"
#define Y_COORDINATE @"yCoordinate"
#define WIDTH @"width"
#define HEIGHT @"height"
#define HEAD_DIRECTION @"headDirection"
#define BED_COLOR @"bgColor"

@implementation DCBedGraphics

- (id)initWithBedGraphicsDictionary:(NSDictionary *)graphicsDictionary {
    
    self = [super init];
    if (self) {
        @try {
            NSNumber *xCoordinate = [graphicsDictionary objectForKey:X_COORDINATE];
            NSNumber *yCoordinate = [graphicsDictionary objectForKey:Y_COORDINATE];
            NSNumber *width = [graphicsDictionary objectForKey:WIDTH];
            NSNumber *height = [graphicsDictionary objectForKey:HEIGHT];
            CGRect graphicsFrame = CGRectMake([xCoordinate floatValue], [yCoordinate floatValue], [width floatValue], [height floatValue]);            
            NSString *colorHexString = [graphicsDictionary objectForKey:BED_COLOR];
            
            //set the values.
            self.bedFrame = graphicsFrame;
            self.headDirection = [graphicsDictionary objectForKey:HEAD_DIRECTION];
            self.bedColor = [UIColor getColorForHexString:colorHexString];
        }
        @catch (NSException *exception) {
            NSLog(@"Excpetion found in setting bed graphics model: %@",exception.description);
        }
        
    }
    return self;
}

// Depending on the bed headDirection the respective nib files are loaded.
- (NSString *)nibFileNameForHeadDirection {
    
    if ([self.headDirection isEqualToString:TOP_DIRECTION]) {
        return @"DCPortraitTopPatientView";
    }
    else if ([self.headDirection isEqualToString:BOTTOM_DIRECTION]) {
        return @"DCPortraitBottomUpPatientView";
    }
    else if ([self.headDirection isEqualToString:LEFT_DIRECTION]) {
        return @"DCLandScapeLeftPatientView";
    }
    else if ([self.headDirection isEqualToString:RIGHT_DIRECTION]) {
        return @"DCLandScapeRightPatientView";
    }
    return nil;
}

@end
