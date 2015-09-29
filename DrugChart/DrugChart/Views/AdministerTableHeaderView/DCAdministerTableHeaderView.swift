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
    
    func populateScheduledTimeValue(time : NSDate) {
        
        timeLabel.text = DCDateUtility.convertDate(time, fromFormat: DEFAULT_DATE_FORMAT, toFormat: TWENTYFOUR_HOUR_FORMAT);
    }

}
