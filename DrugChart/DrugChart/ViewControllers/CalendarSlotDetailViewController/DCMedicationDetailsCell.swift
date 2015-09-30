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
            let route : String = medicationDetails!.route.stringByReplacingOccurrencesOfString(" ", withString: EMPTY_STRING)
            populateRouteAndInstructionLabels(route, instruction: medicationDetails!.instruction)
        }
        let startDateString : String? = DCDateUtility.convertDate(DCDateUtility.dateFromSourceString(medicationDetails?.startDate), fromFormat: DEFAULT_DATE_FORMAT, toFormat: DATE_MONTHNAME_YEAR_FORMAT)
        dateLabel.text = startDateString
    }

    func populateRouteAndInstructionLabels(route : String , instruction : String) {
        
        let attributedRouteString : NSMutableAttributedString = NSMutableAttributedString(string: route, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(16.0)])
        let instructionString = String(format: " (%@)", instruction)
        if (instruction != EMPTY_STRING) {
            let attributedInstructionsString : NSMutableAttributedString = NSMutableAttributedString(string: instructionString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12.0)])
            attributedRouteString.appendAttributedString(attributedInstructionsString)
        }
        routeAndInstructionLabel.attributedText = attributedRouteString;
    }

}