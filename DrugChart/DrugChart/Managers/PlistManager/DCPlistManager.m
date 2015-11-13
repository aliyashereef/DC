//
//  DCPlistManager.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/17/15.
//
//

#import "DCPlistManager.h"
#import "DCOrderSet.h"

// plist names
#define GRAPHICAL_COORDINATES @"GraphicalCoordinateList"
#define ROUTES @"Routes"
#define MEDICINE_LIST @"MedicineList"
#define POSITIONABLE_GRAPHICS @"PositionableGraphics"
#define ADMINSTRATING_TIME_LIST @"AdministratingTime"
#define ORDER_SET_LIST @"OrderSet"

@implementation DCPlistManager

+ (NSArray *)medicationRoutesList {
    
    //get medication routes
    NSArray *contentArray = [self contentsFromPlist:ROUTES];
    return contentArray;
}

+ (NSArray *)medicineNamesList {
    
    //get medicine names
    NSArray *contentArray = [self contentsFromPlist:MEDICINE_LIST];
    return contentArray;
}

// sample graphic details from the plist
+ (NSArray *)bedGraphicalDetails {
    
    NSArray *graphicsArray = [self contentsFromPlist:GRAPHICAL_COORDINATES];
    return graphicsArray;
}

+ (NSArray *)positionablegraphics {
    
    NSArray *positionableGraphicsArray = [self contentsFromPlist:POSITIONABLE_GRAPHICS];
    return positionableGraphicsArray;
}

+ (NSArray *)contentsFromPlist:(NSString *)name {
    
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    NSArray *contentArray = [NSArray arrayWithContentsOfFile:sourcePath];
    return contentArray;
}

+ (NSArray *)administratingTimeList {
    
    //get administrating time list
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:ADMINSTRATING_TIME_LIST ofType:@"plist"];
    NSArray *contentArray = [NSArray arrayWithContentsOfFile:sourcePath];
    return contentArray;
}

+ (NSArray *)orderSetList {
    
    //get orderset list
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:ORDER_SET_LIST ofType:@"plist"];
    NSArray *contentArray = [NSArray arrayWithContentsOfFile:sourcePath];
    NSMutableArray *orderSetArray = [[NSMutableArray alloc] init];
    for (NSDictionary *contentDictionary in contentArray) {
        DCOrderSet *orderSet = [[DCOrderSet alloc] initWithOrderSetDictionary:contentDictionary];
        [orderSetArray addObject:orderSet];
    }
    return orderSetArray;
}

@end
