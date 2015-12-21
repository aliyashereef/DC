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
        
        messageLabel.text = DCSchedulingHelper.scheduleDescriptionForReapeatValue(repeatValue) as String
        messageLabel.sizeToFit()
    }
    
    func populateMessageLabelForIntervalValue(intervalValue : DCInterval) {
        
        messageLabel.text = DCSchedulingHelper.scheduleDescriptionForIntervalValue(intervalValue) as String
        messageLabel.sizeToFit()
    }
}
