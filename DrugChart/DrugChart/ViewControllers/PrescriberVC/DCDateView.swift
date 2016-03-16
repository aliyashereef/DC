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
    var indicatorImageView : UIImageView = UIImageView()
    let dateViewFormat : NSString = "EEE d"
    let dayViewFormat : NSString = "d"
    let weekDayViewFormat : NSString = "EEE   '...'"
    let dateFormat : NSString = "dd MMM yyyy"


     init(frame: CGRect, date : NSString) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        self.setDate(date)
    }

    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
    }
    
    func setDate( date : NSString ) {
        
        dateLabel.frame = CGRectMake(0, 0, self.frame.width, 49)
        dateLabel.center = CGPointMake(self.frame.width/2, 49/2)
        dateLabel.backgroundColor = UIColor.clearColor()
        dateLabel.font = UIFont.systemFontOfSize(17)
        dateLabel.textAlignment = .Center
        self.addSubview(dateLabel)
        let today : NSDate = NSDate()
        
        if date == convertDateToString(today, format: dateFormat as String) {
            dateLabel.text = convertDateToString(today, format: weekDayViewFormat as String) as String
            addTodayIndicator ()
            self.backgroundColor = UIColor(forHexString: "#fafafa")
        } else {
            dateLabel.text = convertDateToString(DCDateUtility.dateFromSourceString(date as String), format: dateViewFormat as String) as String
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
        dateFormatter.dateFormat = dayViewFormat as String
        let dateString = dateFormatter.stringFromDate(today)
        indicatorImageView.frame = CGRectMake(self.frame.width/2 + 7, 12.0, 28, 28)
        indicatorImageView.image = UIImage(named: "CurrentDateBlueRound")
        self.addSubview(indicatorImageView)
        indicatorLabel.frame = CGRectMake(self.frame.width/2 + 7, 12.0, 28, 28)
        indicatorLabel.font = UIFont.systemFontOfSize(17)
        indicatorLabel.textAlignment = .Center
        indicatorLabel.textColor = UIColor.whiteColor()
        indicatorLabel.text = dateString
        self.addSubview(indicatorLabel)
    }
}
