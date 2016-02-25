//
//  DCAdministerTableViewCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 16/02/16.
//
//

import UIKit

class DCAdministerTableViewCell: UITableViewCell {

    @IBOutlet weak var doseRouteAndInstructionLabel: UILabel!
    @IBOutlet weak var flowRateLabel: UILabel!
    @IBOutlet weak var medicineCategoryLabel: UILabel!
    @IBOutlet weak var medicineNameLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureMedicationDetails(medicationDetails : DCMedicationScheduleDetails) {
        medicineNameLabel.text = medicationDetails.name
        if (medicationDetails.route != nil) {
            populateRouteAndInstructionLabelsWithDetails(medicationDetails)
        }
        self.medicineCategoryLabel.text = DCCalendarHelper.typeDescriptionForMedication(medicationDetails)
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
            instructionString = ""
        }
        attributedInstructionsString  = NSMutableAttributedString(string: instructionString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12.0)])
        attributedRouteString.appendAttributedString(attributedInstructionsString)
        self.doseRouteAndInstructionLabel.attributedText = attributedRouteString as NSAttributedString
    }
}
