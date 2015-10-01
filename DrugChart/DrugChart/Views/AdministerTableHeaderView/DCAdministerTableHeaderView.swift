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
    @IBOutlet weak var timeIconImageView: UIImageView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    func populateScheduledTimeValue(time : NSDate) {
        
        timeIconImageView.hidden = false
        timeLabel.hidden = false
        errorMessageLabel.hidden = true
        timeLabel.text = DCDateUtility.convertDate(time, fromFormat: DEFAULT_DATE_FORMAT, toFormat: TWENTYFOUR_HOUR_FORMAT);
    }
    
    func populateHeaderViewWithErrorMessage(alertMessage : String) {
        
        timeIconImageView.hidden = true
        timeLabel.hidden = true
        errorMessageLabel.hidden = false
        errorMessageLabel.text = alertMessage
        
    }

}
