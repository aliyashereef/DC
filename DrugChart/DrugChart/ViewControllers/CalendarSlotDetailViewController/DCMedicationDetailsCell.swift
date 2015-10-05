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
    @IBOutlet var dateLabel: UILabel!
    
    func populateCellWithMedicationDetails(medicationDetails : DCMedicationScheduleDetails?) {
        
        medicineName.text = medicationDetails!.name
        if (medicationDetails?.route != nil) {
            populateRouteAndInstructionLabels(medicationDetails)
        }
        let startDateString : String? = DCDateUtility.convertDate(DCDateUtility.dateFromSourceString(medicationDetails?.startDate), fromFormat: DEFAULT_DATE_FORMAT, toFormat: DATE_MONTHNAME_YEAR_FORMAT)
        dateLabel.text = startDateString
    }

    func populateRouteAndInstructionLabels(medicationDetails : DCMedicationScheduleDetails?) {
        
        let attributedRouteString : NSMutableAttributedString = NSMutableAttributedString(string: (medicationDetails?.route)!, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(16.0)])
        let attributedInstructionsString : NSMutableAttributedString
        let instructionString : String
        if (medicationDetails?.instruction != EMPTY_STRING && medicationDetails?.instruction != nil) {
            instructionString = String(format: " (%@)", (medicationDetails?.instruction)!)
        } else {
            instructionString = " (As Directed)"
        }
        attributedInstructionsString  = NSMutableAttributedString(string: instructionString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12.0)])
        attributedRouteString.appendAttributedString(attributedInstructionsString)
        routeAndInstructionLabel.attributedText = attributedRouteString;

    }

}