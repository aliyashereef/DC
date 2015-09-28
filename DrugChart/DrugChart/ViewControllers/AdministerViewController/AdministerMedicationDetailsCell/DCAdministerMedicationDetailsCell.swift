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
    @IBOutlet weak var startDateLabel: UILabel!
    
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
        if (medicationDetails?.route != nil && medicationDetails?.instruction != nil) {
                   populateRouteAndInstructionLabels(medicationDetails!.route, instruction: medicationDetails!.instruction)
        }
        let startDateString : String? = DCDateUtility.convertDate(DCDateUtility.dateFromSourceString(medicationDetails?.startDate), fromFormat: DEFAULT_DATE_FORMAT, toFormat: DATE_MONTHNAME_YEAR_FORMAT)
        startDateLabel.text = startDateString
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
