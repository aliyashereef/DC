//
//  DCAdministrationStatusCell.swift
//  DrugChart
//
//  Created by aliya on 17/12/15.
//
//

import Foundation

class DCAdministrationStatusCell: UITableViewCell {
    
    @IBOutlet var administrationTimeLabel: UILabel!
    @IBOutlet var administrationStatusLabel: UILabel!
    
    func configureMedicationStatusInCell (medication : DCMedicationSlot) {
        self.administrationTimeLabel.text = "06:00"
        if (medication.medicationAdministration?.status != nil && medication.medicationAdministration.actualAdministrationTime != nil){
            self.administrationStatusLabel.text = medication.status
        } else if (medication.medicationAdministration == nil) {
            self.administrationStatusLabel.text = "Pending"
        }  else if (medication.medicationAdministration?.actualAdministrationTime == nil) {
            self.administrationStatusLabel.text = "Administer Medication"
        }
    }
}