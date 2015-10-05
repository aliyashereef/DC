//
//  DCDateUtility.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 09/03/15.
//
//

#import "DCDateUtility.h"

@implementation DCDateUtility

+ (NSInteger)calculateAgeFromDate:(NSDate *)birthbDate {
    
    NSDate *today = [NSDate date];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:birthbDate
                                       toDate:today
                                       options:0];
    return ageComponents.year;
    
}

+ (NSDate *)getInitialDateForFiveDayDisplay:(NSDate *)date {
    
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
    [initialComponents setDay:components.day - 2];
    [initialComponents setHour:0];
    [initialComponents setMinute:1];
    [initialComponents setSecond:0];
    NSDate *initialDate = [currentCalendar dateFromComponents:initialComponents];
    return initialDate;
    
}


+ (NSDate *)getInitialDateOfWeekForDisplay:(NSDate *)date {
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
    [initialComponents setDay:components.day - 3];
    [initialComponents setHour:0];
    [initialComponents setMinute:1];
    [initialComponents setSecond:0];
    NSDate *initialDate = [currentCalendar dateFromComponents:initialComponents];
    return initialDate;
}

+ (NSString *)getDisplayStringForStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    //get date format eg:Mar 12, 2015
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSArray *monthSymbols = [formatter shortMonthSymbols];
    NSDateComponents *startDateComponents = [[NSCalendar currentCalendar] components:DATE_COMPONENTS fromDate:startDate];
    NSDateComponents *endDateComponents = [[NSCalendar currentCalendar] components:DATE_COMPONENTS fromDate:endDate];
    //If different year is to be checked
    NSMutableString *rangeString;
    if ([startDateComponents month] == [endDateComponents month] && [startDateComponents year] == [endDateComponents year]) {
        rangeString = [NSMutableString stringWithFormat:@"%@ %ld - %ld, %ld", [monthSymbols objectAtIndex:[startDateComponents month] - 1],
                       (long)[startDateComponents day], (long)[endDateComponents day], (long)[endDateComponents year]];
    } else {
        if ([startDateComponents month] != [endDateComponents month]) {
            //if start and end dates fall in different months
            if ([startDateComponents year] == [endDateComponents year]) {
                //all dates fall in the same year
                rangeString = [NSMutableString stringWithFormat:@"%@ %ld - %@ %ld, %ld", [monthSymbols objectAtIndex:[startDateComponents month] - 1],
                               (long)[startDateComponents day], [monthSymbols objectAtIndex:[endDateComponents month] - 1], (long)[endDateComponents day], (long)[endDateComponents year]];
            } else {
                //start date and end dates are in two different years
                rangeString = [NSMutableString stringWithFormat:@"%@ %ld, %ld - %@ %ld, %ld", [monthSymbols objectAtIndex:[startDateComponents month] - 1],
                               (long)[startDateComponents day], (long)[startDateComponents year], [monthSymbols objectAtIndex:[endDateComponents month] - 1], (long)[endDateComponents day], (long)[endDateComponents year]];
            }
        }
    }
    return rangeString;
}

+ (NSDate *)getNextWeekStartDate:(NSDate *)date {
    //get next week start date
    NSDateComponents *components = [[NSCalendar currentCalendar] components:DATE_COMPONENTS fromDate:date];
    [components setDay:[components day] + 1];
    [components setHour:20];
    [components setMinute:0];
    [components setSecond:0];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

+ (NSDate *)getPreviousWeekEndDate:(NSDate *)date {
    //get previous week end date
    NSDateComponents *components = [[NSCalendar currentCalendar] components:DATE_COMPONENTS fromDate:date];
    [components setDay:[components day] - 7];
    [components setHour:20];
    [components setMinute:0];
    [components setSecond:0];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

// TODO: delete this method after changing the calendar to 5 day display.
+ (NSMutableArray *)getDaysOfWeekFromDate:(NSDate *)date {
    //get dates of week
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    NSMutableArray *weekdays = [[NSMutableArray alloc] init];
    for (int i = 0; i < 7; i++) {
        [weekdays addObject:date];
        date = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:date options:0];        
    }
    return weekdays;
}

+ (NSMutableArray *)getFiveDaysOfWeekFromDate:(NSDate *)date {
    //get dates of week
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    NSMutableArray *weekdays = [[NSMutableArray alloc] init];
    for (int i = 0; i < 5; i++) {
        [weekdays addObject:date];
        date = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:date options:0];
    }
    return weekdays;
}


+ (NSMutableArray *)getDateDisplayStringForDateArray:(NSArray *)dateArray {
    
    //get date display string in calendar view in eg format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSArray *weekdaySymbols = [dateFormatter shortStandaloneWeekdaySymbols];
    NSMutableArray *weekDays = [[NSMutableArray alloc] init];
    for (NSDate *date in dateArray) {
        NSInteger day = [self getWeekdayForDate:date];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:DATE_COMPONENTS fromDate:date];
        NSString *displayText = [NSString stringWithFormat:@"%@ %li/%li", [weekdaySymbols objectAtIndex:day-1], (long)[components day], (long)[components month]];
        [weekDays addObject:displayText];
    }
    return weekDays;
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

+ (NSString *)getStartDateDisplayString:(NSString *)date {
    //start date display string in patient home screen
    NSString *formatString = LONG_DATE_FORMAT;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
    [dateFormatter setDateFormat:formatString];
    NSDate *formattedDate = [dateFormatter dateFromString:date];
    NSString *convertedDate = [dateFormatter stringFromDate:formattedDate];
    convertedDate = [self convertDate:formattedDate FromFormat:DEFAULT_DATE_FORMAT ToFormat:DATE_FORMAT_START_DATE];
    return convertedDate;
}

+ (NSString *)getDisplayStringInTwelveHourFormatFromTimeString:(NSString *)timeString {
    
    NSString *timeDisplayString = nil;
    NSDate *date = [DCDateUtility dateForDateString:timeString withDateFormat:TWENTYFOUR_HOUR_FORMAT];
    NSDateFormatter *twelveHourFormatter = [[NSDateFormatter alloc] init];
    [twelveHourFormatter setDateFormat:TWELVE_HOUR_FORMAT];
    timeDisplayString = [twelveHourFormatter stringFromDate:date];
    return timeDisplayString;
}

+ (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate {
    
    //check if the given date is in the range of 2 dates
    BOOL isWithInRange = NO;
    if (((([date compare:firstDate] == NSOrderedDescending) && ([date compare:lastDate]  == NSOrderedAscending)))  ||
        ([date compare:firstDate] == NSOrderedSame) || ([date compare:lastDate] == NSOrderedSame)) {
        
        isWithInRange = YES;
    }
    return isWithInRange;
}


+ (NSString *)convertDate:(NSDate *)date FromFormat:(NSString *)initialFormat ToFormat:(NSString *)finalFormat {
    //convert date from one format to another format
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:initialFormat];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
    [formatter setDateFormat:finalFormat];
    NSString *convertedDateString = [formatter stringFromDate:date];
    return convertedDateString;
}

+ (NSString *)getCurrentSystemTime {
    
    //get time value from current system time
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:TWENTYFOUR_HOUR_FORMAT];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (NSDate *)getDateInCurrentTimeZone:(NSDate *)date {
    
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:GMT];
    NSTimeZone *destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate *systemDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date];
    return systemDate;
    
}

+ (NSDate *)GetDateInGMTTimeZone :(NSDate *)date {
    
    NSTimeZone *destinationTimeZone = [NSTimeZone timeZoneWithAbbreviation:GMT];
    NSTimeZone *sourceTimeZone = [NSTimeZone systemTimeZone];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate *systemDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date];
    return systemDate;
}

+ (NSDate *)getTodaysEndTime {
    
    //calculate end time of today
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    [currentCalendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
    NSDateComponents *components = [currentCalendar components:DATE_COMPONENTS fromDate:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]];
    NSDateComponents *newDateComponents = [[NSDateComponents alloc] init];
    [newDateComponents setMinute:59];
    [newDateComponents setHour:23];
    [newDateComponents setYear:components.year];
    [newDateComponents setMonth:components.month];
    [newDateComponents setDay:components.day];
    NSDate *endDate = [currentCalendar dateFromComponents:newDateComponents];
    return endDate;
    
}

+ (NSInteger )getWeekdayForDate:(NSDate *)date {

    //get week day for date
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:date];
    return [comps weekday];
}

+ (NSString *)getNextMedicationTimeInterval:(NSDate *)date {
    
    //get time difference with current date
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:DATE_COMPONENTS fromDate:[self getDateInCurrentTimeZone:[NSDate date]]  toDate:date options:0];
    NSInteger day = [dateComponents day];
    NSInteger hour = [dateComponents hour];
    NSInteger minutes = [dateComponents minute];
    NSMutableString *timeGap = [[NSMutableString alloc] init];
    if (day > 0) {
        [timeGap appendString:[NSString stringWithFormat:@"%lu days ", (unsigned long)day]];
    }
    [timeGap appendString:[NSString stringWithFormat:@"%lu hours %lu minutes", (unsigned long)hour, (unsigned long)minutes]];
    return timeGap;
}

+ (NSString *)getDisplayDateForAddMedication:(NSDate *)date dateAndTime:(BOOL)dateAndTime {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSArray *monthSymbols = [formatter shortMonthSymbols];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:DATE_COMPONENTS fromDate:date];
    NSMutableString *dateString = [NSMutableString stringWithFormat:@"%ld %@, %ld ", (long)[dateComponents day], [monthSymbols objectAtIndex:[dateComponents month] - 1], (long)[dateComponents year]];
    if (dateAndTime) {
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:TWENTYFOUR_HOUR_FORMAT];
        [timeFormatter setLocale:[NSLocale systemLocale]];
        [timeFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
        [dateString appendFormat:@"%@", [timeFormatter stringFromDate:date]];
    }
    return dateString;
}

+ (NSString *)getDisplayDateInTwentyFourHourFormat:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *displayString = [dateFormatter stringFromDate:date];
    return displayString;
}

+ (NSString *)getShortDateDisplayForDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSArray *weekdaySymbols = [dateFormatter shortStandaloneWeekdaySymbols];
    NSInteger day = [self getWeekdayForDate:date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:DATE_COMPONENTS fromDate:date];
    NSString *displayText = [NSString stringWithFormat:@"%@ %li/%li", [weekdaySymbols objectAtIndex:day-1], (long)[components day], (long)[components month]];
    return displayText;
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

+ (NSString *)dateStringFromSourceString:(NSString *)sourceString {
    
    NSDate *date = [DCDateUtility dateFromSourceString:sourceString];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_FORMAT_START_DATE];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:GMT]];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}

+ (NSString *)getNextMedicationDisplayStringForPatientFromDate:(NSDate *)date {
    
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
//                NSDictionary *timeAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                [DCFontUtility getLatoBoldFontWithSize:20.0f], NSFontAttributeName,
//                                                nil];
//                NSDictionary *dateAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                [DCFontUtility getLatoRegularFontWithSize:15.0f], NSFontAttributeName, nil];
//                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:displayDateString];
//                [attributedString setAttributes:timeAttributes range:NSMakeRange(0, timeString.length+1)];
//                [attributedString setAttributes:dateAttributes range:NSMakeRange(timeString.length, dateString.length)];
//                return attributedString;
                NSString *displayString = [NSString stringWithFormat:@"%@, %@", timeString, dateString];
                return displayString;
            }
        }
    }
    return nil;
}

+ (NSString *)getTimeStringInTwentyFourHourFormat:(NSDate *)time {
    
    //get time in 24 hour format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
    NSString *displayString = [dateFormatter stringFromDate:time];
    return displayString;
}

@end
