//
//  DCDateUtility.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 09/03/15.
//
//

#import "DCDateUtility.h"

@implementation DCDateUtility

+ (NSDate *)initialDateForCalendarDisplay:(NSDate *)date
                              withAdderValue:(NSInteger)adder {
    
    //make current date as the middle date and get initial day of the week
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    [currentCalendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
    NSDateComponents *components = [currentCalendar components:DATE_COMPONENTS fromDate:date];
    [components setDay:components.day];
    [components setHour:0];
    [components setMinute:1];
    [components setSecond:0];
    NSDate *todayMidnightDate = [currentCalendar dateFromComponents:components];
    NSDateComponents *initialComponents = [currentCalendar components:DATE_COMPONENTS fromDate:todayMidnightDate];
    [initialComponents setDay:components.day + adder];
    [initialComponents setHour:0];
    [initialComponents setMinute:1];
    [initialComponents setSecond:0];
    NSDate *initialDate = [currentCalendar dateFromComponents:initialComponents];
    return initialDate;
    
}

+ (NSArray *)monthNames {
    
    //get month names
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
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

+ (NSMutableArray *)nextAndPreviousSevenDaysWithReferenceToDate:(NSDate *)date {
    //get dates of week
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    NSMutableArray *weekdays = [[NSMutableArray alloc] init];
    for (int i = 0; i < 15; i++) {
        [weekdays addObject:date];
        date = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:date options:0];
    }
    return weekdays;
}

+ (NSDate *)dateForDateString:(NSString *)dateString
               withDateFormat:(NSString *)dateFormatString {
    //convert date string to NSDate value
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
    [formatter setDateFormat:dateFormatString];
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}

+ (NSString *)dateStringFromDate:(NSDate *)date
                        inFormat:(NSString *)formatString {
 
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
    [formatter setDateFormat:formatString];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

+ (NSDate *)dateInCurrentTimeZone:(NSDate *)date {
    
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:GMT];
    NSTimeZone *destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate *systemDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date];
    return systemDate;
}

+ (NSString *)displayDateInTwentyFourHourFormat:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *displayString = [dateFormatter stringFromDate:date];
    return displayString;
}

+ (NSDate *)dateFromSourceString:(NSString *)sourceString {
    
    NSDate *convertedDate = nil;
    NSArray *dateFormatterList = [NSArray arrayWithObjects:EMIS_DATE_FORMAT,
                                 @"yyyy-MM-dd HH:mm:ss", @"yyyy-MM-dd HH:mm:ss.SSS", @"yyyy-MM-dd'T'HH:mm:ss",@"dd MMM,yyyy HH:mm", @"d-MMM-yyyy HH:mm", nil];//include all possible date formats here
    if (sourceString) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
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
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:DISPLAY_DATE_FORMAT];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:GMT]];
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
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
    NSString *displayString = [dateFormatter stringFromDate:time];
    return displayString;
}

+ (NSDate *)administrationDateForString:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:GMT]];
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
    
    NSDate *currentSystemDate = [self dateInCurrentTimeZone:[NSDate date]];
    NSString *currentDateString = [self dateStringFromDate:currentSystemDate inFormat:SHORT_DATE_FORMAT];
    return currentDateString;
}

@end
