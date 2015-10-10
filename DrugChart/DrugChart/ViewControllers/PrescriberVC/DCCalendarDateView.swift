//
//  DCCalendarDateView.swift
//  DrugChart
//
//  Created by aliya on 01/10/15.
//
//

import Foundation
import UIKit

@objc class DCCalendarDateView : UIView {
    var dateArray : NSArray = NSArray()
    var weekViewWidth: CGFloat = 0.0
    
    init(frame: CGRect,dateArray : NSArray ) {
        
        super.init(frame: frame)
        self.frame = frame
        self.dateArray = dateArray
        self.setDatesInView( dateArray)

    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
    }
    
    func calculateWeekViewSlotWidth () {
        
        weekViewWidth = (DCUtility.getMainWindowSize().width - 300)/5
    }

    func setDatesInView( dateArray : NSArray ) {
        
        calculateWeekViewSlotWidth()
        for index in 0...4 {
            
            let dateX : CGFloat = CGFloat(index) * weekViewWidth
            let frame : CGRect = CGRectMake(dateX, 0, weekViewWidth, 50)
            NSLog("WeekView: index : %d dateX : %f", index, dateX)
            let dateView : DCDateView = DCDateView(frame: frame, date: dateArray[index] as! NSString)
            self.addSubview(dateView)
        }
    }
}