//
//  DCSchedulingHelper.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 11/13/15.
//
//

import UIKit

class DCSchedulingHelper: NSObject {
    
    class func screenTitleForScreenType(screenType : AddMedicationDetailType) -> String {
        
        //screen title for detail type
        var title = EMPTY_STRING
        if (screenType == eDetailSchedulingType) {
            title = NSLocalizedString("SCHEDULING", comment:"")
        } else if (screenType == eDetailRepeatType) {
            title = NSLocalizedString("REPEAT", comment: "")
        }
        return title
    }
    
    class func scheduleDisplayArrayForScreenType(screenType : AddMedicationDetailType) -> NSMutableArray {
        
        var scheduleArray = NSMutableArray()
        if (screenType == eDetailSchedulingType) {
            scheduleArray = [SPECIFIC_TIMES, INTERVAL]
        } else if (screenType == eDetailRepeatType) {
            scheduleArray = [FREQUENCY, EVERY]
        }
        return scheduleArray
    }
    
    class func scheduleDescriptionForReapeatValue(repeatValue : DCRepeat) -> String {
        
        var descriptionText = EMPTY_STRING
        if (repeatValue.frequency == "1 day") {
            descriptionText = NSString(format: "%@ day.", NSLocalizedString("DAILY_DESCRIPTION", comment: "")) as String
        } else {
            descriptionText = NSString(format: "Medication will be administered every %@", repeatValue.frequency) as String
        }
        return descriptionText
    }
    
}
