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

+ (void)modifyViewComponentForErrorDisplay:(UIView *)view {
    [view layer].borderWidth = 0.6;
    [view layer].borderColor = [UIColor redColor].CGColor;
    view.clipsToBounds = YES;
}

+ (UIPopoverController *)displayPopOverControllerOnView:(UIView *)view {
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

+ (NSMutableAttributedString *)dateOfBirthAndAgeAttributedString:(NSDate *)dateOfBirth {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:BIRTH_DATE_FORMAT];
    NSString *dobDateString = [dateFormatter stringFromDate:dateOfBirth];
    NSMutableAttributedString *attributedDOBString = [[NSMutableAttributedString alloc]
                                                      initWithString:[NSString stringWithFormat:@"%@ ", dobDateString]
                                                      attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : [UIColor colorForHexString:@"#394348"]}];
    return attributedDOBString;
}

+ (BOOL)isDetectedErrorField:(UIView *)view {
    
    BOOL isError = NO;
    if ([view layer].borderColor == [UIColor redColor].CGColor) {
        DDLogError(@"error field detected");
        isError = YES;
    }
    return isError;
}

+ (void)resetTextFieldAfterErrorCorrection:(UIView *)view withColor:(UIColor *)color {
    
    [view layer].borderColor = color.CGColor;
}

+ (UIImage *)bedTypeImageForBedType:(NSString *)bedType {
    
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

+ (void)roundCornersForView:(UIView *)view roundTopCorners:(BOOL)top {
    
    //curve corners of a view. This method curves top/bottom corners
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIRectCorner corners;
    if (top) {
        corners = UIRectCornerTopLeft | UIRectCornerTopRight;
    } else {
        corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    }
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: view.bounds byRoundingCorners: corners cornerRadii: (CGSize){10.0, 10.0}].CGPath;
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

+ (id )convertJsonStringToDictionary:(NSString *)jsonString {
    
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

+ (CGFloat)heightValueForText:(NSString *)text withFont:(UIFont *)font
                        maxWidth:(CGFloat)maxWidth {
    
    CGSize constrain = CGSizeMake(maxWidth, FLT_MAX);
    CGRect textRect;
    textRect = [text   boundingRectWithSize:constrain
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:font}
                                            context:nil];
    return textRect.size.height;
}

+ (CGSize)sizeFromString:(NSString *)sizeString {
    
    NSArray *sizeArray = [sizeString componentsSeparatedByString:@","];
    if ([sizeArray count] == 2) {
        float width = [sizeArray.firstObject floatValue];
        float height = [sizeArray.lastObject floatValue];
        return CGSizeMake(width, height);
    }
    return CGSizeMake(0.0, 0.0);
}

+ (CGPoint)coordinatesFromString:(NSString *)coordinateString {
    
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

+ (CGSize)textViewSizeWithText:(NSString *)text maxWidth:(CGFloat)width
                             font:(UIFont *)font {
    
    CGSize constrain = CGSizeMake(width, FLT_MAX);
    CGRect textRect = [text  boundingRectWithSize:constrain
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:font}
                                                        context:nil];
    return textRect.size;
}

+ (CGSize)requiredSizeForText:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)width {
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
        DDLogError(@"Error description: %@", exception.description);
    }
    return formattedTime;
}

+ (CGSize)mainWindowSize {
    
    //get main window size
    UIWindow *mainWindow = [UIApplication sharedApplication].windows[0];
    return mainWindow.bounds.size;
}

+ (NSAttributedString *)dosagePlaceHolderForValidState:(BOOL)isValid {
    
    //get dosage placeholder sttributed string
    UIColor *color = isValid ? [UIColor redColor] : [UIColor colorForHexString:@"#8f8f95"];
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NEW_DOSAGE", @"new dosage placeholder") attributes:@{NSForegroundColorAttributeName: color}];
    return placeholder;
}

+ (NSMutableAttributedString *)monthYearAttributedStringForDisplayString:(NSString *)displayString
                                              withInitialMonthLength:(NSInteger)length {
    
    NSDictionary *monthAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont systemFontOfSize:22.0f weight:UIFontWeightMedium], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil];
    NSDictionary *yearAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:22.0f weight:UIFontWeightLight], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:displayString];
    [attributedString setAttributes:monthAttributes range:NSMakeRange(0, displayString.length)];
    [attributedString setAttributes:yearAttributes range:NSMakeRange(displayString.length - 4, 4)];
    if (length > 0) {
        [attributedString setAttributes:yearAttributes range:NSMakeRange(length + 2, 4)];
    }
    return attributedString;
}

+ (NSString *)mostOccurredStringFromArray:(NSArray *)contentArray {
    
    //get most occurred string
    NSUInteger count = 0;
    NSString *mostCommonString;
    for(NSString *data in contentArray) {
        NSUInteger countStr = [[contentArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self MATCHES[CD] %@", data]]count];
        if(countStr > count) {
            count = countStr;
            mostCommonString = data;
        }
    }
    return mostCommonString;
}

+ (NSString *)removeSubstring:(NSString *)substring FromOriginalString:(NSMutableString *)originalString {
    
    NSRange range = [originalString rangeOfString:substring];
    /** Delete the substring from the original string **/
    [originalString deleteCharactersInRange:range];
    return originalString;
}

+ (NSString *)capitaliseFirstCharacterOfString:(NSString *)originalString {
    
    //capitalise first character
    originalString = [NSString stringWithFormat:@"%@%@",[[originalString substringToIndex:2] uppercaseString],[originalString substringFromIndex:2] ];
    return originalString;
}

+ (NSString *)removeLastCharacterFromString:(NSString *)originalString {
    
    //remove last character from original string
    if ([originalString length] > 0) {
        originalString = [originalString substringToIndex:[originalString length] - 1];
    }
    return originalString;
}

+ (void)backButtonItemForViewController:(UIViewController *)viewController
                 inNavigationController:(UINavigationController *)navigationController withTitle:(NSString *)title {
    
    NSArray *viewControllerArray = [navigationController viewControllers];
    // get index of the previous ViewContoller
    long previousViewControllerIndex = [viewControllerArray indexOfObject:viewController] - 1;
    UIViewController *previous;
    if (previousViewControllerIndex >= 0) {
        previous = [viewControllerArray objectAtIndex:previousViewControllerIndex];
        previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithTitle:title
                                                     style:UIBarButtonItemStylePlain
                                                     target:nil
                                                     action:nil];
    }
}

+ (void)presentNavigationController:(UINavigationController *)navigationController
             withRootViewController:(UIViewController *)rootViewController {
    
    //present navigation controller with root view controller
    UINavigationController *newNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    newNavigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [navigationController presentViewController:newNavigationController animated:YES completion:nil];
}

+ (CGSize)popOverPreferredContentSize {
    
    CGFloat viewHeight = [DCUtility mainWindowSize].height - 2*80;
    CGSize preferredContentSize = CGSizeMake(365.0, viewHeight);
    return preferredContentSize;
}

+ (CGRect)navigationBarFrameForNavigationController:(UINavigationController *)navigationController {
    
    CGRect frame = navigationController.navigationBar.frame;
    if ([DCAPPDELEGATE windowState] == oneThirdWindow || [DCAPPDELEGATE windowState] == halfWindow) {
        frame.size.height = NAVIGATION_BAR_HEIGHT_WITH_STATUS_BAR;
    } else {
        frame.size.height = NAVIGATION_BAR_HEIGHT_NO_STATUS_BAR;
    }
    return frame;
}


@end
