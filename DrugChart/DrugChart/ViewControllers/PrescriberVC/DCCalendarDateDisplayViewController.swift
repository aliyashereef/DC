//
//  DCCalendarDateDisplayViewController.swift
//  DrugChart
//
//  Created by aliya on 01/10/15.
//
//

import Foundation
import UIKit

@objc class DCCalendarDateDisplayViewController: DCBaseViewController {
    
    @IBOutlet weak var leftCalendarView: DCCalendarDateView!
    @IBOutlet weak var centerCalendarView: DCCalendarDateView!
    @IBOutlet weak var rightCalendarView: DCCalendarDateView!
    @IBOutlet weak var calendarViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarViewWidthConstraint: NSLayoutConstraint!

    var currentWeekDateArray : NSMutableArray?
    var lastDateForCurrentWeek : NSDate?
    var firstDateForCurrentWeek : NSDate?
    
    let currentDate : NSDate = NSDate()
    let dateViewFormat : NSString = "EEE d"
    //MARK: View Management Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        calendarViewWidthConstraint.constant = (DCUtility.mainWindowSize().width - MEDICATION_VIEW_WIDTH);
        displayWeekDatesArray()
        self.displayDatesInView()
    }
    
    //MARK: View translation Methods
    
    func translateCalendarContainerViewsForTranslationParameters(xTranslation: CGFloat, withXVelocity xVelocity:CGFloat, panEndedValue panEnded:Bool) {
        
        let calendarWidth : CGFloat = (DCUtility.mainWindowSize().width - MEDICATION_VIEW_WIDTH);
        let valueToTranslate = (calendarViewLeadingConstraint.constant + xTranslation);
        if (valueToTranslate >= -calendarWidth && valueToTranslate <= calendarWidth) {
            calendarViewLeadingConstraint.constant = calendarViewLeadingConstraint.constant + xTranslation;
        }
        if (panEnded == true) {
            if (xVelocity > 0) {
                // animate to left. show previous week
                displayPreviousWeekDatesInCalendar()
            } else {
                //show next week
                displayNextWeekDatesInCalendar()
            }
        }
     }
    
    func todayActionForCalendarTop () {
        
        UIView.animateWithDuration(0.1) { () -> Void in
            self.calendarViewLeadingConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK :Next, Previous and Today actions
    
    func displayPreviousWeekDatesInCalendar() {
        
        UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
            let calendarWidth : CGFloat = (DCUtility.mainWindowSize().width - MEDICATION_VIEW_WIDTH);
            if (self.calendarViewLeadingConstraint.constant >= MEDICATION_VIEW_WIDTH) {
                self.calendarViewLeadingConstraint.constant = calendarWidth
            }
            self.view.layoutIfNeeded()
            }) { (Bool) -> Void in
                self.calendarViewLeadingConstraint.constant = 0.0
        }
    }
    
    func displayNextWeekDatesInCalendar() {
        UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
            let calendarWidth : CGFloat = (DCUtility.mainWindowSize().width - MEDICATION_VIEW_WIDTH);
            if (self.calendarViewLeadingConstraint.constant <= -MEDICATION_VIEW_WIDTH) {
                self.calendarViewLeadingConstraint.constant = -calendarWidth
            }
            self.view.layoutIfNeeded()
            }) { (Bool) -> Void in
                self.calendarViewLeadingConstraint.constant = 0.0
        }
    }


    func displayWeekDatesArray() -> NSMutableArray {
        
        var index : NSInteger = 0
        let displayDatesArray = NSMutableArray()
        for ( index = 0; index < currentWeekDateArray!.count; index++) {
            let date = currentWeekDateArray?.objectAtIndex(index) as! NSDate
            let displayDate = convertDateToString(date)
            displayDatesArray .addObject(displayDate)
        }
        return displayDatesArray
    }
    
    func convertDateToString (date:NSDate) -> NSString {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateViewFormat as String
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
    
    // Returns the date container width
    
    func dateContainerViewWidth () -> (CGFloat) {
        
        return DCUtility.mainWindowSize().width
    }

    // Populate the dates for the previous and next date views
    func displayDatesInView () {
        
        let displayDatesArray = displayWeekDatesArray()
        var index : NSInteger = 0
        let leftDatesArray : NSMutableArray = []
        let centerDatesArray : NSMutableArray = []
        let rightDatesArray : NSMutableArray = []
        
        for ( index = 0; index < displayDatesArray.count; index++) {
            if (index < 5) {
                leftDatesArray.addObject(displayDatesArray.objectAtIndex(index))
            }
            else if (index >= 5 && index < 10) {
                centerDatesArray.addObject(displayDatesArray.objectAtIndex(index))
            }
            else if (index >= 10 && index < 15) {
                rightDatesArray.addObject(displayDatesArray.objectAtIndex(index))
            }
        }
        leftCalendarView .populateViewForDateArray(leftDatesArray)
        centerCalendarView.populateViewForDateArray(centerDatesArray)
        rightCalendarView.populateViewForDateArray(rightDatesArray)
    }

}