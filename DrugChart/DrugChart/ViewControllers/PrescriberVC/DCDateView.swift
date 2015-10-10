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
        dateLabel.frame = CGRectMake(0,0, 144, 50)
        //dateLabel.backgroundColor = UIColor.whiteColor()
        dateLabel.font = UIFont.systemFontOfSize(17)
        dateLabel.textAlignment = .Center
        dateLabel.text = date as String
        self.addSubview(dateLabel)
        let today : NSDate = NSDate()
        if date == convertDateToString(today) {
            addTodayIndicator ()
        }
    }
    
    func convertDateToString (date:NSDate) -> NSString {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE d"
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
    func addTodayIndicator() {
        let today : NSDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "d"
        let dateString = dateFormatter.stringFromDate(today)
        
        indicatorLabel.frame = CGRectMake(79,12.0, 25, 25)
        indicatorLabel.font = UIFont.systemFontOfSize(17)
        indicatorLabel.textAlignment = .Center
        indicatorLabel.textColor = UIColor.whiteColor()
        indicatorLabel.text = dateString
        indicatorLabel.backgroundColor = UIColor.blueColor()
        indicatorLabel.layer.cornerRadius = 12.5
        indicatorLabel.layer.masksToBounds = true
        self.addSubview(indicatorLabel)
    }

}
