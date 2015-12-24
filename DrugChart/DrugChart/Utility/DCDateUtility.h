//
//  DCDateUtility.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 09/03/15.
//
//

#import <Foundation/Foundation.h>

#define TWENTYFOUR_HOUR_FORMAT @"HH.mm"
#define TWELVE_HOUR_FORMAT @"hh:mm a"
#define DISPLAY_DATE_FORMAT @"HH:mm, dd MMMM"

#define EMIS_DATE_FORMAT @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

@interface DCDateUtility : NSObject

+ (NSString *)monthNameAndYearForWeekDatesArray:(NSArray *)datesArray;

+ (NSDate *)dateForDateString:(NSString *)dateString
               withDateFormat:(NSString *)dateFormatString;

+ (NSString *)dateStringFromDate:(NSDate *)date
                        inFormat:(NSString *)formatString;

+ (NSDate *)dateInCurrentTimeZone:(NSDate *)date;

+ (NSString *)displayDateInTwentyFourHourFormat:(NSDate *)date;

+ (NSDate *)dateFromSourceString:(NSString *)sourceString;

+ (NSString *)nextMedicationDisplayStringFromDate:(NSDate *)date;

+ (NSString *)timeStringInTwentyFourHourFormat:(NSDate *)time;

+ (NSMutableArray *)nextAndPreviousDays:(NSInteger)daysCount
                    withReferenceToDate:(NSDate *)date;

+ (NSDate *)initialDateForCalendarDisplay:(NSDate *)date
                              withAdderValue:(NSInteger)adder;

+ (NSDate *)administrationDateForString:(NSString *)dateString;

+ (NSString *)systemDateStringInShortDisplayFormat;

+ (NSInteger)currentWeekDayIndex;

+ (NSArray *)monthNames;

+ (NSInteger)currentDay;

+ (NSInteger)currentMonth;

@end
