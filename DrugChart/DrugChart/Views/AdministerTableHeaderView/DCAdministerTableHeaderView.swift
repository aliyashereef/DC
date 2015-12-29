//
//  DCAdministerTableHeaderView.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/23/15.
//
//

import UIKit

class DCAdministerTableHeaderView: UIView {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    func populateScheduledTimeValue(time : NSDate) {
        
        timeLabel.hidden = false
        errorMessageLabel.hidden = true
        timeLabel.text = DCDateUtility.dateStringFromDate(time, inFormat: TWENTYFOUR_HOUR_FORMAT)
    }
    
    func populateHeaderViewWithErrorMessage(alertMessage : String) {
        
        timeLabel.hidden = true
        errorMessageLabel.hidden = false
        errorMessageLabel.text = alertMessage
    }

}
