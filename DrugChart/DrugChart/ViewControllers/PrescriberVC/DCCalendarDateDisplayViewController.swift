//
//  DCCalendarDateDisplayViewController.swift
//  DrugChart
//
//  Created by aliya on 01/10/15.
//
//

import Foundation
import UIKit

@objc class DCCalendarDateDisplayViewController: UIViewController {
    
    var currentWeekDateArray : NSMutableArray?
    var lastDateForCurrentWeek : NSDate?
    var firstDateForCurrentWeek : NSDate?
    
    let currentDate : NSDate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareDateArrays()
    }
    
    func prepareDateArrays() {
        
        let currentWeekDateArray : NSMutableArray = getCurrentWeek()
        let previousWeekDateArray : NSMutableArray = getPreviousWeek()
        let nextWeekDateArray : NSMutableArray = getNextWeek()
        let datePackArray : Array = [previousWeekDateArray,currentWeekDateArray,nextWeekDateArray]
        setDatesDisplayInView(datePackArray)
    }
    
    func getPreviousWeek() -> NSMutableArray {
        let dates : NSMutableArray = []
        for index in (1...5).reverse() {
            let timeInterval : NSTimeInterval = Double(60*60*24*index)
            let nextDate : NSDate = firstDateForCurrentWeek!.dateByAddingTimeInterval(-timeInterval)
            dates.addObject(convertDateToString(nextDate))
        }
        return dates
    }
    
    func getNextWeek() -> NSMutableArray{
        let dates : NSMutableArray = []
        for index : Int in 1...5 {
            let timeInterval : NSTimeInterval = Double(60*60*24*index)
            let nextDate : NSDate = lastDateForCurrentWeek!.dateByAddingTimeInterval(timeInterval)
            dates.addObject(convertDateToString(nextDate))
        }
        return dates
    }
    
    func getCurrentWeek() -> NSMutableArray {
        
        let dates : NSMutableArray = []
        for index in (1...2).reverse() {
            let timeInterval : NSTimeInterval = Double(60*60*24*index)
            let nextDate : NSDate = currentDate.dateByAddingTimeInterval(-timeInterval)
            dates.addObject(convertDateToString(nextDate))
            if index == 2 {
                firstDateForCurrentWeek = nextDate
            }
        }
        dates.addObject(convertDateToString(currentDate))
        for index : Int in 1...2 {
            let timeInterval : NSTimeInterval = Double(60*60*24*index)
            let nextDate : NSDate = currentDate.dateByAddingTimeInterval(timeInterval)
            dates.addObject(convertDateToString(nextDate))
            if index == 2 {
                lastDateForCurrentWeek = nextDate
            }
        }
        return dates
    }
    
    func convertDateToString (date:NSDate) -> NSString {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE dd"
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
    
    func setDatesDisplayInView( datePackArray : [NSArray] ) {
        
        for index in 0...2 {
            
            let dateViewX : CGFloat = CGFloat(index-1) * 724.0
            let frame : CGRect = CGRectMake(dateViewX,0,724,49.5)
            let dateDisplay : DCCalendarDateView = DCCalendarDateView(frame: frame, dateArray: datePackArray[index])
            self.view.addSubview(dateDisplay)
        }
    }

}