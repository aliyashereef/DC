//
//  DCWard.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 21/04/15.
//
//

#import "DCWard.h"
#import "DCBed.h"
#import "DCPositionableGraphics.h"

#define PATIENT_KEY @"occupyingPatient"

//Basic information anout ward
#define WARDS_NAME_KEY @"displayName"
#define WARDS_NUMBER_KEY @"displayNumber"

//graphical display keys
#define WARDS_ID_KEY @"identifier"
#define WARDS_DIMENSIONS @"dimensions"
#define POSITIONABLE_GRAPHICS @"positionableGraphics"

//Url keys
#define BEDS @"beds"
#define PATIENTS_KEY @"patients"

//Count keys
#define AVAILABLE_BED_KEY @"availableBeds"
#define CLOSED_BED_KEY @"closedBeds"
#define CAPACITY @"capacity"
#define OCCUPIED_BED_KEY @"occupiedBeds"

#define LOCALHOST_PATH @"http://localhost:8080/api"

@implementation DCWard {
    NSArray *bedsArray;
}

- (DCWard *)initWithDicitonary:(NSDictionary *)wardsDictionary {
    
    self = [super init];
    if (self) {
        // Parsing the basic information about the ward.
        @try {
            self.wardName = [wardsDictionary objectForKey:WARDS_NAME_KEY];
            if ([self.wardName isEqualToString:EMPTY_STRING]) {
                self.wardName = @"Ward";
            }
            self.wardNumber = [NSNumber numberWithInt:[[wardsDictionary objectForKey:WARDS_NUMBER_KEY] intValue]];
            self.wardId = [wardsDictionary objectForKey:WARDS_ID_KEY];
            
            // Parsing the dimensional values for the ward graphical display.
            NSString *dimensionsString = (NSString *)[wardsDictionary objectForKey:WARDS_DIMENSIONS];
            self.wardDimensions = [DCUtility getSizeFromString:dimensionsString];
            NSArray *graphicsArray = (NSArray *)[wardsDictionary objectForKey:POSITIONABLE_GRAPHICS];
            self.positionableGraphicsArray = [self getPositionalGraphicsObjectsArray:graphicsArray];
            
            // Parsing the values for displaying count
            self.capacity = [wardsDictionary valueForKey:CAPACITY];;
            self.occupiedBedCount = [wardsDictionary valueForKey:OCCUPIED_BED_KEY];;
            self.closedBedCount = [wardsDictionary valueForKey:CLOSED_BED_KEY];;
            self.availableBedCount = [wardsDictionary valueForKey:AVAILABLE_BED_KEY];
            
            //Parsing the beds and patients URL
            self.bedsUrl = (NSString *)[wardsDictionary objectForKey:BEDS];
            self.patientsUrl = (NSString *)[wardsDictionary valueForKey:PATIENTS_KEY];
            self.bedsUrl = [self.bedsUrl stringByReplacingOccurrencesOfString:LOCALHOST_PATH
                                                                   withString:kDCBaseUrl];
            self.patientsUrl = [self.patientsUrl stringByReplacingOccurrencesOfString:LOCALHOST_PATH
                                                                   withString:kDCBaseUrl];
            
        }
        @catch (NSException *exception) {
            DCDebugLog(@"Issue in setting wards model: Error: %@", exception.description);
        }
    }
    return self;
}

- (NSArray *)getPositionalGraphicsObjectsArray:(NSArray *)graphicsArray {
    NSMutableArray *positionalGraphArray = nil;
    if ([graphicsArray count] > 0) {
        positionalGraphArray = [[NSMutableArray alloc] init];
        for (NSDictionary *graphicsDictionary in graphicsArray) {
            
            DCPositionableGraphics *positionableGraphics = [[DCPositionableGraphics alloc]
                                                            initWithPositionDetailsDictionary:graphicsDictionary];
            [positionalGraphArray addObject:positionableGraphics];
        }
    }
    return positionalGraphArray;
}


@end
