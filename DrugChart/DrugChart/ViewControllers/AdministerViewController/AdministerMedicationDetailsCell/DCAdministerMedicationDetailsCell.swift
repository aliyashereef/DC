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
    
    func populateCellWithMedicationDetails(medicationDetails : DCMedicationScheduleDetails) {
        
        NSLog("Medicine name : %@", medicationDetails.name)
        medicineNameLabel.text = medicationDetails.name
        NSLog("Route : %@", medicationDetails.route)
        NSLog("Instructions : %@", medicationDetails.instruction)
        NSLog("Start date : %@", medicationDetails.startDate)
    }
    
    func populateRouteAndInstructionLabels(route : String , instruction : String) {
        
    }
}
