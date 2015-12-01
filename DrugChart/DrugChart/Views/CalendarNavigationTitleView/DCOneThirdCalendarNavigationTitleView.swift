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
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var nhsLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func populateViewWithPatientName(patientName: NSString , nhsNumber : NSString , dateOfBirth : NSDate , age: NSString) {
        let dateFormatter : NSDateFormatter = NSDateFormatter.init()
        dateFormatter.dateFormat = BIRTH_DATE_FORMAT
        let dobDateString = dateFormatter.stringFromDate(dateOfBirth)
        patientNameLabel.text = patientName as String
        dobLabel.text = String(format: "\(dobDateString as String) (\(age as String) years)")
        nhsLabel.text = nhsNumber as String
    }
}
