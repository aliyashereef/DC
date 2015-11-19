//
//  DCSchedulingHelper.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 11/13/15.
//
//

import UIKit

class DCSchedulingHelper: NSObject {
    
    static func screenTitleForScreenType(screenType : AddMedicationDetailType) -> String {
        
        //screen title for detail type
        var title = EMPTY_STRING
        if (screenType == eDetailSchedulingType) {
            title = NSLocalizedString("SCHEDULING", comment:"")
        } else if (screenType == eDetailRepeatType) {
            title = NSLocalizedString("REPEAT", comment: "")
        }
        return title
    }
    
    static func scheduleDisplayArrayForScreenType(screenType : AddMedicationDetailType) -> NSMutableArray {
        
        var scheduleArray = NSMutableArray()
        if (screenType == eDetailSchedulingType) {
            scheduleArray = [SPECIFIC_TIMES, INTERVAL]
        } else if (screenType == eDetailRepeatType) {
            scheduleArray = [FREQUENCY, EVERY]
        }
        return scheduleArray
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
            if (repeatValue.frequency == "1 week") {
                descriptionText = NSMutableString(format: "%@ week.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""))
            } else {
                descriptionText = NSMutableString(format: "%@ %@", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency)
            }
        } else if (repeatValue.repeatType == MONTHLY) {
            if (repeatValue.frequency == "1 month") {
                descriptionText = NSMutableString(format: "%@ month.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""))
            } else {
                descriptionText = NSMutableString(format: "%@ %@", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency)
            }
        } else {
            descriptionText = NSMutableString(format: "%@ %@", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency)
        }
//        if (repeatValue.frequency == "1 day") {
//            descriptionText = NSString(format: "%@ day.", NSLocalizedString("DAILY_DESCRIPTION", comment: "")) as String
//        } else if (repeatValue.frequency == "1 week") {
//            descriptionText = NSString(format: "%@ week.", NSLocalizedString("DAILY_DESCRIPTION", comment: "")) as String
//        } else if (repeatValue.frequency == "1 month") {
//            descriptionText = NSString(format: "%@ month.", NSLocalizedString("DAILY_DESCRIPTION", comment: "")) as String
//        } else {
//            descriptionText = NSString(format: "%@ %@", NSLocalizedString("DAILY_DESCRIPTION", comment: ""), repeatValue.frequency) as String
//        }
        return descriptionText
    }
    
    
}
