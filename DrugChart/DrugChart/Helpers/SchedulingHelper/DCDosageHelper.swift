//
//  DCDosageHelper.swift
//  DrugChart
//
//  Created by Felix Joseph on 19/01/16.
//
//

import UIKit

class DCDosageHelper: NSObject {

    static func updatePreviewDetailsArray (conditions:DCConditions, currentStartingDose newStartingDose: Float, doseUnit unit: String) -> [String]{
        var nextDoseValue = newStartingDose
        var stringForNextPreviewDetail : String = ""
        var previewDetails = [String]()
        var nextDoseValueString : String = ""
        if conditions.change == REDUCING {
            while nextDoseValue > NSString(string: conditions.until).floatValue {
                nextDoseValueString = String(format: nextDoseValue == floor(nextDoseValue) ? "%.0f" : "%.1f", nextDoseValue)
                stringForNextPreviewDetail = "\(nextDoseValueString) \(unit) for \(conditions.every)"
                previewDetails.append(stringForNextPreviewDetail)
                nextDoseValue = nextDoseValue - NSString(string: conditions.dose).floatValue
            }
        } else {
            while nextDoseValue < NSString(string: conditions.until).floatValue {
                nextDoseValueString = String(format: nextDoseValue == floor(nextDoseValue) ? "%.0f" : "%.1f", nextDoseValue)
                stringForNextPreviewDetail = "\(nextDoseValueString) \(unit) for \(conditions.every)"
                previewDetails.append(stringForNextPreviewDetail)
                nextDoseValue = nextDoseValue + NSString(string: conditions.dose).floatValue
            }
        }
        return previewDetails
    }
    
    static func createDescriptionStringForDosageCondition(condition:DCConditions, dosageUnit unit:String) -> String {
        
        var displayString : String = ""
        var change : String = ""
        if (condition.change == REDUCING) {
            change = "Reduce"
        } else {
            change = "Increase"
        }
        if (condition.dose != "" && condition.every != "" && condition.until != "") {
            displayString = "\(change) \(condition.dose) every \(condition.every) until \(condition.until)"
        } else {
            displayString = ""
        }
        if (displayString != "") {
            condition.conditionDescription = displayString
        }
        return displayString
    }
}
