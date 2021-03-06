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
            if (interval.daysCount == ONE) {
                descriptionText.appendFormat(" %@", DAY)
            } else {
                descriptionText.appendFormat(" %@ %@", interval.daysCount, DAYS)
            }
        case HOURS_TITLE :
            if (interval.hoursCount == ONE) {
                descriptionText.appendFormat(" %@", HOUR)
            } else {
                descriptionText.appendFormat(" %@ %@", interval.hoursCount, HOURS)
            }
        case MINUTES_TITLE :
            if (interval.minutesCount == ONE) {
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
    
    static func specificTimesAdministratingTimesCountString(timesCount : NSInteger) -> String {
        
        //form administrating times count string
        var timesString : String = EMPTY_STRING
        switch timesCount {
            case 1 :
                timesString = ONCE
            case 2 :
                timesString = TWICE
            case 3 :
                timesString = THRICE
            default :
                timesString = String(format: "%i times", timesCount)
        }
        return timesString
    }
    
    static func scheduleDescriptionForSpecificTimesRepeatValue(repeatValue : DCRepeat, administratingTimes times : NSArray) -> NSMutableString {
        
        let descriptionText : NSMutableString = NSMutableString()
        let activeAdministratingTimes = self.alreadySelectedAdministratingTimesFromTimeArray(times)
        let timesCountString = self.specificTimesAdministratingTimesCountString(activeAdministratingTimes.count)
        switch repeatValue.repeatType {
            case DAILY :
                descriptionText.appendFormat(NSLocalizedString("SCHEDULING_GENERAL_DESCRIPTION", comment: ""))
                if (activeAdministratingTimes.count > 0) {
                    descriptionText.appendFormat(" %@ a day", timesCountString)
                }
                if (activeAdministratingTimes.count > 0) {
                    descriptionText.appendFormat(" at %@", administratingTimesStringFromTimeArray(NSMutableArray(array: activeAdministratingTimes)))
                }
                if (repeatValue.frequency != SINGLE_DAY) {
                    descriptionText.appendFormat(" every %@", repeatValue.frequency)
                } else {
                    descriptionText.appendString(" every day")
                }
            case WEEKLY :
                descriptionText.appendFormat("%@", descriptionTextForWeeklySpecificTimesSchedulingForRepeatValue(repeatValue, selectedAdministratingTimes: activeAdministratingTimes, timesCountDisplayString: timesCountString))
            case MONTHLY:
                descriptionText.appendFormat("%@", descriptionTextForMonthlySpecificTimesSchedulingForRepeatValue(repeatValue, activeAdministratingTimes: activeAdministratingTimes, timesCountDisplayString : timesCountString))
            case YEARLY:
                descriptionText.appendFormat("%@", descriptionTextForYearlySpecificTimesSchedulingForRepeatValue(repeatValue, activeAdministratingTimes: activeAdministratingTimes, timesCountDisplayString: timesCountString))
            default:
                descriptionText.appendFormat("%@", repeatValue.frequency)
        }
        descriptionText.appendString(DOT)
        return descriptionText
    }
    
    static func splitComponentsSeparatedBySpace(ontheValue : String) -> (firstString : NSString, weekDay : String) {
        
        let contentArray = ontheValue.characters.split{$0 == " "}.map(String.init)
        return (contentArray[0], contentArray[1])
    }
    
    static func descriptionTextForWeeklySpecificTimesSchedulingForRepeatValue(repeatValue : DCRepeat, selectedAdministratingTimes times : NSArray, timesCountDisplayString timesString : String) -> NSMutableString {
        
        //description for weekly Specific Times
        let descriptionText : NSMutableString = NSMutableString()
        descriptionText.appendFormat(NSLocalizedString("SCHEDULING_GENERAL_DESCRIPTION", comment: ""))
        if (times.count > 0) {
            descriptionText.appendFormat(" %@ a day", timesString)
        }
        if (repeatValue.weekDays != nil) {
             var weeksString : String = ""
            var weekDays = repeatValue.weekDays as NSArray as? [String]
            if (weekDays?.count > 1) {
                let lastElement = weekDays!.removeLast()
                weeksString = weekDays!.joinWithSeparator(", ")
                weeksString = weeksString + " and \(lastElement)"
            } else {
                weeksString = weekDays!.joinWithSeparator("")
            }
            descriptionText.appendFormat(" on %@", weeksString)
        }
        if (times.count > 0) {
            descriptionText.appendFormat(" at %@", administratingTimesStringFromTimeArray(NSMutableArray(array: times)))
        }
        descriptionText.appendString(" every")
        if (repeatValue.frequency == SINGLE_WEEK) {
            descriptionText.appendFormat(" %@", WEEK)
        } else {
            descriptionText.appendFormat(" %@", repeatValue.frequency)
        }
        return descriptionText
    }
    
   static func descriptionTextForYearlySpecificTimesSchedulingForRepeatValue(repeatValue : DCRepeat, activeAdministratingTimes times : NSArray, timesCountDisplayString timesString : String) -> NSMutableString {
    
    //description text for yearly specific times scheduling for each and on the cases
        let descriptionText : NSMutableString = NSMutableString()
        descriptionText.appendFormat(NSLocalizedString("SCHEDULING_GENERAL_DESCRIPTION", comment: ""))
        if (times.count > 0) {
            descriptionText.appendFormat(" %@ a day", timesString)
        }
        if (repeatValue.isEachValue == true) {
            descriptionText.appendFormat("%@", descriptionTextForYearlySpecificTimesSchedulingEachValueForRepeatValue(repeatValue, activeAdministratingTimes: times))
        } else {
            descriptionText.appendFormat("%@", descriptionTextForYearlySpecificTimesSchedulingOnTheValueForRepeatValue(repeatValue, activeAdministratingTimes: times))
        }
        return descriptionText
    }
    
    static func descriptionTextForYearlySpecificTimesSchedulingEachValueForRepeatValue(repeatValue : DCRepeat, activeAdministratingTimes times : NSArray) -> NSMutableString {
        
        let descriptionText : NSMutableString = NSMutableString()
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
            descriptionText.appendFormat(" on the %@ %@", eachValue, month)
            if (times.count > 0) {
                descriptionText.appendFormat(" at %@", administratingTimesStringFromTimeArray(NSMutableArray(array: times)))
            }
            descriptionText.appendString(" every year")
            
        } else {
            descriptionText.appendFormat(" on the %@ of %@", eachValue, month)
            if (times.count > 0) {
                descriptionText.appendFormat(" at %@", administratingTimesStringFromTimeArray(NSMutableArray(array: times)))
            }
            descriptionText.appendFormat(" every %@", repeatValue.frequency)
        }
        return descriptionText
    }
    
    static func descriptionTextForYearlySpecificTimesSchedulingOnTheValueForRepeatValue(repeatValue : DCRepeat, activeAdministratingTimes times : NSArray) -> NSMutableString {
        
        let descriptionText : NSMutableString = NSMutableString()
        if (repeatValue.yearOnTheValue == nil) {
            repeatValue.yearOnTheValue = "First Sunday January"
        }
        let yearArray = repeatValue.yearOnTheValue.characters.split{$0 == " "}.map(String.init)
        let indexValue = yearArray[0]
        let day = yearArray[1]
        let month = yearArray[2]
        if (repeatValue.frequency == SINGLE_YEAR) {
            descriptionText.appendFormat(" on the %@ %@ of %@", indexValue, day, month)
            if (times.count > 0) {
                descriptionText.appendFormat(" at %@", administratingTimesStringFromTimeArray(NSMutableArray(array: times)))
            }
            descriptionText.appendString(" every year")
        } else {
            descriptionText.appendFormat(" on the %@ %@ of %@", indexValue, day, month)
            if (times.count > 0) {
                descriptionText.appendFormat(" at %@", administratingTimesStringFromTimeArray(NSMutableArray(array: times)))
            }
            descriptionText.appendFormat(" every %@", repeatValue.frequency)
        }
        return descriptionText
    }
    
    static func descriptionTextForMonthlySpecificTimesSchedulingForRepeatValue(repeatValue : DCRepeat, activeAdministratingTimes times : NSArray, timesCountDisplayString timesString : String) -> NSMutableString {
        
        //decription for monthly Specific times for each & on the cases
        let descriptionText : NSMutableString = NSMutableString()
        descriptionText.appendFormat(NSLocalizedString("SCHEDULING_GENERAL_DESCRIPTION", comment: ""))
        if (times.count > 0) {
            descriptionText.appendFormat(" %@ a day", timesString)
        }
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
            descriptionText.appendFormat(" on the %@", eachValue)
            if (times.count > 0) {
                descriptionText.appendString(" of the month")
            } else {
                descriptionText.appendFormat(" of every %@", repeatValue.frequency)
            }
        } else {
            if (repeatValue.onTheValue == EMPTY_STRING) {
                repeatValue.onTheValue = "First Sunday"
            }
            descriptionText.appendFormat(" on the %@", repeatValue.onTheValue)
            if (times.count > 0) {
                descriptionText.appendString(" of the month")
            } else {
                descriptionText.appendFormat(" of every %@", repeatValue.frequency)
            }
        }
        if (times.count > 0) {
            descriptionText.appendFormat(" at %@", administratingTimesStringFromTimeArray(NSMutableArray(array: times)))
            descriptionText.appendString(" every")
            descriptionText.appendFormat(" %@", repeatValue.frequency)
        }
         return descriptionText
    }
    
    static func alreadySelectedAdministratingTimesFromTimeArray(timeArray : NSArray) -> NSArray {
        
        //get selected administrating times
        let predicate = NSPredicate(format: "selected == 1")
        let filteredArray = timeArray.filteredArrayUsingPredicate(predicate)
        return filteredArray
    }
    
    static func administratingTimesStringFromTimeArray(timeArray : NSMutableArray) -> NSString {
        
        let filteredArray = alreadySelectedAdministratingTimesFromTimeArray(timeArray)
        if (filteredArray.count > 0) {
            var selectedTimesArray =  [String]()
            for timeDictionary in filteredArray {
                let time = timeDictionary["time"]
                selectedTimesArray.append((time as? String)!)
            }
            var timeString : String = ""
            if (selectedTimesArray.count > 1) {
                let lastElement = selectedTimesArray.removeLast()
                timeString = selectedTimesArray.joinWithSeparator(", ")
                timeString = timeString + " and \(lastElement)"
            } else {
                timeString = selectedTimesArray.joinWithSeparator("")
            }
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
    
    static func intervalPreviewArrayFromAdministrationTimeDetails(timeArray : NSArray) -> NSMutableArray {
        
        // get administration times from preview array
        let previewArray : NSMutableArray = []
        for timesDictionary in timeArray {
            let time = timesDictionary["time"]
            previewArray.addObject((time as? String)!)
        }
        return previewArray
    }
}
