//
//  DCOneThirdCalendarNavigationTitleView.swift
//  DrugChart
//
//  Created by aliya on 26/11/15.
//
//

import Foundation

class DCOneThirdCalendarNavigationTitleView: UIView {
    
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var patientNameLabelTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var nhsLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func populateViewWithPatientName(patientName: NSString , nhsNumber : NSString , dateOfBirth : NSDate , age: NSString) {
        let dateFormatter : NSDateFormatter = NSDateFormatter.init()
        dateFormatter.dateFormat = BIRTH_DATE_FORMAT
        patientNameLabelTopSpaceConstraint.constant = 0.0
        let dobDateString = dateFormatter.stringFromDate(dateOfBirth)
        patientNameLabel.text = patientName as String
        if dobDateString != EMPTY_STRING {
            dobLabel.text = String(format: "\(dobDateString as String) (\(age as String) years)")
        }
        if nhsNumber != EMPTY_STRING {
            nhsLabel.text = nhsNumber as String
        }
    }
    
    func populatViewForOneThirdLandscapeWithPatientName(patientName: NSString, nhsNumber : NSString , dateOfBirth : NSDate , age: NSString) {
        let dateFormatter : NSDateFormatter = NSDateFormatter.init()
        dateFormatter.dateFormat = BIRTH_DATE_FORMAT
        patientNameLabelTopSpaceConstraint.constant = 8.0
        let dobDateString = dateFormatter.stringFromDate(dateOfBirth)
        patientNameLabel.text = patientName as String
        nhsLabel.text = EMPTY_STRING as String
        dobLabel.text = String(format: "\(dobDateString as String) (\(age as String) years), \(nhsNumber as String)")
    }
    
    func populateViewForPharmacistFullScreen(patientName: NSString, nhsNumber : NSString, dateOfBirth : NSDate, age: NSString) {
        
        let dateFormatter : NSDateFormatter = NSDateFormatter.init()
        dateFormatter.dateFormat = BIRTH_DATE_FORMAT
        patientNameLabelTopSpaceConstraint.constant = 8.0
        let dobDateString = dateFormatter.stringFromDate(dateOfBirth)
        patientNameLabel.text = NSLocalizedString("MEDICATION_LIST", comment: "title")
        patientNameLabel.font = UIFont.boldSystemFontOfSize(18)
        nhsLabel.text = EMPTY_STRING as String
        dobLabel.text = String(format: "\(patientName as String) | \(dobDateString as String)(\(age as String) years) | \(nhsNumber as String)")
        dobLabel.font = UIFont.systemFontOfSize(12)
    }
    
    func populateViewForPharmacistOneThirdScreen(patientName: NSString, nhsNumber : NSString, dateOfBirth : NSDate, age: NSString) {
        
        let dateFormatter : NSDateFormatter = NSDateFormatter.init()
        dateFormatter.dateFormat = BIRTH_DATE_FORMAT
        patientNameLabelTopSpaceConstraint.constant = 8.0
        let dobDateString = dateFormatter.stringFromDate(dateOfBirth)
        patientNameLabel.text = patientName as String
        if #available(iOS 8.2, *) {
            patientNameLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightMedium)
        } else {
            // Fallback on earlier versions
        }
        nhsLabel.text = EMPTY_STRING as String
        dobLabel.text = String(format: "\(dobDateString as String) (\(age as String) years) | \(nhsNumber as String)")
        dobLabel.font = UIFont.systemFontOfSize(12)
    }
}
