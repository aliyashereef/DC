//
//  DCDateView.swift
//  DrugChart
//
//  Created by aliya on 01/10/15.
//
//

import Foundation
import UIKit
import QuartzCore

@objc class DCDateView : UIView {
    
    var dateLabel: UILabel = UILabel()
    var indicatorLabel: UILabel = UILabel()

     init(frame: CGRect, date : NSString) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        self.setDate(date)
    }

    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
    }
    
    func setDate( date : NSString ) {
        
        dateLabel.frame = CGRectMake(0, 0, 144, 49)
        dateLabel.backgroundColor = UIColor.clearColor()
        dateLabel.font = UIFont.systemFontOfSize(17)
        dateLabel.textAlignment = .Center
        self.addSubview(dateLabel)
        let today : NSDate = NSDate()
        if date == convertDateToString(today, format: "EEE d") {
            dateLabel.text = convertDateToString(today, format: "EEE ") as String
            addTodayIndicator ()
            self.backgroundColor = UIColor.getColorForHexString("#fafafa")
        } else {
            dateLabel.text = date as String
        }
    }
    
    func convertDateToString (date : NSDate, format : String) -> NSString {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
    
    func addTodayIndicator() {
        
        let today : NSDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "d"
        let dateString = dateFormatter.stringFromDate(today)
        indicatorLabel.frame = CGRectMake(88,12.0, 25, 25)
        indicatorLabel.font = UIFont.systemFontOfSize(17)
        indicatorLabel.textAlignment = .Center
        indicatorLabel.textColor = UIColor.whiteColor()
        indicatorLabel.text = dateString
        indicatorLabel.backgroundColor = UIColor.getColorForHexString("#007aff")
        indicatorLabel.layer.cornerRadius = 12.5
        indicatorLabel.layer.masksToBounds = true
        self.addSubview(indicatorLabel)
    }
}
