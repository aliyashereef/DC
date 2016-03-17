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
    
    let currentDate : NSDate = NSDate()
    let dateViewFormat : NSString = "EEE d"
    let dateFormat : NSString = "dd MMM yyyy"
    var windowSizeChanged = false
    //MARK: View Management Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.adjustHolderFrameAndDisplayDates()
        self.displayDatesInView()
    }
    
    
    //MARK: View translation Methods
    
    func translateCalendarContainerViewsForTranslationParameters(xTranslation: CGFloat, withXVelocity xVelocity:CGFloat, panEndedValue panEnded:Bool) {
        
        let calendarWidth : CGFloat = (DCUtility.mainWindowSize().width - DCUtility.mainWindowSize().width * 0.30);
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
            let calendarWidth : CGFloat = (DCUtility.mainWindowSize().width - DCUtility.mainWindowSize().width * 0.30);
            if (self.calendarViewLeadingConstraint.constant >= DCUtility.mainWindowSize().width * 0.30) {
                self.calendarViewLeadingConstraint.constant = calendarWidth
            }
            self.view.layoutIfNeeded()
            }) { (Bool) -> Void in
                self.calendarViewLeadingConstraint.constant = 0.0
        }
    }
    
    func displayNextWeekDatesInCalendar() {
        UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
            let calendarWidth : CGFloat = (DCUtility.mainWindowSize().width - DCUtility.mainWindowSize().width * 0.30);
            if (self.calendarViewLeadingConstraint.constant <= -DCUtility.mainWindowSize().width * 0.30) {
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
        
        calendarViewWidthConstraint.constant = (DCUtility.mainWindowSize().width - DCUtility.mainWindowSize().width * 0.30);
    }

    // Populate the dates for the previous and next date views
    func displayDatesInView () {
        self.adjustHolderFrameAndDisplayDates()
        let displayDatesArray = displayWeekDatesArray()
        var index : NSInteger = 0
        let leftDatesArray : NSMutableArray = []
        let centerDatesArray : NSMutableArray = []
        let rightDatesArray : NSMutableArray = []
        let calendarStripDaysCount = (appDelegate.windowState == DCWindowState.fullWindow) ? 5:3
        
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
        leftCalendarView .populateViewForDateArray(leftDatesArray)
        centerCalendarView.populateViewForDateArray(centerDatesArray)
        rightCalendarView.populateViewForDateArray(rightDatesArray)
    }

}