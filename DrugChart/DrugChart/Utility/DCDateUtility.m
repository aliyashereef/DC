//
//  DCDateUtility.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 09/03/15.
//
//

#import "DCDateUtility.h"

@implementation DCDateUtility

#define CUSTOM_DATE_FORMAT @"yyyy-MM-d HH:mm:ss"

+ (NSDateFormatter *)sharedDateFormatter {
    static NSDateFormatter *sharedFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedFormatter = [[NSDateFormatter alloc] init];
    });
    
    return sharedFormatter;
}

+ (NSDate *)initialDateForCalendarDisplay:(NSDate *)date
                           withAdderValue:(NSInteger)adder {
    
    //make current date as the middle date and get initial day of the week
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    // since iOS returns the date in UTC, we are setting the calendar days from the datecomponents
    // in the same format.
    [currentCalendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:UTC]];
    NSDateComponents *components = [currentCalendar components:DATE_COMPONENTS fromDate:date];
    [components setDay:components.day];
    NSDate *todayMidnightDate = [self midNightTimeForDate:date];
    NSDateComponents *initialComponents = [currentCalendar components:DATE_COMPONENTS fromDate:todayMidnightDate];
    [initialComponents setDay:components.day + adder];
    [initialComponents setHour:0];
    [initialComponents setMinute:0];
    [initialComponents setSecond:0];
    NSDate *initialDate = [currentCalendar dateFromComponents:initialComponents];
    return initialDate;
    
}

+ (NSDate *)midNightTimeForDate:(NSDate *)date {
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    // since iOS returns the date in UTC, we are setting the calendar days from the datecomponents
    // in the same format.
    [currentCalendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:UTC]];
    NSDateComponents *components = [currentCalendar components:DATE_COMPONENTS fromDate:date];
    [components setDay:components.day];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *todayMidnightDate = [currentCalendar dateFromComponents:components];
    return todayMidnightDate;
}

+ (NSDate *)shortDateFromDate:(NSDate *)originalDate {
    
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSCalendarUnitYear |NSCalendarUnitMonth |NSCalendarUnitDay
                                    fromDate:originalDate];
    NSDate *shortDate = [[NSCalendar currentCalendar]
                         dateFromComponents:components];
    return shortDate;
}

+ (NSArray *)monthNames {
    
    //get month names
    NSDateFormatter *formatter = [self sharedDateFormatter];
    NSMutableArray *monthSymbols = [[NSMutableArray alloc] init];
    for(int months = 0; months < 12; months++) {
        [monthSymbols addObject:[NSString stringWithFormat:@"%@", [[formatter monthSymbols]objectAtIndex: months]]];
    }
    return monthSymbols;
}

+ (NSString *)monthNameAndYearForWeekDatesArray:(NSArray *)datesArray {
    
    NSArray *monthSymbols = [self monthNames];
    NSMutableArray *displayArray = [[NSMutableArray alloc] init];
    for (NSDate *date in datesArray) {
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:DATE_COMPONENTS fromDate:date];
       NSMutableString *dateString = [NSMutableString stringWithFormat:@"%@ %ld", [monthSymbols objectAtIndex:[dateComponents month] - 1], (long)[dateComponents year]];
        [displayArray addObject:dateString];
    }
    NSString *monthYear = [DCUtility mostOccurredStringFromArray:displayArray];
    return monthYear;
}

+ (NSMutableArray *)nextAndPreviousDays:(NSInteger)daysCount
                    withReferenceToDate:(NSDate *)date {
    //get dates of week
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    NSMutableArray *weekdays = [[NSMutableArray alloc] init];
    for (int i = 0; i < daysCount; i++) {
        [weekdays addObject:date];
        NSCalendar *currentCalendar = [NSCalendar currentCalendar];
        [currentCalendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:UTC]];
        date = [currentCalendar dateByAddingComponents:components toDate:date options:0];
    }
    return weekdays;
}

+ (NSDate *)dateForDateString:(NSString *)dateString
               withDateFormat:(NSString *)dateFormatString {
    //convert date string to NSDate value
    NSDateFormatter *formatter = [self sharedDateFormatter];
    //[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
    [formatter setDateFormat:dateFormatString];
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}

+ (NSString *)dateStringFromDate:(NSDate *)date
                        inFormat:(NSString *)formatString {
 
    NSDateFormatter *formatter = [self sharedDateFormatter];
    [formatter setDateFormat:formatString];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

+ (NSString *)displayDateInTwentyFourHourFormat:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [self sharedDateFormatter];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *displayString = [dateFormatter stringFromDate:date];
    return displayString;
}

+ (NSDate *)dateFromSourceString:(NSString *)sourceString {
    
    NSDate *convertedDate = nil;
    NSArray *dateFormatterList = [NSArray arrayWithObjects:EMIS_DATE_FORMAT,
                                 @"yyyy-MM-dd HH:mm:ss", @"yyyy-MM-dd HH:mm:ss.SSS", @"yyyy-MM-dd'T'HH:mm:ss",@"dd MMM,yyyy HH:mm", @"d-MMM-yyyy HH:mm", TWENTYFOUR_HOUR_FORMAT, @"yyyy-MM-dd HH:mm",@"dd MMM yyyy",nil];//include all possible date formats here
    if (sourceString) {
        NSDateFormatter *dateFormatter = [self sharedDateFormatter];
        for (NSString *dateFormatterString in dateFormatterList) {
            [dateFormatter setDateFormat:dateFormatterString];
            NSDate *originalDate = [dateFormatter dateFromString:sourceString];
            if (originalDate) {
                convertedDate = originalDate;
                break;
            }
        }
    }
    return convertedDate;
}

+ (NSString *)nextMedicationDisplayStringFromDate:(NSDate *)date {
    
    if (date) {
        NSDateFormatter *formatter = [self sharedDateFormatter];
        [formatter setDateFormat:DISPLAY_DATE_FORMAT];
        NSString *displayDateString = [formatter stringFromDate:date];
        if (![displayDateString isEqualToString:EMPTY_STRING]) {
            NSArray *splittedDateArray = [displayDateString componentsSeparatedByString:COMMA];
            if ([splittedDateArray count] > 0) {
                NSString *timeString = [splittedDateArray objectAtIndex:0];
                NSString *dateString = [splittedDateArray objectAtIndex:1];
                NSString *displayString = [NSString stringWithFormat:@"%@, %@", timeString, dateString];
                return displayString;
            }
        }
    }
    return nil;
}

+ (NSString *)timeStringInTwentyFourHourFormat:(NSDate *)time {
    
    //get time in 24 hour format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    NSString *displayString = [dateFormatter stringFromDate:time];
    return displayString;
}

+ (NSDate *)administrationDateForString:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [self sharedDateFormatter];
    NSArray *dateFormatterList = [NSArray arrayWithObjects:@"yyyy-MM-dd'T'HH:mm:ss",
                                  @"yyyy-MM-dd'T'HH:mm:ss.SSS", nil];
    for (NSString *dateFormatterString in dateFormatterList) {
        
        [dateFormatter setDateFormat:dateFormatterString];
        NSDate *scheduledDate = [dateFormatter dateFromString:dateString];
        if (scheduledDate) {
            return scheduledDate;
        }
    }
    return nil;
}

+ (NSString *)systemDateStringInShortDisplayFormat {
    
    NSDate *currentSystemDate = [NSDate date];
    NSString *currentDateString = [self dateStringFromDate:currentSystemDate inFormat:SHORT_DATE_FORMAT];
    return currentDateString;
}

+ (NSDateComponents *)currentDateComponentsForCalendarUnit:(NSCalendarUnit)unit {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentSystemDate = [NSDate date];
    NSDateComponents *components = [calendar components:unit fromDate:currentSystemDate];
    return  components;
}

+ (NSInteger)currentWeekDayIndex {
    
    //current week day index
    NSDateComponents *components = [self currentDateComponentsForCalendarUnit:NSCalendarUnitWeekday];
    NSInteger weekDay = components.weekday;
    return weekDay;
}

+ (NSInteger)currentDay {
    
    //current day
    NSDateComponents *components = [self currentDateComponentsForCalendarUnit:NSCalendarUnitDay];
    NSInteger day = components.day;
    return day;
}

+ (NSInteger)currentMonth {
    
    //current month
    NSDateComponents *components = [self currentDateComponentsForCalendarUnit:NSCalendarUnitMonth];
    NSInteger month = components.month;
    return month;
}

@end
