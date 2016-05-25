//
//  DCPatientBannerView.swift
//  DrugChart
//
//  Created by Jagajith M Kalarickal on 24/05/16.
//
//

import Foundation

@objc protocol PatientDetailsDelegate {
    
    func displayPatientDetails()
}

class DCPatientBannerView: UIView {

    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var hospitalNumberLabel: UILabel!
    @IBOutlet weak var nhsNumberLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var patientBannerButton: UIButton!
    var patientDetailsDelegate : PatientDetailsDelegate?
    
    func displayPatientDetails(patientName: NSString, nhsNumber : NSString , dateOfBirth : NSDate , age: NSString, gender: NSString, hospitalNo: NSString) {
        let dateFormatter : NSDateFormatter = NSDateFormatter.init()
        dateFormatter.dateFormat = BIRTH_DATE_FORMAT
        let dobDateString = dateFormatter.stringFromDate(dateOfBirth)
        patientNameLabel.text = patientName as String
        dobLabel.text = String(format: "\(dobDateString as String) (\(age as String) years)")
        genderLabel.text = gender as String
        nhsNumberLabel.text = nhsNumber as String
        hospitalNumberLabel.text = hospitalNo as String
        if hospitalNo == "(null)"{
            hospitalNumberLabel.text = "HOSP16526"
        }else{
            hospitalNumberLabel.text = hospitalNo as String
        }
    }
    @IBAction func patientBannerButtonPresses(sender: AnyObject) {
        if let delegate = patientDetailsDelegate {
            delegate.displayPatientDetails()
        }
    }
}
