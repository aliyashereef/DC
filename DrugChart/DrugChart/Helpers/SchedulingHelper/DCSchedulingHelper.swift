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
    
    static func scheduleDescriptionForReapeatValue(repeatValue : DCRepeat) -> NSMutableString {
        
        var descriptionText : NSMutableString = NSMutableString()
        switch repeatValue.repeatType {
        case DAILY :
            if (repeatValue.frequency == "1 day") {
                descriptionText = NSMutableString(format: "%@ day.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""))
            } else {
                descriptionText = NSMutableString(format: "%@ %@", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency)
            }
            break
        case WEEKLY :
            descriptionText = descriptionTextForWeeklySpecificTimesSchedulingForRepeatValue(repeatValue)
            break
        case MONTHLY:
            descriptionText = descriptionTextForMonthlySpecificTimesSchedulingForRepeatValue(repeatValue)
            break
        case YEARLY:
            descriptionText = descriptionTextForYearlySpecificTimesSchedulingForRepeatValue(repeatValue)
            break
        default:
            descriptionText = NSMutableString(format: "%@ %@", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency)
            break
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
            if (repeatValue.frequency == "1 week") {
                descriptionText = NSMutableString(format: "%@ week on %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), weeksString)
            } else {
                descriptionText = NSMutableString(format: "%@ %@ on %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency, weeksString)
            }
        } else {
            if (repeatValue.frequency == "1 week") {
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
            if (repeatValue.frequency == "1 year") {
                descriptionText = NSMutableString(format: "%@ year on the %@ of %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), eachValue, month)
            } else {
                descriptionText = NSMutableString(format: "%@ %@ on the %@ of %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency, eachValue, month)
            }
        } else {
            if (repeatValue.yearOnTheValue == nil) {
                repeatValue.yearOnTheValue = "First Sunday January"
            }
            if (repeatValue.frequency == "1 year") {
                descriptionText = NSMutableString(format: "%@ year on the %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.yearOnTheValue )
            } else {
                descriptionText = NSMutableString(format: "%@ %@ on the %@.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency, repeatValue.yearOnTheValue )
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
        for number : NSInteger in 1...7 {
            [numbersArray.addObject(number)]
        }
        return numbersArray;
    }
    
}
