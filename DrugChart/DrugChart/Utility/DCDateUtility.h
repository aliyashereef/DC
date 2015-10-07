//
//  DCDateUtility.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 09/03/15.
//
//

#import <Foundation/Foundation.h>

#define TWENTYFOUR_HOUR_FORMAT @"HH:mm"
#define TWELVE_HOUR_FORMAT @"hh:mm a"
#define DISPLAY_DATE_FORMAT @"HH:mm, dd MMMM"

#define EMIS_DATE_FORMAT @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

@interface DCDateUtility : NSObject

+ (NSInteger)calculateAgeFromDate:(NSDate *)birthbDate;

+ (NSDate *)getNextWeekStartDate:(NSDate *)date;

+ (NSString *)getDisplayStringForStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

+ (NSString *)getMonthAndYearFromStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

+ (NSDate *)getPreviousWeekEndDate:(NSDate *)date;

+ (NSMutableArray *)getDaysOfWeekFromDate:(NSDate *)date;

+ (NSMutableArray *)getDateDisplayStringForDateArray:(NSArray *)dateArray;

+ (NSDate *)dateForDateString:(NSString *)dateString
               withDateFormat:(NSString *)dateFormatString;

+ (NSString *)getStartDateDisplayString:(NSString *)date;

+ (NSString *)getDisplayStringInTwelveHourFormatFromTimeString:(NSString *)timeString;

+ (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate;

+ (NSString *)convertDate:(NSDate *)date FromFormat:(NSString *)initialFormat ToFormat:(NSString *)finalFormat;

+ (NSString *)getCurrentSystemTime;

+ (NSDate *)getDateInCurrentTimeZone:(NSDate *)date;

+ (NSDate *)GetDateInGMTTimeZone :(NSDate *)date ;

+ (NSDate *)getTodaysEndTime;

+ (NSInteger )getWeekdayForDate:(NSDate *)date;

+ (NSDate *)getInitialDateOfWeekForDisplay:(NSDate *)date;

+ (NSString *)getNextMedicationTimeInterval:(NSDate *)date;

+ (NSString *)getDisplayDateForAddMedication:(NSDate *)date dateAndTime:(BOOL)dateAndTime;

+ (NSString *)getDisplayDateInTwentyFourHourFormat:(NSDate *)date;

+ (NSString *)getShortDateDisplayForDate:(NSDate *)date;

+ (NSDate *)dateFromSourceString:(NSString *)sourceString;

+ (NSString *)dateStringFromSourceString:(NSString *)sourceString;

+ (NSString *)getNextMedicationDisplayStringForPatientFromDate:(NSDate *)date;

+ (NSString *)getTimeStringInTwentyFourHourFormat:(NSDate *)time;

+ (NSMutableArray *)getFiveDaysOfWeekFromDate:(NSDate *)date;

+ (NSDate *)getInitialDateForFiveDayDisplay:(NSDate *)date;

@end
