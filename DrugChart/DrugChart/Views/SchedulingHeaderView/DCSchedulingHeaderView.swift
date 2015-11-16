//
//  DCSchedulingHeaderView.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 11/16/15.
//
//

import UIKit

class DCSchedulingHeaderView: UIView {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    func populateMessageLabelWithRepeatValue(repeatValue : DCRepeat) {
        
        NSLog("*** Repeat Type is %@", repeatValue.repeatType)
        NSLog("** Repeat Frequency is %@", repeatValue.frequency)
        if (repeatValue.frequency == "1 day") {
            messageLabel.text = NSString(format: "%@ day.", NSLocalizedString("DAILY_DESCRIPTION", comment: "")) as String
        } else {
            messageLabel.text = NSString(format: "Medication will be administered every %@", repeatValue.frequency) as String
        }
    }
}
