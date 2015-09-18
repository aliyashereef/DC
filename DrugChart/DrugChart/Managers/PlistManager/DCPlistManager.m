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

+ (NSArray *)getMedicationRoutesList {
    
    //get medication routes
    NSArray *contentArray = [self getContentsFromPlist:ROUTES];
    return contentArray;
}

+ (NSArray *)getMedicineNamesList {
    
    //get medicine names
    NSArray *contentArray = [self getContentsFromPlist:MEDICINE_LIST];
    return contentArray;
}

// sample graphic details from the plist
+ (NSArray *)getBedGraphicalDetails {
    
    NSArray *graphicsArray = [self getContentsFromPlist:GRAPHICAL_COORDINATES];
    return graphicsArray;
}

+ (NSArray *)getPositionablegraphics {
    
    NSArray *positionableGraphicsArray = [self getContentsFromPlist:POSITIONABLE_GRAPHICS];
    return positionableGraphicsArray;
}

+ (NSArray *)getContentsFromPlist:(NSString *)name {
    
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    NSArray *contentArray = [NSArray arrayWithContentsOfFile:sourcePath];
    return contentArray;
}

+ (NSArray *)getAdministratingTimeList {
    
    //get administrating time list
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:ADMINSTRATING_TIME_LIST ofType:@"plist"];
    NSArray *contentArray = [NSArray arrayWithContentsOfFile:sourcePath];
    return contentArray;
}

+ (NSArray *)getOrderSetList {
    
    //get orderset list
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:ORDER_SET_LIST ofType:@"plist"];
    NSArray *contentArray = [NSArray arrayWithContentsOfFile:sourcePath];
    NSMutableArray *orderSetArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in contentArray) {
        DCOrderSet *orderSet = [[DCOrderSet alloc] initWithOrderSetDictionary:dict];
        [orderSetArray addObject:orderSet];
    }
    return orderSetArray;
}

@end
