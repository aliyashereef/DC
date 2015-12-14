//
//  NSDate.swift
//  DrugChart
//
//  Created by Noureen on 11/12/2015.
//
//

import Foundation
import UIKit

extension NSDate {
    func getDatePart(displayView:GraphDisplayView) ->Int
{
    let calendar = NSCalendar.currentCalendar()
    let chosenDateComponents = calendar.components([.Hour , .Minute,.Day, .Month , .Year], fromDate: self)
    return chosenDateComponents.hour * 60 + chosenDateComponents.minute ;
    
    //    switch(displayView)
//    {
//        case GraphDisplayView.Day:
//            return chosenDateComponents.hour * 60 + chosenDateComponents.minute ;
//    }
}
    
}