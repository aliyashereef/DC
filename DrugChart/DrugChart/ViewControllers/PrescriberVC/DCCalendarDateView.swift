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
    
    init(frame: CGRect,dateArray : NSArray ) {
        super.init(frame: frame)
        self.frame = frame
        self.dateArray = dateArray
        self.setDatesInView( dateArray)

    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setDatesInView( dateArray : NSArray ) {
        for index in 0...4 {
            
            let dateX : CGFloat = CGFloat(index) * 145.0
            let frame : CGRect = CGRectMake(dateX, 0, 145, 50)
            let dateView : DCDateView = DCDateView(frame: frame, date: dateArray[index] as! NSString)
            self.addSubview(dateView)
        }
    }
}