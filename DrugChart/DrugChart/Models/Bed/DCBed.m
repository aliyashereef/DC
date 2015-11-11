//
//  DCBed.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 21/04/15.
//
//

#import "DCBed.h"
#import "DCBedsAndPatientsWebService.h"

#define BED_NUMBER_KEY @"bedDisplayNumber"
#define PATIENT_KEY @"occupyingPatient"
#define BED_STATUS @"bedStatus"
#define BED_TYPE @"bedType"
#define BED_COORDINATES @"coordinates"
#define BED_HEAD_DIRECTION @"headDirection"
#define BED_COLOR @"backgroundColour"
#define BED_ID @"bedId"
#define BED_FEATURES @"bedFeatures"
#define BED_IDENTIFIER @"identifier"

#define BED_DISPLAY_TEXT @"displayText"
#define PATIENT_REFERENCE_URL @"href"
#define LOCALHOST_PATH @"http://localhost:8080/api"

#define GRAPHICAL_PORTRAIT_TOP @"DCPortraitTopPatientView"
#define GRAPHICAL_PORTRAIT_BOTTOM @"DCPortraitBottomUpPatientView"
#define GRAPHICAL_LANDSCAPE_LEFT @"DCLandScapeLeftPatientView"
#define GRAPHICAL_LANDSCAPE_RIGHT @"DCLandScapeRightPatientView"

@implementation DCBed

- (DCBed *)initWithDictionary:(NSDictionary *)bedDictionary {
    self = [super init];
    if (self) {
        @try {
            self.bedNumber = [NSNumber numberWithInt:[[bedDictionary objectForKey:BED_NUMBER_KEY] intValue]];
            self.bedStatus = [bedDictionary objectForKey:BED_STATUS];
            self.bedType = [bedDictionary objectForKey:BED_TYPE];
            self.bedId = [NSNumber numberWithInt:[[bedDictionary objectForKey:BED_ID] intValue]];;
            self.headDirection = [bedDictionary objectForKey:BED_HEAD_DIRECTION];
            
            NSString *coordinateString = [bedDictionary objectForKey:BED_COORDINATES];
            CGPoint coordinates = [DCUtility coordinatesFromString:coordinateString];
            self.bedFrame = [self bedFrameFromCoordinates:coordinates];
            
            NSString *colorString = [bedDictionary objectForKey:BED_COLOR];
            self.bedColor = [self bedColorFromString:colorString];
            
            NSDictionary *patientDictionary = [bedDictionary objectForKey:PATIENT_KEY];
            if (patientDictionary) {
                self.patient = [[DCPatient alloc] init];
                self.patient.patientName = [patientDictionary valueForKey:BED_DISPLAY_TEXT];
                NSString *requestUrl = [patientDictionary valueForKey:PATIENT_REFERENCE_URL];
                self.patient.patientId = [self patientIdFromPatientReferenceUrl:requestUrl];

                self.patient.bedId = [NSString stringWithFormat:@"%@",self.bedId];
                self.patient.bedType = self.bedType;
                self.patient.bedNumber = [NSString stringWithFormat:@"%@",self.bedNumber];
            }
            else {
                self.patient = nil;
            }
        }
        @catch (NSException *exception) {
            DCDebugLog(@"An exception occured in setting the bed model. Description: %@", exception.description);
        }
    }
    return self;
}
//
// Depending on the bed headDirection the respective nib files are loaded.
- (NSString *)nibFileNameForHeadDirection {
    
    if ([self.headDirection isEqualToString:TOP_DIRECTION]) {
        return GRAPHICAL_PORTRAIT_TOP;
    }
    else if ([self.headDirection isEqualToString:BOTTOM_DIRECTION]) {
        return GRAPHICAL_PORTRAIT_BOTTOM;
    }
    else if ([self.headDirection isEqualToString:LEFT_DIRECTION]) {
        return GRAPHICAL_LANDSCAPE_LEFT;
    }
    else if ([self.headDirection isEqualToString:RIGHT_DIRECTION]) {
        return GRAPHICAL_LANDSCAPE_RIGHT;
    }
    return nil;
}

// the width and height(135, 180) are currently given with respect to the dimensions used in web.
// used since the view for display of the graphical view is currently a scroll view.
// If Scrollview can't be used, we need to change this.
- (CGRect)bedFrameFromCoordinates:(CGPoint)coordinates {
    
    if ([self.headDirection isEqualToString:TOP_DIRECTION] ||
        [self.headDirection isEqualToString:BOTTOM_DIRECTION]) {
        return CGRectMake(coordinates.x, coordinates.y, 135.0, 180.0);
    }
    else {
        return CGRectMake(coordinates.x, coordinates.y, 180.0, 135.0);
    }
    return CGRectZero;
}

// server returns the color value as a string, we extract the RGB values from this string.
// convert it to UIColor.
- (UIColor *)bedColorFromString:(NSString *)colorString {
    
    NSArray *colorsArray = [colorString componentsSeparatedByString:COMMA];
    if ([colorsArray count] == 3) {
        float red = [colorsArray.firstObject floatValue];
        float green = [[colorsArray objectAtIndex:2] floatValue];
        float blue = [colorsArray.lastObject floatValue];
        return [UIColor colorWithRed:red/255.0
                               green:green/255.0
                                blue:blue/255.0
                               alpha:1.0];
    }
    return [UIColor clearColor];
}

- (NSString *)patientIdFromPatientReferenceUrl:(NSString *)referenceUrl {
    
    NSArray*urlComponents = [referenceUrl componentsSeparatedByString: @"/"];
    NSUInteger count = [urlComponents count];
    NSString* lastBit = [urlComponents objectAtIndex:(count-1)];
    return  lastBit;
}

@end
