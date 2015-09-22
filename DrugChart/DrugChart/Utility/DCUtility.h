//
//  DCUtility.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 02/03/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DCErrorPopOverViewController.h"
#import "DCMedicationSlot.h"

#define fsw frame.size.width
#define fsh frame.size.height
#define fox frame.origin.x
#define foy frame.origin.y

typedef enum : NSUInteger {
    kShortStyleDateOnly,
    kShortStyleDateAndTime
} DateFormatStyle;

@interface DCUtility : NSObject

//validate email
+ (BOOL)emailIsValid:(NSString *)email;

//sort contents of array
+ (NSArray *)sortArray:(NSArray *)arrayToSort
            basedOnKey:(NSString *)key ascending:(BOOL)ascending;

+ (UIImage *)getMedicationStatusImageForMedicationStatus:(NSString *)status;

+ (void)modifyViewComponentForErrorDisplay:(UIView *)view;

+ (DCErrorPopOverViewController *)getDisplayPopOverOnView:(UIView *)view;

+ (NSArray *)getBarButtonItemsItemsInPatientViewController:(id)sender andAction:(SEL)selector;

+ (NSArray *)getNavigationBarLogoImageItem;

+ (NSMutableAttributedString *)getDateOfBirthAndAgeAttributedString:(NSDate *)dateOfBirth;

+ (BOOL)isDetectedErrorField:(UIView *)view;

+ (UIPopoverController *)getDisplayPopOverControllerOnView:(UIView *)view;

+ (void)resetTextFieldAfterErrorCorrection:(UIView *)view withColor:(UIColor *)color;

+ (UIImage *)getBedTypeImageForBedType:(NSString *)bedType;

+ (void)shakeView:(UIView *)viewToShake completion:(void (^)(BOOL completed))completion;

+ (void)roundCornersForView:(UIView *)view roundTopCorners:(BOOL)top;

+ (void)displayAlertWithTitle:(NSString *)title message:(NSString *)message;

+ (NSString *)decodeBase64EncodedString:(NSString *)encodedString;

+ (NSString *)encodeStringToBase64Format:(NSString *)string;

+ (NSDictionary *)convertjsonStringToDictionary:(NSString *)jsonString;

+ (CGFloat)getHeightValueForText:(NSString *)text withFont:(UIFont *)font
                        maxWidth:(CGFloat)maxWidth;

+ (CGSize)getSizeFromString:(NSString *)sizeString;

+ (CGPoint)getCoordinatesFromString:(NSString *)coordinateString;

+ (id) convertJSONStringToArray: (NSString *)jsonString;

+ (void)removeChildViewController:(UIViewController *)childViewController;

+ (CGSize)getTextViewSizeWithText:(NSString *)text maxWidth:(CGFloat)width
                             font:(UIFont *)font;

+ (CGSize)getRequiredSizeForText:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)width;

+ (void)startWobbleAnimationForView:(UIView *)view;

+ (void)stopWobbleAnimationForView:(UIView *)view;

+ (void)configureDisplayElementsForTextView:(UITextView *)textView;

+ (NSArray *)categorizeContentArrayBasedOnSeverity:(NSArray *)initialArray;

+ (NSString *)convertTimeToHourMinuteFormat:(NSString *)time;

+ (CGSize)getMainWindowSize;

+ (NSAttributedString *)getDosagePlaceHolderForValidState:(BOOL)isValid;

+ (DCMedicationSlot *)getNearestMedicationSlotToBeAdministeredFromSlotsArray:(NSArray *)slotsArray;


@end
