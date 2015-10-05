//
//  DCUtility.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 02/03/15.
//
//

#import "DCUtility.h"
#import "DCErrorPopOverBackgroundView.h"
#import "DCWarning.h"

#define MEDICINE_REFUSED_IMAGE @"MedicineRefused"
#define MEDICINE_OMITTED_IMAGE @"MedicineOmitted"
#define MEDICINE_GIVEN_IMAGE @"MedicineGivenImage"
#define MEDICINE_TOBE_GIVEN_IMAGE @"MedicineToBeGiven"
#define MEDICINE_SELF_ADMINISTERED_IMAGE @"MedicineSelfAdministered"

#define PRESCRIBER_ADMINISTERED_IMAGE @""


@implementation DCUtility

+ (BOOL)emailIsValid:(NSString *)email {
    //email validation
    BOOL valid = NO;
    NSString *filterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = valid ? filterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (NSArray *)sortArray:(NSArray *)arrayToSort
            basedOnKey:(NSString *)key ascending:(BOOL)ascending {
    //sort contents of array
    NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
    NSArray *sortedArray = [arrayToSort sortedArrayUsingDescriptors: @[sortOrder]];
    return sortedArray;
}

+ (UIImage *)getMedicationStatusImageForMedicationStatus:(NSString *)status {
    UIImage *image;
    if ([status isEqualToString:OMITTED]) {
        image = [UIImage imageNamed:MEDICINE_OMITTED_IMAGE];
    } else if ([status isEqualToString:IS_GIVEN]) {
        image = [UIImage imageNamed:MEDICINE_GIVEN_IMAGE];
    } else if ([status isEqualToString:REFUSED]) {
        image = [UIImage imageNamed:MEDICINE_REFUSED_IMAGE];
    } else if ([status isEqualToString:YET_TO_GIVE]) {
        image = [UIImage imageNamed:MEDICINE_TOBE_GIVEN_IMAGE];
    } else {
        image = [UIImage imageNamed:MEDICINE_SELF_ADMINISTERED_IMAGE];
    }
    return image;
}

+ (void)modifyViewComponentForErrorDisplay:(UIView *)view {
    [view layer].borderWidth = 0.6;
    [view layer].borderColor = [UIColor redColor].CGColor;
    view.clipsToBounds = YES;
}

+ (DCErrorPopOverViewController *)getDisplayPopOverOnView:(UIView *)view {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD
                                                             bundle: nil];
    DCErrorPopOverViewController *errorViewController = [mainStoryboard instantiateViewControllerWithIdentifier:ERROR_CONTENT_VIEW_CONTROLLER_STORYBOARD_ID];
    UIPopoverController *popOverController = [[UIPopoverController alloc] initWithContentViewController:errorViewController];
    popOverController.backgroundColor = [UIColor redColor];
    popOverController.popoverBackgroundViewClass = [DCErrorPopOverBackgroundView class];
    popOverController.popoverContentSize = CGSizeMake(200.0, 33.0);
    [popOverController presentPopoverFromRect:[view bounds]
                                       inView:view
                     permittedArrowDirections:UIPopoverArrowDirectionDown
                                     animated:YES];
    return errorViewController;
}

+ (UIPopoverController *)getDisplayPopOverControllerOnView:(UIView *)view {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD
                                                             bundle: nil];
    DCErrorPopOverViewController *errorViewController = [mainStoryboard instantiateViewControllerWithIdentifier:ERROR_CONTENT_VIEW_CONTROLLER_STORYBOARD_ID];
    UIPopoverController *popOverController = [[UIPopoverController alloc] initWithContentViewController:errorViewController];
    popOverController.backgroundColor = [UIColor redColor];
    popOverController.popoverBackgroundViewClass = [DCErrorPopOverBackgroundView class];
    popOverController.popoverContentSize = CGSizeMake(200.0, 33.0);
    [popOverController presentPopoverFromRect:[view bounds]
                                       inView:view
                     permittedArrowDirections:UIPopoverArrowDirectionDown
                                     animated:YES];
    return popOverController;
}

//TODO: delete is no longer needed.
+ (NSArray *)getBarButtonItemsItemsInPatientViewController:(id)sender
                                         andAction:(SEL)selector {

    UIImage *settingsImage = [UIImage imageNamed:SETTINGS_IMAGE];
    UIBarButtonItem *settingsButton= [[UIBarButtonItem alloc] initWithImage:settingsImage style:UIBarButtonItemStylePlain target:sender action:selector];
    return @[settingsButton];
}

+ (NSArray *)getNavigationBarLogoImageItem {
    
    UIImage *logoImage = [UIImage imageNamed:TOP_LOGO];
    CGRect imageFrame = CGRectMake(0, 0, logoImage.size.width, logoImage.size.height);
    UIButton *logoButton = [[UIButton alloc] initWithFrame:imageFrame];
    [logoButton setBackgroundImage:logoImage forState:UIControlStateNormal];
    [logoButton addTarget:self action:nil
         forControlEvents:UIControlEventTouchUpInside];
    [logoButton setUserInteractionEnabled:NO];
    UIBarButtonItem *logoItem = [[UIBarButtonItem alloc] initWithCustomView:logoButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -3;
    return @[negativeSpacer, logoItem];
}

+ (NSMutableAttributedString *)getDateOfBirthAndAgeAttributedString:(NSDate *)dateOfBirth {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:BIRTH_DATE_FORMAT];
    NSString *dobDateString = [dateFormatter stringFromDate:dateOfBirth];
//    NSInteger age = [DCDateUtility calculateAgeFromDate:dateOfBirth];
    NSMutableAttributedString *attributedDOBString = [[NSMutableAttributedString alloc]
                                                      initWithString:[NSString stringWithFormat:@"%@ ", dobDateString]
                                                      attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : [UIColor getColorForHexString:@"#394348"]}];
//    NSAttributedString *attributedAgeString = [[NSAttributedString alloc]
//                                               initWithString:[NSString stringWithFormat:@"(%ld years)", (long)age]
//                                               attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : [UIColor getColorForHexString:@"#7d929e"]}];
//    [attributedDOBString appendAttributedString:attributedAgeString];
    return attributedDOBString;
}

+ (BOOL)isDetectedErrorField:(UIView *)view {
    
    BOOL isError = NO;
    if ([view layer].borderColor == [UIColor redColor].CGColor) {
        DCDebugLog(@"error field detected");
        isError = YES;
    }
    return isError;
}

+ (void)resetTextFieldAfterErrorCorrection:(UIView *)view withColor:(UIColor *)color {
    
    [view layer].borderColor = color.CGColor;
}

+ (UIImage *)getBedTypeImageForBedType:(NSString *)bedType {
    
    if ([bedType isEqualToString:BED]) {
        return [UIImage imageNamed:@"Bed"];
    } else if ([bedType isEqualToString:CHAIR]) {
        return [UIImage imageNamed:@"Chair"];
    } else if ([bedType isEqualToString:TROLLEY]) {
        return [UIImage imageNamed:@"Trolley"];
    } else if ([bedType isEqualToString:CUBICLE]) {
        return [UIImage imageNamed:@"Cubicle"];
    }
    return [UIImage imageNamed:@"Bed"];
}

+ (void)shakeView:(UIView *)viewToShake completion:(void (^)(BOOL completed))completion {
    
    CGFloat t = 2.0;
    CGAffineTransform translateRight  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0.0);
    CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0.0);
    
    viewToShake.transform = translateLeft;
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:5.0];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                completion(YES);
            }];
        }
    }];
}

+ (void)startWobbleAnimationForView:(UIView *)view {
    
    view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-1.5));
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                     animations:^ {
                         view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(1.5));
                     }
                     completion:NULL
     ];
}

+ (void)stopWobbleAnimationForView:(UIView *)view {
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear)
                     animations:^ {
                         view.transform = CGAffineTransformIdentity;
                     }
                     completion:NULL
     ];
}

+ (void)roundCornersForView:(UIView *)view roundTopCorners:(BOOL)top {
    
    //curve corners of a view. This method curves top/bottom corners
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIRectCorner corners;
    if (top) {
        corners = UIRectCornerTopLeft | UIRectCornerTopRight;
    } else {
        corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    }
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: view.bounds byRoundingCorners: corners cornerRadii: (CGSize){5.0, 5.0}].CGPath;
    view.layer.mask = maskLayer;
}

+ (void)displayAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:OK_BUTTON_TITLE otherButtonTitles: nil];
    [alertView show];
}

+ (NSString *)decodeBase64EncodedString:(NSString *)encodedString {
    
    //convert encoded string to padded base64 type
    int padLength = (4 - (encodedString.length % 4)) % 4;
    NSString *paddedBase64 = [NSString stringWithFormat:@"%s%.*s", [encodedString UTF8String], padLength, "=="];
    NSData *decoded = [[NSData alloc] initWithBase64EncodedString:paddedBase64 options:0];
    NSString *decodedValue = [[NSString alloc] initWithData:decoded encoding:NSUTF8StringEncoding];
    return decodedValue;
}

+ (NSString *)encodeStringToBase64Format:(NSString *)string {
    
    NSData *encodeData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [encodeData base64EncodedStringWithOptions:0];
    return base64String;
}

+ (id )convertjsonStringToDictionary:(NSString *)jsonString {
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return json;
}

+ (id) convertJSONStringToArray: (NSString *)jsonString {
    NSMutableArray *roleArray = [[NSMutableArray alloc] init];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *roles = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingMutableContainers
                                                              error:nil];
    [roleArray addObjectsFromArray:roles];
    return roleArray;
}

+ (CGFloat)getHeightValueForText:(NSString *)text withFont:(UIFont *)font
                        maxWidth:(CGFloat)maxWidth {
    
    CGSize constrain = CGSizeMake(maxWidth, FLT_MAX);
    CGRect textRect;
    textRect = [text   boundingRectWithSize:constrain
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:font}
                                            context:nil];
    return textRect.size.height;
}

+ (CGSize)getSizeFromString:(NSString *)sizeString {
    
    NSArray *sizeArray = [sizeString componentsSeparatedByString:@","];
    if ([sizeArray count] == 2) {
        float width = [sizeArray.firstObject floatValue];
        float height = [sizeArray.lastObject floatValue];
        return CGSizeMake(width, height);
    }
    return CGSizeMake(0.0, 0.0);
}

+ (CGPoint)getCoordinatesFromString:(NSString *)coordinateString {
    
    NSArray *coordinatesArray = [coordinateString componentsSeparatedByString:@","];
    if ([coordinatesArray count] == 2) {
        float xAxis = [coordinatesArray.firstObject floatValue];
        float yAxis = [coordinatesArray.lastObject floatValue];
        return CGPointMake(xAxis, yAxis);
    }
    return CGPointMake(0.0, 0.0);
}

+ (void)removeChildViewController:(UIViewController *)childViewController {
    
    //remove child view controller from parent
    [childViewController willMoveToParentViewController:nil];  // 1
    [childViewController.view removeFromSuperview];            // 2
    [childViewController removeFromParentViewController];
}

+ (CGSize)getTextViewSizeWithText:(NSString *)text maxWidth:(CGFloat)width
                             font:(UIFont *)font {
    
    CGSize constrain = CGSizeMake(width, FLT_MAX);
    CGRect textRect = [text  boundingRectWithSize:constrain
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:font}
                                                        context:nil];
    return textRect.size;
}

+ (CGSize)getRequiredSizeForText:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)width {
    if(text.length == 0)    return CGSizeZero;
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];
    return textRect.size;
}

+ (void)configureDisplayElementsForTextView:(UITextView *)textView {
    
    //configure display elements
    textView.layer.borderWidth = 0.6;
    textView.layer.borderColor = [UIColor colorWithRed:177.0f/255.0f green:177.0f/255.0f blue:177.0f/255.0f alpha:0.6].CGColor;
    textView.layer.cornerRadius = 2.0f;
}

+ (NSArray *)categorizeContentArrayBasedOnSeverity:(NSArray *)initialArray {
    
    //categorize array based on severity value
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSMutableArray *mildArray = [[NSMutableArray alloc] init];
    NSMutableArray *severeArray = [[NSMutableArray alloc] init];
    for (DCWarning *warning in initialArray) {
        if ([warning.severity isEqualToString:MILD_KEY]) {
            [mildArray addObject:warning];
        } else if ([warning.severity isEqualToString:SEVERE_KEY] ) {
            [severeArray addObject:warning];
        }
    }
    [resultArray addObject:@{@"Severe" : severeArray}];
    [resultArray addObject:@{@"Mild" : mildArray}];
    return resultArray;
}

+ (NSString *)convertTimeToHourMinuteFormat:(NSString *)time {
    
    //convert time to hour minute format
    NSMutableString *formattedTime = [[NSMutableString alloc] init];
    @try {
        NSArray *initialArray = [time componentsSeparatedByString:COLON];
        if (initialArray.count > 0) {
            [formattedTime appendFormat:@"%@:%@", [initialArray objectAtIndex:0], [[[initialArray objectAtIndex:1] componentsSeparatedByString:COLON] objectAtIndex:0]];
        }
    }
    @catch (NSException *exception) {
        DCDebugLog(@"Error description: %@", exception.description);
    }
    return formattedTime;
}

+ (CGSize)getMainWindowSize {
    
    //get main window size
    UIWindow *mainWindow = [UIApplication sharedApplication].windows[0];
    return mainWindow.bounds.size;
}

+ (NSAttributedString *)getDosagePlaceHolderForValidState:(BOOL)isValid {
    
    //get dosage placeholder sttributed string
    UIColor *color = isValid ? [UIColor redColor] : [UIColor getColorForHexString:@"#8f8f95"];
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NEW_DOSAGE", @"new dosage placeholder") attributes:@{NSForegroundColorAttributeName: color}];
    return placeholder;
}

+ (DCMedicationSlot *)getNearestMedicationSlotToBeAdministeredFromSlotsArray:(NSArray *)slotsArray {
    
    NSDate *currentSystemDate = [DCDateUtility getDateInCurrentTimeZone:[NSDate date]];
    NSString *currentDateString = [DCDateUtility convertDate:currentSystemDate FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    //get medication slots array of current week
    for (DCMedicationSlot *slot in slotsArray) {
        NSString *timeString = [DCDateUtility convertDate:slot.time FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
        if ([timeString isEqualToString:currentDateString]) {
            [filteredArray addObject:slot];
        }
        
        NSDate *nearestDate;
        NSDate *laterDate;
        for(DCMedicationSlot *slot in filteredArray) {
            laterDate = [currentSystemDate laterDate:slot.time];
            if(![laterDate isEqualToDate:currentSystemDate]){
                nearestDate = [laterDate earlierDate:nearestDate];
                NSLog(@"nearestDate is %@", nearestDate);
            }
        }
        NSLog(@"laterDate is %@", laterDate);
        if ((nearestDate && [nearestDate compare:slot.time] == NSOrderedSame) ||
            [slot.status isEqualToString:YET_TO_GIVE]) {
            return slot;
        }
    }
    return nil;
}

@end
