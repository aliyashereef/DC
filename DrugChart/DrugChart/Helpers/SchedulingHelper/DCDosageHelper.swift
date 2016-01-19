//
//  DCDosageHelper.swift
//  DrugChart
//
//  Created by Felix Joseph on 19/01/16.
//
//

import UIKit

class DCDosageHelper: NSObject {

    static func updatePreviewDetailsArray (conditions:DCConditions, currentStartingDose newStartingDose: Float) -> [String]{
        var nextDoseValue = newStartingDose
        var stringForNextPreviewDetail : String = ""
        var previewDetails = [String]()
        if conditions.change == REDUCING {
            while nextDoseValue > NSString(string: conditions.until).floatValue {
                stringForNextPreviewDetail = "\(nextDoseValue) for \(conditions.every)"
                previewDetails.append(stringForNextPreviewDetail)
                nextDoseValue = nextDoseValue - NSString(string: conditions.dose).floatValue
            }
        } else {
            while nextDoseValue < NSString(string: conditions.until).floatValue {
                stringForNextPreviewDetail = "\(nextDoseValue) for \(conditions.every)"
                previewDetails.append(stringForNextPreviewDetail)
                nextDoseValue = nextDoseValue + NSString(string: conditions.dose).floatValue
            }
        }
        return previewDetails
    }
}
