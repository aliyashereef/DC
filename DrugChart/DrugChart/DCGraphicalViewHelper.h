//
//  DCGraphicalViewHelper.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 02/07/15.
//
//

#import <Foundation/Foundation.h>

@interface DCGraphicalViewHelper : NSObject

+ (UIImage *)getBedImageForBedType:(NSString *)bedType
             andBedOperationStatus:(NSString *)bedStatus
                     andHasPatient:(BOOL)hasPatient;

@end
