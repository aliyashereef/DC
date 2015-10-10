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
    
    
    @IBOutlet weak var leftCalendarView: DCCalendarDateView!
    @IBOutlet weak var centerCalendarView: DCCalendarDateView!
    @IBOutlet weak var rightCalendarView: DCCalendarDateView!
    @IBOutlet weak var calendarViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarViewWidthConstraint: NSLayoutConstraint!

    
    var currentWeekDateArray : NSMutableArray?
    var lastDateForCurrentWeek : NSDate?
    var firstDateForCurrentWeek : NSDate?
    
    let currentDate : NSDate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarViewWidthConstraint.constant = (DCUtility.getMainWindowSize().width - MEDICATION_VIEW_WIDTH);
        prepareDateArrays()
    }
    
    func translateCalendarContainerViewsForTranslationParameters(xTranslation: CGFloat, withXVelocity xVelocity:CGFloat, panEndedValue panEnded:Bool) {
        
        NSLog("***** xTranslation : %f", xTranslation)
        NSLog("**** xVelocity : %f", xVelocity)
        NSLog("**** panEnded : %f", panEnded.boolValue)
        
        
        let calendarWidth : CGFloat = (DCUtility.getMainWindowSize().width - MEDICATION_VIEW_WIDTH);
        let valueToTranslate = calendarViewLeadingConstraint.constant + xTranslation;
        if (valueToTranslate >= -calendarWidth && valueToTranslate <= calendarWidth) {
            calendarViewLeadingConstraint.constant = calendarViewLeadingConstraint.constant + xTranslation;
            // self.layoutIfNeeded()
        }
        if (panEnded == true) {
            if (xVelocity > 0) {
                // animate to left. show previous week
                UIView.animateWithDuration(0.05, animations: { () -> Void in
                    if (self.calendarViewLeadingConstraint.constant >= MEDICATION_VIEW_WIDTH) {
                        self.calendarViewLeadingConstraint.constant = calendarWidth
                    } else {
                        //display current week
                        self.calendarViewLeadingConstraint.constant = 0.0
                    }
                    self.view.layoutIfNeeded()
                })
            } else {
                //show next week
                UIView.animateWithDuration(0.05, animations: { () -> Void in
                    if (self.calendarViewLeadingConstraint.constant <= -MEDICATION_VIEW_WIDTH) {
                        self.calendarViewLeadingConstraint.constant = -calendarWidth
                    } else {
                        self.calendarViewLeadingConstraint.constant = 0.0
                    }
                    self.view.layoutIfNeeded()
                })
            }
        }
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
        dateFormatter.dateFormat = "EEE d"
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
    
    func getDateContainerViewWidth () -> (CGFloat) {
        
        return DCUtility.getMainWindowSize().width
    }
    
    func setDatesDisplayInView( datePackArray : [NSArray] ) {
        
        leftCalendarView.dateArray = datePackArray[0]
        leftCalendarView .populateViewForDateArray(datePackArray[0])
        centerCalendarView.populateViewForDateArray(datePackArray[1])
        rightCalendarView.populateViewForDateArray(datePackArray[2])
    }

}