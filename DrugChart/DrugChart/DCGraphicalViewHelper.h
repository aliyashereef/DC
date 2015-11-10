//
//  DCGraphicalViewHelper.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 02/07/15.
//
//

#import <Foundation/Foundation.h>

@interface DCGraphicalViewHelper : NSObject

+ (UIImage *)bedImageForBedType:(NSString *)bedType
             bedOperationStatus:(NSString *)bedStatus
                containsPatient:(BOOL)hasPatient;

@end
