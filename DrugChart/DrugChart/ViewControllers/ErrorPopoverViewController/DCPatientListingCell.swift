//
//  DCPatientListingCell.swift
//  DrugChart
//
//  Created by aliya on 05/10/15.
//
//

import Foundation

class DCPatientListingCell: UITableViewCell {
    
    @IBOutlet var patientNameLabel: UILabel!
    @IBOutlet var doctorNameLabel: UILabel!
    @IBOutlet var bedNoLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    var patientDetails : DCPatient!
    
    func populatePatientCellWithPatientDetails ( patient : DCPatient ) {
        patientDetails = patient
        self.patientNameLabel.text = patient.patientName
        manageBedNumberDisplayForPatient()
        manageConsultantDisplayForPatient()
        manageNextMedicationDisplayForPatient()
    }
    
    func populateBedNumberLabel() {
    
    //populate bed no label
    let titleAttributes  = [NSFontAttributeName: UIFont.systemFontOfSize(13), NSForegroundColorAttributeName : UIColor.blackColor()]
    let contentAttributes  = [NSFontAttributeName: UIFont.systemFontOfSize(13), NSForegroundColorAttributeName : UIColor.getColorForHexString("#878787")]
    let attributedString = NSMutableAttributedString(string:"Bed No \(patientDetails.bedNumber)")
        attributedString.setAttributes(titleAttributes, range: NSMakeRange(0, 6))
        attributedString.setAttributes(contentAttributes, range: NSMakeRange(6, (patientDetails?.bedNumber.characters.count)!))
    bedNoLabel.text = attributedString.string
        
    }
    
    func manageNextMedicationDisplayForPatient() {
        if let date : NSDate = patientDetails.nextMedicationDate {
            dateLabel.text = DCDateUtility.nextMedicationDisplayStringFromDate(date)
        } else {
            dateLabel.text = EMPTY_STRING
        }
    }
    
    func manageConsultantDisplayForPatient () {
        if let consultant : NSString = patientDetails.consultant {
    //To Do : To handle the case with no consultant in the API , we are using a dummy value for doctor.
            doctorNameLabel.text = consultant as String
        } else {
            doctorNameLabel.text = DUMMY_DOCTOR
        }
    }
    
    func manageBedNumberDisplayForPatient() {
        if (patientDetails?.bedNumber != nil) {
    //To Do : To handle the case with no bed number in the API , we are using a dummy value for number.
            populateBedNumberLabel()
        }else {
            patientDetails?.bedNumber = BED_NUMBER
            populateBedNumberLabel()
        }
    }
}