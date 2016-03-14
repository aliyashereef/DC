//
//  NSDate.swift
//  DrugChart
//
//  Created by Noureen on 11/12/2015.
//
//

import Foundation
import UIKit

public func <(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == NSComparisonResult.OrderedAscending
}

public func ==(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == NSComparisonResult.OrderedSame
}
extension NSDate:Comparable{
    
    func getDatePart(displayView:GraphDisplayView,startDate:NSDate) ->Int
{
    
    let calendar = NSCalendar.currentCalendar()
    let chosenDateComponents = calendar.components([.Hour , .Minute,.Day, .Month , .Year], fromDate: self)
    switch(displayView)
    {
    case .Day:
        return chosenDateComponents.hour * 60 + chosenDateComponents.minute ;
    case .Week:
        return startDate.getNoofDays(self) * 24 * 60 + chosenDateComponents.hour * 60 + chosenDateComponents.minute ;
    case .Month:
        return startDate.getNoofDays(self) * 24 * 60 + chosenDateComponents.hour * 60 + chosenDateComponents.minute 
    }
}
    
    func getFormattedDay() -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd"
        return formatter.stringFromDate(self)
    }
    func getFormatedDayandMonth() ->String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.stringFromDate(self)
    }
    func getNoofDays(endDate:NSDate) ->Int
    {
        let calendar = NSCalendar.currentCalendar()
        let noOfDays = calendar.components([.Day], fromDate: self, toDate: endDate, options: [])
        return noOfDays.day
    }
    func getFormattedDate() -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.stringFromDate(self)
    }
    
    func getFHIRDateandTime()->String
    {
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date:NSMutableString = NSMutableString()
        date.appendString(formatter.stringFromDate(self))
        date.insertString(":", atIndex: date.length - 2)
        return date as String
    }
    
    func getFormattedDateTime() -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMM yyyy h:mm a"
        return formatter.stringFromDate(self)
    }
    
    func getFormattedMonthandYear() -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM/yyyy"
        return formatter.stringFromDate(self)
    }
    
    func getFormattedTime() ->String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.stringFromDate(self)
    }
    
    func getFormattedDayoftheWeek() -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.stringFromDate(self)
    }
    func getFormattedMonthName() ->String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.stringFromDate(self)
    }
    func getFormattedYear() ->String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.stringFromDate(self)
    }
    
    func isToday() ->Bool
    {
        let today : NSDate = NSDate()
        let order = NSCalendar.currentCalendar().compareDate(self , toDate:today,
            toUnitGranularity: .Day)
        if order == NSComparisonResult.OrderedSame {
            return true
        } else {
            return false
        }
    }
    func minDayofMonth() -> NSDate // return with min time as well
    {
        let calendar = NSCalendar.currentCalendar()
        let chosenDateComponents = calendar.components([.Hour , .Minute,.Day, .Month , .Year , .Second], fromDate: self)
        chosenDateComponents.hour = 0
        chosenDateComponents.minute = 0
        chosenDateComponents.second = 0
        chosenDateComponents.day = 1
        return  calendar.dateFromComponents(chosenDateComponents)!
    }
    func maxDayofMonth() ->NSDate
    {
        let minDate = self.minDayofMonth()
        
        let range = NSCalendar.currentCalendar().rangeOfUnit(.Day, inUnit: .Month, forDate: minDate)
        
        let endDate =  NSCalendar.currentCalendar().dateByAddingUnit(.Day,
            value: range.length - 1,
            toDate:minDate ,
            options: NSCalendarOptions(rawValue: 0))!
        return endDate.maxTime()
    }
    
    func minTime() -> NSDate
    {
        let calendar = NSCalendar.currentCalendar()
        let chosenDateComponents = calendar.components([.Hour , .Minute,.Day, .Month , .Year , .Second], fromDate: self)
        chosenDateComponents.hour = 0
        chosenDateComponents.minute = 0
        chosenDateComponents.second = 0
        return  calendar.dateFromComponents(chosenDateComponents)!
    }
    
    func maxTime() -> NSDate
    {
        let calendar = NSCalendar.currentCalendar()
        let chosenDateComponents = calendar.components([.Hour , .Minute,.Day, .Month , .Year , .Second], fromDate: self)
        chosenDateComponents.hour = 23
        chosenDateComponents.minute = 59
        chosenDateComponents.second = 59
        return  calendar.dateFromComponents(chosenDateComponents)!
    }
}