//
//  DCMedicationDetailsCell.swift
//  DrugChart
//
//  Created by aliya on 23/09/15.
//
//

import Foundation
import UIKit

class  DCMedicationDetailsCell: UITableViewCell {

    @IBOutlet var medicineName: UILabel!
    @IBOutlet var routeAndInstructionLabel: UILabel!
    
    func populateCellWithMedicationDetails(medicationDetails : DCMedicationScheduleDetails?) {
        
        medicineName.text = medicationDetails!.name
        if (medicationDetails?.route != nil) {
            populateRouteAndInstructionLabels(medicationDetails)
        }
    }

    func populateRouteAndInstructionLabels(medicationDetails : DCMedicationScheduleDetails?) {
        let route : String = medicationDetails!.route.stringByReplacingOccurrencesOfString(" ", withString: EMPTY_STRING)
        let attributedRouteString : NSMutableAttributedString = NSMutableAttributedString(string:route, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(16.0)])
        let attributedInstructionsString : NSMutableAttributedString
        let instructionString : String
        if (medicationDetails?.instruction != EMPTY_STRING && medicationDetails?.instruction != nil) {
            instructionString = String(format: " (%@)", (medicationDetails?.instruction)!)
        } else {
            instructionString = EMPTY_STRING
        }
        attributedInstructionsString  = NSMutableAttributedString(string: instructionString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12.0)])
        attributedRouteString.appendAttributedString(attributedInstructionsString)
        routeAndInstructionLabel.attributedText = attributedRouteString;

    }

}