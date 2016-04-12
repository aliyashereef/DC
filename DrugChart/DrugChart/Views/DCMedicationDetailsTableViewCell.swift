//
//  DCMedicationDetailsTableViewCell.swift
//  DrugChart
//
//  Created by aliya on 17/12/15.
//
//

import Foundation

class DCMedicationDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet var medicineNameLabel: UILabel!
    @IBOutlet var oralAndInstructionsLabel: UILabel!
    @IBOutlet var frequencyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureMedicationDetails(medicationDetails : DCMedicationScheduleDetails) {
        
        medicineNameLabel.text = medicationDetails.name
        if (medicationDetails.route != nil) {
            populateRouteAndInstructionLabelsWithDetails(medicationDetails)
        }
        self.frequencyLabel.text = DCCalendarHelper.typeDescriptionForMedication(medicationDetails)
    }

    func populateRouteAndInstructionLabelsWithDetails(medicationDetails : DCMedicationScheduleDetails) {
        
        //fill in route and instructions in required font
        let route : String = medicationDetails.route.stringByReplacingOccurrencesOfString(" ", withString: EMPTY_STRING)
        let attributedRouteString : NSMutableAttributedString = NSMutableAttributedString(string:route, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(16.0)])
        let attributedInstructionsString : NSMutableAttributedString
        let instructionString : String
        if (medicationDetails.instruction != EMPTY_STRING && medicationDetails.instruction != nil) {
            instructionString = String(format: " (%@)", (medicationDetails.instruction)!)
        } else {
            instructionString = EMPTY_STRING
        }
        attributedInstructionsString  = NSMutableAttributedString(string: instructionString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12.0)])
        attributedRouteString.appendAttributedString(attributedInstructionsString)
        self.oralAndInstructionsLabel.attributedText = attributedRouteString as NSAttributedString
    }

}
