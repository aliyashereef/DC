//
//  DCCalendarHelper.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 2/3/16.
//
//

import UIKit

let ONCE_IN_DAY : String = "Once a day"

class DCCalendarHelper: NSObject {
    
    static func typeDescriptionForMedication(medicationSchedule : DCMedicationScheduleDetails) -> String {
        
        if (medicationSchedule.medicineCategory == ONCE_MEDICATION) {
            return medicationSchedule.medicineCategory
        } else if (medicationSchedule.medicineCategory == WHEN_REQUIRED) {
            return WHEN_REQUIRED_VALUE
        } else {
           
            if let timeArray = medicationSchedule.timeChart {
                if (timeArray.count > 0) {
                    //if medication start date has time slots count less than actual administration times count, get slots count for second day 
                    var initialMedication : NSDictionary
                    initialMedication = ((timeArray.count > 1) ? timeArray[1] : timeArray[0]) as! NSDictionary
                    let medicationCount = initialMedication[MED_DETAILS]?.count
                    if (medicationCount! == 1) {
                        return ONCE_IN_DAY
                    } else {
                        let descriptionText = String(format: "%d times a day", medicationCount!)
                        return descriptionText
                    }
                } else {
                    return REGULAR_MEDICATION
                }
            } else {
                return REGULAR_MEDICATION
            }
        }
    }

}
