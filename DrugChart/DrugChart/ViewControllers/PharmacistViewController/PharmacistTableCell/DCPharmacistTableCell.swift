//
//  DCPharmacistTableCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/29/16.
//
//

import UIKit

class DCPharmacistTableCell: UITableViewCell {

    @IBOutlet weak var medicationNameLabel: UILabel!
    @IBOutlet weak var routeAndInstructionsLabel: UILabel!
    @IBOutlet weak var frequencyDescriptionLabel: UILabel!
    @IBOutlet weak var firstStatusImageView: UIImageView!
    @IBOutlet weak var secondStatusImageView: UIImageView!
    @IBOutlet weak var thirdStatusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillMedicationDetailsInTableCell(medicationSchedule : DCMedicationScheduleDetails) {
        
        //populate medication details
        medicationNameLabel.text = medicationSchedule.name
        self.populateRouteAndInstructionLabel(medicationSchedule)
    }
        
    func populateRouteAndInstructionLabel(medicationDetails : DCMedicationScheduleDetails?) {
        
        let route : String = medicationDetails!.route.stringByReplacingOccurrencesOfString(" ", withString: EMPTY_STRING)
        let attributedRouteString : NSMutableAttributedString = NSMutableAttributedString(string: route, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(16.0)])
        let attributedInstructionsString : NSMutableAttributedString
        let instructionString : String
        if (medicationDetails?.instruction != EMPTY_STRING && medicationDetails?.instruction != nil) {
            instructionString = String(format: " (%@)", (medicationDetails?.instruction)!)
        } else {
            instructionString = EMPTY_STRING
        }
        attributedInstructionsString  = NSMutableAttributedString(string: instructionString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12.0)])
        attributedRouteString.appendAttributedString(attributedInstructionsString)
        routeAndInstructionsLabel.attributedText = attributedRouteString;
    }

}
