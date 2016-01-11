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

+ (UIImage *)medicationStatusImageForMedicationStatus:(NSString *)status;

+ (void)modifyViewComponentForErrorDisplay:(UIView *)view;

+ (NSMutableAttributedString *)dateOfBirthAndAgeAttributedString:(NSDate *)dateOfBirth;

+ (BOOL)isDetectedErrorField:(UIView *)view;

+ (UIPopoverController *)displayPopOverControllerOnView:(UIView *)view;

+ (void)resetTextFieldAfterErrorCorrection:(UIView *)view withColor:(UIColor *)color;

+ (UIImage *)bedTypeImageForBedType:(NSString *)bedType;

+ (void)shakeView:(UIView *)viewToShake completion:(void (^)(BOOL completed))completion;

+ (void)roundCornersForView:(UIView *)view roundTopCorners:(BOOL)top;

+ (void)displayAlertWithTitle:(NSString *)title message:(NSString *)message;

+ (NSString *)decodeBase64EncodedString:(NSString *)encodedString;

+ (NSString *)encodeStringToBase64Format:(NSString *)string;

+ (NSDictionary *)convertJsonStringToDictionary:(NSString *)jsonString;

+ (CGFloat)heightValueForText:(NSString *)text withFont:(UIFont *)font
                        maxWidth:(CGFloat)maxWidth;

+ (CGSize)sizeFromString:(NSString *)sizeString;

+ (CGPoint)coordinatesFromString:(NSString *)coordinateString;

+ (id) convertJSONStringToArray: (NSString *)jsonString;

+ (void)removeChildViewController:(UIViewController *)childViewController;

+ (CGSize)textViewSizeWithText:(NSString *)text maxWidth:(CGFloat)width
                             font:(UIFont *)font;

+ (CGSize)requiredSizeForText:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)width;

+ (void)startWobbleAnimationForView:(UIView *)view;

+ (void)stopWobbleAnimationForView:(UIView *)view;

+ (void)configureDisplayElementsForTextView:(UITextView *)textView;

+ (NSArray *)categorizeContentArrayBasedOnSeverity:(NSArray *)initialArray;

+ (NSString *)convertTimeToHourMinuteFormat:(NSString *)time;

+ (CGSize)mainWindowSize;

+ (NSAttributedString *)dosagePlaceHolderForValidState:(BOOL)isValid;

+ (NSMutableAttributedString *)monthYearAttributedStringForDisplayString:(NSString *)displayString
                                              withInitialMonthLength:(NSInteger)length;

+ (NSString *)mostOccurredStringFromArray:(NSArray *)contentArray;

+ (NSString *)removeSubstring:(NSString *)substring FromOriginalString:(NSMutableString *)originalString;

+ (NSString *)capitaliseFirstCharacterOfString:(NSString *)originalString;

+ (NSString *)removeLastCharacterFromString:(NSString *)originalString;

+ (void)backButtonItemForViewController:(UIViewController *)viewController
                 inNavigationController:(UINavigationController *)navigationController withTitle:(NSString *)title;

@end
