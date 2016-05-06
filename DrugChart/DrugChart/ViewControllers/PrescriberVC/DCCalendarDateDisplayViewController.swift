//
//  DCCalendarDateDisplayViewController.swift
//  DrugChart
//
//  Created by aliya on 01/10/15.
//
//

import Foundation
import UIKit
import CocoaLumberjack

@objc class DCCalendarDateDisplayViewController: DCBaseViewController {
    
    @IBOutlet weak var leftCalendarView: DCCalendarDateView!
    @IBOutlet weak var centerCalendarView: DCCalendarDateView!
    @IBOutlet weak var rightCalendarView: DCCalendarDateView!
    @IBOutlet weak var calendarViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarViewWidthConstraint: NSLayoutConstraint!
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate

    var currentWeekDateArray : NSMutableArray?
    var lastDateForCurrentWeek : NSDate?
    var firstDateForCurrentWeek : NSDate?
    
    var calendarViewWidth : CGFloat = 0.0
    let currentDate : NSDate = NSDate()
    let dateViewFormat : NSString = "EEE d"
    let dateFormat : NSString = "dd MMM yyyy"
    var windowSizeChanged = false
    //MARK: View Management Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        calendarViewWidth = (appDelegate.windowState == DCWindowState.fullWindow) ? CGFloat(CALENDAR_FULL_WINDOW_WIDTH): CGFloat(CALENDAR_TWO_THIRD_WINDOW_WIDTH)
        self.adjustHolderFrameAndDisplayDates()
        self.displayDatesInView()
    }
    
    
    //MARK: View translation Methods
    
    func translateCalendarContainerViewsForTranslationParameters(xTranslation: CGFloat, withXVelocity xVelocity:CGFloat, panEndedValue panEnded:Bool) {
        // medication administration slots have to be made constant width , medication details flexible width

        let valueToTranslate = (calendarViewLeadingConstraint.constant + xTranslation);
        if (valueToTranslate >= -calendarViewWidth && valueToTranslate <= calendarViewWidth) {
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
            //medication administration slots have to be made constant width , medication details flexible width
            let calendarWidth : CGFloat = (DCUtility.mainWindowSize().width - self.calendarViewWidth);
            if (self.calendarViewLeadingConstraint.constant >= calendarWidth) {
                self.calendarViewLeadingConstraint.constant = self.calendarViewWidth
            }
            self.view.layoutIfNeeded()
            }) { (Bool) -> Void in
                self.calendarViewLeadingConstraint.constant = 0.0
        }
    }
    
    func displayNextWeekDatesInCalendar() {
        UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
            //medication administration slots have to be made constant width , medication details flexible width
            let calendarWidth : CGFloat = (DCUtility.mainWindowSize().width - self.calendarViewWidth);
            if (self.calendarViewLeadingConstraint.constant <= -calendarWidth) {
                self.calendarViewLeadingConstraint.constant = -self.calendarViewWidth
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
            let displayDate = DCDateUtility.dateStringFromDate(date, inFormat:dateFormat as String)
            displayDatesArray .addObject(displayDate)
        }
        return displayDatesArray
    }
    
    // Returns the date container width
    
    func dateContainerViewWidth () -> (CGFloat) {
        
        return DCUtility.mainWindowSize().width
    }
    
    func adjustHolderFrameAndDisplayDates () {
        
        //medication administration slots have to be made constant width , medication details flexible width
        calendarViewWidthConstraint.constant = calendarViewWidth;
    }

    // Populate the dates for the previous and next date views
    func displayDatesInView () {
        
        self.adjustHolderFrameAndDisplayDates()
        let displayDatesArray = displayWeekDatesArray()
        var index : NSInteger = 0
        let leftDatesArray : NSMutableArray = []
        let centerDatesArray : NSMutableArray = []
        let rightDatesArray : NSMutableArray = []
        let calendarStripDaysCount = (appDelegate.windowState == DCWindowState.fullWindow) ? 4:2
        for ( index = 0; index < displayDatesArray.count; index++) {
            if (index < calendarStripDaysCount) {
                leftDatesArray.addObject(displayDatesArray.objectAtIndex(index))
            }
            else if (index >= calendarStripDaysCount && index < 2 * calendarStripDaysCount) {
                centerDatesArray.addObject(displayDatesArray.objectAtIndex(index))
            }
            else if (index >= 2 * calendarStripDaysCount && index < 3 * calendarStripDaysCount) {
                rightDatesArray.addObject(displayDatesArray.objectAtIndex(index))
            }
        }
        DDLogDebug("\(centerCalendarView.backgroundColor)")
        leftCalendarView.weekViewWidth = calculateWeekViewSlotWidth()
        leftCalendarView .populateViewForDateArray(leftDatesArray)
        centerCalendarView.weekViewWidth = calculateWeekViewSlotWidth()
        centerCalendarView.populateViewForDateArray(centerDatesArray)
        rightCalendarView.weekViewWidth = calculateWeekViewSlotWidth()
        rightCalendarView.populateViewForDateArray(rightDatesArray)
    }
    
    func calculateWeekViewSlotWidth () -> CGFloat {
        
        // medication administration slots have to be made constant width , medication details flexible width
        let weekViewWidth : CGFloat!
        if (appDelegate.windowState == DCWindowState.fullWindow) {
            weekViewWidth = (calendarViewWidth)/DCCalendarConstants.FULL_SCREEN_DAYS_COUNT
        } else {
            weekViewWidth = (calendarViewWidth)/DCCalendarConstants.TWO_THIRD_SCREEN_DAYS_COUNT
        }
        return weekViewWidth
    }
}