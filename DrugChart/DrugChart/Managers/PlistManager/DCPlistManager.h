//
//  DCPlistManager.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/17/15.
//
//

#import <Foundation/Foundation.h>

@interface DCPlistManager : NSObject

+ (NSArray *)getMedicationRoutesList;

+ (NSArray *)getMedicineNamesList;

+ (NSArray *)getBedGraphicalDetails;

+ (NSArray *)getPositionablegraphics;

+ (NSArray *)getAdministratingTimeList;

+ (NSArray *)getOrderSetList;

@end
