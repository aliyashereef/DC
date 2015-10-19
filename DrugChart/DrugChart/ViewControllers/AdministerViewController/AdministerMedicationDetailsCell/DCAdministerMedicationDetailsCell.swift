//
//  DCAdministerMedicationDetailsCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/22/15.
//
//

import UIKit

class DCAdministerMedicationDetailsCell: UITableViewCell {
    
    @IBOutlet weak var medicineNameLabel: UILabel!
    @IBOutlet weak var routeAndInstructionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateCellWithMedicationDetails(medicationDetails : DCMedicationScheduleDetails?) {
        
        medicineNameLabel.text = medicationDetails!.name
        if (medicationDetails?.route != nil) {
            populateRouteAndInstructionLabels(medicationDetails)
        }
    }
    
    func populateRouteAndInstructionLabels(medicationDetails : DCMedicationScheduleDetails?) {
        let route : String = medicationDetails!.route.stringByReplacingOccurrencesOfString(" ", withString: EMPTY_STRING)
        let attributedRouteString : NSMutableAttributedString = NSMutableAttributedString(string: route, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(16.0)])
        let attributedInstructionsString : NSMutableAttributedString
        let instructionString : String
        if (medicationDetails?.instruction != EMPTY_STRING && medicationDetails?.instruction != nil) {
            instructionString = String(format: " (%@)", (medicationDetails?.instruction)!)
        } else {
            instructionString = ""
        }
        attributedInstructionsString  = NSMutableAttributedString(string: instructionString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12.0)])
        attributedRouteString.appendAttributedString(attributedInstructionsString)
        routeAndInstructionLabel.attributedText = attributedRouteString;
    }
    
}
