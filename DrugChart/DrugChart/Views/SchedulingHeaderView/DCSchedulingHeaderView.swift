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
    
    func populateMessageLabelWithSpecificTimesRepeatValue(repeatValue : DCRepeat, administratingTimes times : NSArray) {
        
        messageLabel.text = DCSchedulingHelper.scheduleDescriptionForSpecificTimesRepeatValue(repeatValue, administratingTimes: times) as String
        messageLabel.sizeToFit()
    }
    
    func populateMessageLabelForIntervalValue(intervalValue : DCInterval) {
        
        messageLabel.text = DCSchedulingHelper.scheduleDescriptionForIntervalValue(intervalValue) as String
        messageLabel.sizeToFit()
    }
}
