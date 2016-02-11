//
//  DCDurationBasedMedicationDetailsCell.swift
//  DrugChart
//
//  Created by aliya on 11/02/16.
//
//

import Foundation

class DCDurationBasedMedicationDetailsCell: UITableViewCell {
    
    @IBOutlet weak var medicineNameLabel: UILabel!
    @IBOutlet weak var dosageRouteAndInstructionLabel: UILabel!
    @IBOutlet weak var medicineCategoryLabel: UILabel!
    @IBOutlet weak var flowRateLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    func configureMedicationDetails(medicationDetails : DCMedicationScheduleDetails) {
        
        medicineNameLabel.text = medicationDetails.name
        if (medicationDetails.route != nil) {
            populateRouteAndInstructionLabelsWithDetails(medicationDetails)
        }
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
        self.dosageRouteAndInstructionLabel.attributedText = attributedRouteString as NSAttributedString
    }
}