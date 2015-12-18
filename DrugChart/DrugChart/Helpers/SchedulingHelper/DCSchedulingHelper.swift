//
//  DCSchedulingHelper.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 11/13/15.
//
//

import UIKit
import CocoaLumberjack

class DCSchedulingHelper: NSObject {
    
    static func screenTitleForScreenType(screenType : SchedulingDetailType) -> String {
        
        //screen title for detail type
        var title = EMPTY_STRING
        if (screenType == eDetailSpecificTimesRepeatType) {
            title = NSLocalizedString("REPEAT", comment: "")
        } else if (screenType == eDetailIntervalRepeatFrequency) {
            title = NSLocalizedString("REPEAT_FREQUENCY", comment: "")
        }
        return title
    }
    
    static func scheduleDisplayArrayForScreenType(screenType : SchedulingDetailType) -> NSMutableArray {
        
        var scheduleArray = NSMutableArray()
        if (screenType == eDetailSchedulingType) {
            scheduleArray = [SPECIFIC_TIMES, INTERVAL]
        } else if (screenType == eDetailSpecificTimesRepeatType) {
            scheduleArray = [FREQUENCY, EVERY]
        }
        return scheduleArray
    }
    
    static func schedulingDetailTypeAtIndexPath(indexPath : NSIndexPath, forFrequencyType type : NSString) -> SchedulingDetailType? {
        
        if indexPath.section == 0 {
            return eDetailSchedulingType
        } else {
            if type == SPECIFIC_TIMES {
                if indexPath.row == 1 {
                    return eDetailSpecificTimesRepeatType
                }
            } else {
                //interval frequency
                if indexPath.row == 0 {
                    return eDetailIntervalRepeatFrequency
                }
            }
        }
        return nil
    }
    
    static func specificTimesDescriptionValueForRepeatFrequency(repeatFrequency : NSString) -> NSString {
        
        switch repeatFrequency {
        case SINGLE_DAY :
            return DAY
        case SINGLE_WEEK :
            return WEEK
        case SINGLE_MONTH :
            return MONTH
        default:
            return repeatFrequency
        }
    }
    
    static func specificTimesPickerTypeForRepeatType(repeatType : NSString) -> PickerType {
        
        switch repeatType {
        case DAILY :
            return eDailyCount
        case WEEKLY :
            return eWeeklyCount
        case MONTHLY :
            return eMonthlyCount
        case YEARLY :
            return eYearlyCount
        default :
            return eDailyCount
        }
    }
    
    static func includeStartAndEndTimeInIntervalDescriptionForInterval(interval : DCInterval) -> Bool {
        
        //check to determine if start and end time is to be included in description
        return (interval.hasStartAndEndDate == true && interval.startTime != nil && interval.endTime != nil)
    }
    
    static func scheduleDescriptionForIntervalValue(interval : DCInterval) -> NSString {
        
        let descriptionText = NSMutableString(string: NSLocalizedString("DAILY_DESCRIPTION", comment: ""))
        switch interval.repeatFrequencyType {
        case DAYS_TITLE :
            if (interval.daysCount == "1") {
                descriptionText.appendFormat(" %@", DAY)
            } else {
                descriptionText.appendFormat(" %@ %@", interval.daysCount, DAYS)
            }
        case HOURS_TITLE :
            if (interval.hoursCount == "1") {
                descriptionText.appendFormat(" %@", HOUR)
            } else {
                descriptionText.appendFormat(" %@ %@", interval.hoursCount, HOURS)
            }
        case MINUTES_TITLE :
            if (interval.minutesCount == "1") {
                descriptionText.appendFormat(" %@", MINUTE)
            } else {
                descriptionText.appendFormat(" %@ %@", interval.minutesCount, MINUTES)
            }
        default :
            break
        }
        if (includeStartAndEndTimeInIntervalDescriptionForInterval(interval) == true) {
            descriptionText.appendFormat(" between %@ and %@", interval.startTime, interval.endTime)
        }
        descriptionText.appendString(DOT)
        return descriptionText
    }
    
    static func scheduleDescriptionForReapeatValue(repeatValue : DCRepeat) -> NSMutableString {
        
        var descriptionText : NSMutableString = NSMutableString()
        switch repeatValue.repeatType {
            case DAILY :
                if (repeatValue.frequency == SINGLE_DAY) {
                    descriptionText = NSMutableString(format: "%@ day.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""))
                } else {
                    descriptionText = NSMutableString(format: "%@ %@", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency)
                }
            case WEEKLY :
                descriptionText = descriptionTextForWeeklySpecificTimesSchedulingForRepeatValue(repeatValue)
            case MONTHLY:
                descriptionText = descriptionTextForMonthlySpecificTimesSchedulingForRepeatValue(repeatValue)
            case YEARLY:
                descriptionText = descriptionTextForYearlySpecificTimesSchedulingForRepeatValue(repeatValue)
            default:
                descriptionText = NSMutableString(format: "%@ %@", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency)
        }
        return descriptionText
    }
    
    
    static func splitComponentsSeparatedBySpace(ontheValue : String) -> (firstString : NSString, weekDay : String) {
        
        let contentArray = ontheValue.characters.split{$0 == " "}.map(String.init)
        return (contentArray[0], contentArray[1])
    }
    
    static func descriptionTextForWeeklySpecificTimesSchedulingForRepeatValue(repeatValue : DCRepeat) -> NSMutableString {
        
        //description for weekly Specific Times
        var descriptionText : NSMutableString = NSMutableString()
        let weekDays = repeatValue.weekDays as NSArray as? [String]
        let weeksString = weekDays!.joinWithSeparator(", ")
        if (repeatValue.weekDays.count > 0) {
            if (repeatValue.frequency == SINGLE_WEEK) {
                descriptionText = NSMutableString(format: "%@ week on %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), weeksString)
            } else {
                descriptionText = NSMutableString(format: "%@ %@ on %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency, weeksString)
            }
        } else {
            if (repeatValue.frequency == SINGLE_WEEK) {
                descriptionText = NSMutableString(format: "%@ week.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""))
            } else {
                descriptionText = NSMutableString(format: "%@ %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency)
            }
        }
        return descriptionText
    }
    
   static func descriptionTextForYearlySpecificTimesSchedulingForRepeatValue(repeatValue : DCRepeat) -> NSMutableString {
    
    //description text for yearly specific times scheduling for each and on the cases
        var descriptionText : NSMutableString = NSMutableString()
        if (repeatValue.isEachValue == true) {
            var eachValue : String = EMPTY_STRING
            if (repeatValue.yearEachValue == nil) {
                let currentDay = DCDateUtility.currentDay()
                let currentMonth = DCDateUtility.currentMonth()
                let monthString = DCDateUtility.monthNames()[currentMonth - 1]
                repeatValue.yearEachValue = String("\(currentDay) \(monthString)")
            }
            let (day, month) = splitComponentsSeparatedBySpace(repeatValue.yearEachValue)
            if let number = Int(day as String) {
                let convertedNumber = NSNumber(integer:number)
                DDLogDebug("\(convertedNumber)")
                let ordinal = NSString.ordinalNumberFormat(convertedNumber)
                eachValue = ordinal
            }
            if (repeatValue.frequency == SINGLE_YEAR) {
                descriptionText = NSMutableString(format: "%@ year on the %@ of %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), eachValue, month)
            } else {
                descriptionText = NSMutableString(format: "%@ %@ on the %@ of %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency, eachValue, month)
            }
        } else {
            if (repeatValue.yearOnTheValue == nil) {
                repeatValue.yearOnTheValue = "First Sunday January"
            }
            if (repeatValue.frequency == SINGLE_YEAR) {
                descriptionText = NSMutableString(format: "%@ year on the %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.yearOnTheValue )
            } else {
                let yearArray = repeatValue.yearOnTheValue.characters.split{$0 == " "}.map(String.init)
                let indexValue = yearArray[0]
                let day = yearArray[1]
                let month = yearArray[2]
                descriptionText = NSMutableString(format: "%@ %@ on the %@ %@ of %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency, indexValue, day, month)
            }
        }
        return descriptionText
    }
    
    static func descriptionTextForMonthlySpecificTimesSchedulingForRepeatValue(repeatValue : DCRepeat) -> NSMutableString {
        
        //decription for monthly Specific times for each & on the cases
        var descriptionText : NSMutableString = NSMutableString()
        if (repeatValue.isEachValue == true) {
            var eachValue : String = EMPTY_STRING
            if (repeatValue.eachValue == nil) {
                let currentDay = DCDateUtility.currentDay()
                repeatValue.eachValue = String(currentDay)
            }
            if let number = Int(repeatValue.eachValue) {
                let convertedNumber = NSNumber(integer:number)
                DDLogDebug("\(convertedNumber)")
                let ordinal = NSString.ordinalNumberFormat(convertedNumber)
                eachValue = ordinal
            }
            if (repeatValue.frequency == "1 month") {
                descriptionText = NSMutableString(format: "%@ month on the %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), eachValue)
            } else {
                descriptionText = NSMutableString(format: "%@ %@ on the %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency, eachValue)
            }
        } else {
            if (repeatValue.onTheValue == EMPTY_STRING) {
                repeatValue.onTheValue = "First Sunday"
            }
            if (repeatValue.frequency == "1 month") {
                descriptionText = NSMutableString(format: "%@ month on the %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.onTheValue )
            } else {
                descriptionText = NSMutableString(format: "%@ %@ on the %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency, repeatValue.onTheValue )
            }
        }
        return descriptionText
    }
    
    static func administratingTimesStringFromTimeArray(timeArray : NSMutableArray) -> NSString {
        
        let predicate = NSPredicate(format: "selected == 1")
        let filteredArray = timeArray.filteredArrayUsingPredicate(predicate)
        if (filteredArray.count != 0) {
            var selectedTimesArray =  [String]()
            for timeDictionary in filteredArray {
                let time = timeDictionary["time"]
                selectedTimesArray.append((time as? String)!)
            }
            let timeString = selectedTimesArray.joinWithSeparator(", ")
            return timeString
      }
       return EMPTY_STRING
    }
    
    static func numbersArrayWithMaximumCount(maxCount : NSInteger) -> NSMutableArray {
        
        let numbersArray = NSMutableArray()
        for number : NSInteger in 1...maxCount {
            [numbersArray.addObject(number)]
        }
        return numbersArray;
    }
    
    static func dateIsLessThanOrEqualToEndDate(date : NSDate, endDate : NSDate) -> Bool {
        
        //check if date is less than or equal to end date
        return (date.compare(endDate) == .OrderedAscending) || (date.compare(endDate) == .OrderedSame)
    }
    
    static func administrationTimesForIntervalSchedulingWithRepeatFrequencyType(type : PickerType, timeGap difference : Int ,WithStartDateString startDateString : String, WithendDateString endDateString : String) -> NSMutableArray {
        
        //administration times for interval scheduling with start date and end date in 24 hr format. Calculate administration times between start date and end date from the repeat frequency
        let startDate = DCDateUtility.dateFromSourceString(startDateString)
        let endDate = DCDateUtility.dateFromSourceString(endDateString)
        let calendar = NSCalendar.currentCalendar()
        let calendarUnit : NSCalendarUnit = (type == eHoursCount) ? .Hour : .Minute
        let timeArray : NSMutableArray = []
        var newDate = startDate
        timeArray.addObject(startDateString)
        while (dateIsLessThanOrEqualToEndDate(newDate, endDate: endDate)) {
            newDate = calendar.dateByAddingUnit(calendarUnit, value: difference, toDate: newDate!, options: NSCalendarOptions.MatchNextTime)
            if(dateIsLessThanOrEqualToEndDate(newDate, endDate: endDate)) {
                let newDateString = DCDateUtility.timeStringInTwentyFourHourFormat(newDate)
                timeArray.addObject(newDateString)
            }
        }
        return timeArray
    }
}
