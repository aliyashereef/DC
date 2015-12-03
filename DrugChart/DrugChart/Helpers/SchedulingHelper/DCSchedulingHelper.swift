//
//  DCSchedulingHelper.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 11/13/15.
//
//

import UIKit

class DCSchedulingHelper: NSObject {
    
    static func screenTitleForScreenType(screenType : SchedulingDetailType) -> String {
        
        //screen title for detail type
        var title = EMPTY_STRING
        if (screenType == eDetailSchedulingType) {
            title = NSLocalizedString("BASE_FREQUENCY", comment:"")
        } else if (screenType == eDetailRepeatType) {
            title = NSLocalizedString("REPEAT", comment: "")
        }
        return title
    }
    
    static func scheduleDisplayArrayForScreenType(screenType : SchedulingDetailType) -> NSMutableArray {
        
        var scheduleArray = NSMutableArray()
        if (screenType == eDetailSchedulingType) {
            scheduleArray = [SPECIFIC_TIMES, INTERVAL]
        } else if (screenType == eDetailRepeatType) {
            scheduleArray = [FREQUENCY, EVERY]
        }
        return scheduleArray
    }
    
    static func schedulingDetailTypeAtIndexPath(indexPath : NSIndexPath) -> SchedulingDetailType? {
        
        if indexPath.section == 0 {
            return eDetailSchedulingType
        } else {
            if indexPath.row == 1 {
                return eDetailRepeatType
            }
        }
        return nil
    }
    
    static func scheduleDescriptionForReapeatValue(repeatValue : DCRepeat) -> NSMutableString {
        
        var descriptionText : NSMutableString = NSMutableString()
        if (repeatValue.repeatType == DAILY) {
            if (repeatValue.frequency == "1 day") {
                descriptionText = NSMutableString(format: "%@ day.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""))
            } else {
                descriptionText = NSMutableString(format: "%@ %@", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency)
            }
        } else if (repeatValue.repeatType == WEEKLY) {
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
        } else if (repeatValue.repeatType == MONTHLY) {
            if (repeatValue.isEachValue == true) {
                var eachValue : String = EMPTY_STRING
                if (repeatValue.eachValue == nil) {
                   // repeatValue.eachValue = "1"
                    let currentDay = DCDateUtility.currentDay()
                    NSLog("currentDay is %d", currentDay)
                    repeatValue.eachValue = String(currentDay)
                }
                if let number = Int(repeatValue.eachValue) {
                    let convertedNumber = NSNumber(integer:number)
                    print(convertedNumber)
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
        } else {
            descriptionText = NSMutableString(format: "%@ %@", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency)
        }
        return descriptionText
    }
    
    static func splitMonthOnTheValues(ontheValue : String) -> (firstString : NSString, weekDay : String) {
        
        let contentArray = ontheValue.characters.split{$0 == " "}.map(String.init)
        return (contentArray[0], contentArray[1])
    }
    
}
