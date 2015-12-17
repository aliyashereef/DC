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
    case .Week:
        let calendar1 = NSCalendar.currentCalendar()
        let noOfDays = calendar1.components([.Day], fromDate: startDate, toDate: self, options: [])
        return noOfDays.day * 24 * 60 + chosenDateComponents.hour * 60 + chosenDateComponents.minute ;
    case .Day:
        return chosenDateComponents.hour * 60 + chosenDateComponents.minute ;
    default:
        return 1;
    }
}
    func getFormattedDate() -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.stringFromDate(self)
    }
    
    func getFormattedDateTime() -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy h:mm a"
        return formatter.stringFromDate(self)
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