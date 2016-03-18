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
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
    
    func calculateWeekViewSlotWidth () {
        //TODO: medication administration slots have to be made constant width , medication details flexible width
        let medicationDetailTableWidth = DCUtility.mainWindowSize().width * 0.30
        // here width has to be changed.
        if (appDelegate.windowState == DCWindowState.fullWindow) {
            
            weekViewWidth = (DCUtility.mainWindowSize().width - medicationDetailTableWidth)/5
        }
        else {
            weekViewWidth = (DCUtility.mainWindowSize().width - medicationDetailTableWidth)/3
        }
    }
    
    func populateViewForDateArray(dateArray : NSArray) {
        
        self.dateArray = dateArray
        self.showDatesInView(dateArray)
    }

    // To arrange the date views in the view to show a week
    
    func showDatesInView( dateArray : NSArray ) {
        
        calculateWeekViewSlotWidth()
        var counterLimit : NSInteger = 2
        if (appDelegate.windowState == DCWindowState.fullWindow) {
            counterLimit = 4
        }
        
        for index in 0...counterLimit {
            let dateX : CGFloat = CGFloat(index) * weekViewWidth + CGFloat(index) + 1
            let frame : CGRect = CGRectMake(dateX, 0, weekViewWidth, 49)
            if (self.viewWithTag(index + 1) != nil) {
                let dateView = self.viewWithTag(index + 1) as! DCDateView
                dateView.removeFromSuperview()
            }
            let dateView : DCDateView = DCDateView(frame: frame, date: dateArray[index] as! NSString)
            dateView.tag = index+1
            self.addSubview(dateView)
            if (index == 0) {
                //This is added since the current week separation is not shown
                let borderView : UIView = UIView.init(frame: CGRectMake(-0.9, 0, 1, 49))
                borderView.backgroundColor = UIColor(forHexString: "#efeff4")
                dateView.addSubview(borderView)
            }
        }
    }
}