//
//  DCInfusionsHelper.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/12/16.
//
//

import UIKit

class DCInfusionsHelper: NSObject {
    
    static func infusionsTableViewSectionCount(administerOption : NSString?) -> NSInteger {
        
        //get section count from the route selected,
        if let option = administerOption {
            if (option == BOLUS_INJECTION) {
                return SectionCount.eSecondSection.rawValue
            } else {
                return SectionCount.eThirdSection.rawValue
            }
        } else {
            return SectionCount.eFirstSection.rawValue
        }
    }
    
    static func durationBasedInfusionFooterTextForDosage(dosage : DCDosage?, flowDuration : NSString?) -> NSString {
        
        //form duration based infusion text
        var displayText = NSMutableString(string: EMPTY_STRING)
        let durationArray = flowDuration!.componentsSeparatedByString(" ")
        let duration = durationArray[0]
        let durationUnit = durationArray[1]
        var flowRate : Float = 0.0
        if let doseType  = dosage?.type {
            if (doseType == DOSE_FIXED || doseType == DOSE_VARIABLE) {
                displayText = NSMutableString(string: NSLocalizedString("FLOW_RATE_FOOTER", comment: ""))
                if (doseType == DOSE_FIXED) {
                    if let doseValue = dosage?.fixedDose?.doseValue {
                        flowRate = self.flowRateFromDoseValue(doseValue, duration: duration)
                    }
                } else {
                    if let doseValue = dosage?.variableDose?.doseFromValue {
                        flowRate = self.flowRateFromDoseValue(doseValue, duration: duration)
                    }
                }
                let doseUnit = (dosage?.doseUnit != nil) ? (dosage?.doseUnit)! : "mg"
                if (durationUnit.containsString(HOUR)) {
                    displayText.appendFormat("%.1f %@/hour", flowRate, doseUnit)
                } else {
                    displayText.appendFormat("%.1f %@/minute", flowRate, doseUnit)
                }
            }
        }
        return displayText
    }
    
    static func flowRateFromDoseValue(dose : NSString?, duration : NSString?) -> Float {
        
        let flowRate  = NSString(string: dose!).floatValue / NSString(string: duration!).floatValue
        return flowRate
    }
    
    static func hideInlinePickerViewAtIndexIndexPath(pickerIndexPath : NSIndexPath, forSelectedCellAtIndexPath cellIndexPath : NSIndexPath, withAdministerOption option : NSString) -> Bool {
        
        var hidePicker = false
        if (option == BOLUS_INJECTION) {
            if(cellIndexPath.row != pickerIndexPath.row - 1) {
                hidePicker = true
            }
        } else if (option == DURATION_BASED_INFUSION || option == RATE_BASED_INFUSION) {
            if (cellIndexPath.section != SectionCount.eFirstSection.rawValue) {
                hidePicker = true
            } else if (cellIndexPath.section != SectionCount.eFirstSection.rawValue && cellIndexPath.row != pickerIndexPath.row - 1) {
                hidePicker = true
            }
        }
      return hidePicker
    }
    
}
