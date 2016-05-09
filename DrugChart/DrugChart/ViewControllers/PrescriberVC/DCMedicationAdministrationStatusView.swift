//
//  DCMedicationAdministrationStatusView.swift
//  DrugChart
//
//  Created by Muhammed Shaheer on 01/10/15.
//
//

import UIKit

let ADMINISTRATION_SUCCESS_IMAGE    =   UIImage(named: "AllAdministered")
let ADMINISTRATION_FAILURE_IMAGE    =   UIImage(named: "AnyFailure")
let ADMINISTRATION_DUE_IMAGE        =   UIImage(named: "DueAt")
let ADMINISTRATION_DUE_NOW_IMAGE    =   UIImage(named: "DueNow")
let ADMINISTRATION_PENDING_IMAGE    =   UIImage(named: "PendingClockImage")

let PENDING_FONT_COLOR              =   UIColor(forHexString: "#acacac")
let DUE_AT_FONT_COLOR               =   UIColor(forHexString: "#007aff")
let OVERDUE_FONT_COLOR              =   UIColor(forHexString: "#ff0000") // get exact color for display
let DUE_NOW_FONT_COLOR              =   UIColor.whiteColor()
let CURRENT_DAY_BACKGROUND_COLOR    =   UIColor(forHexString: "#fafafa")
let INACTIVE_BACKGROUND_COLOR       =   UIColor(forHexString: "#f7f7f7")
let INACTIVE_TEXT_COLOR             =   UIColor(forHexString :"#989797")
let INACTIVE_RED_COLOR              =   UIColor(forHexString: "#e87b7b")
let ACTIVE_TEXT_COLOR               =   UIColor(forHexString :"#737373")
let DUE_NOW_BACKGROUND_COLOR        =   UIColor(forHexString: "#f99e35")
let PENDING_COUNT_FONT_COLOR        =   UIColor(forHexString: "#595959")

let TIME_INTERVAL_LIMIT_BEFORE_DUE_NOW : NSTimeInterval = -60*10
let TIME_INTERVAL_LIMIT_AFTER_DUE_NOW : NSTimeInterval = 60*5


typealias AdministerButtonTappedCallback = (Bool) -> Void

protocol DCMedicationAdministrationStatusProtocol:class {
    
    func administerMedicationWithMedicationSlots (medicationSLotDictionary: NSDictionary, atIndexPath indexPath: NSIndexPath ,withWeekDate date : NSDate)
}

class DCMedicationAdministrationStatusView: UIView {
    
    var medicationSlotDictionary: NSDictionary?
    var currentIndexPath: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    var weekDate : NSDate?
    var timeArray : NSArray = []
    var administerButton: DCAdministerButton?
    var statusIcon : UIImageView?
    var statusLabel : UILabel?
    var medicationCategory : NSString?
    var startDate : NSDate?
    var slotsCount : NSInteger? = 0
    
    var isOneThirdScreen : Bool = false
    var isActive : Bool = true
    var administerButtonCallback: AdministerButtonTappedCallback!
    weak var delegate:DCMedicationAdministrationStatusProtocol?

    var currentSystemDate: NSDate!
    var currentDateString: String!
    var centerPoint: CGPoint!
    var iconCenterForOneThirdScreenDueAtStatus: CGPoint!
    var iconCenterForLeftAlignedDueAtStatusCaseOne: CGPoint!
    var iconCenterForLeftAlignedDueAtStatusCaseTwo: CGPoint!
    var iconCenterForOneThirdScreenDueNowStatus: CGPoint!
    var iconCenterForOneThirdScreenAdministeredStatus: CGPoint!
    var iconCenterForTwoThirdScreenAdministeredStatus: CGPoint!
    var iconCenterForOneThirdScreenNearestSlot: CGPoint!
    var labelCenterForOneThirdScreenDueAtStatus: CGPoint!
    var labelCenterForLeftAlignedDueAtStatus: CGPoint!
    var labelCenterForNotLeftAlignedDueAtStatus: CGPoint!
    var labelCenterForTwoThirdScreenAdministeredStatus: CGPoint!

    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        addViewElements()
        
        
        currentSystemDate = NSDate()
        currentDateString = DCDateUtility.dateStringFromDate(currentSystemDate, inFormat: SHORT_DATE_FORMAT)
        
         // Storing the center points during init, to avoid calculations for each loop of table view row
        centerPoint = CGPointMake(0.5 * self.bounds.size.width, 0.5 * self.bounds.size.height)
        iconCenterForOneThirdScreenDueAtStatus = CGPointMake(self.bounds.size.width/8.2, 0.5 * self.bounds.size.height)
        iconCenterForLeftAlignedDueAtStatusCaseOne = CGPointMake(self.bounds.size.width/7.2, 0.5 * self.bounds.size.height)
        iconCenterForLeftAlignedDueAtStatusCaseTwo = CGPointMake(self.bounds.size.width/6.3, 0.5 * self.bounds.size.height)
        iconCenterForOneThirdScreenDueNowStatus = CGPointMake(self.bounds.size.width/6, 0.5 * self.bounds.size.height)
        iconCenterForOneThirdScreenAdministeredStatus = CGPointMake(self.bounds.size.width/1.13, 0.5 * self.bounds.size.height)
        iconCenterForTwoThirdScreenAdministeredStatus = CGPointMake(self.bounds.size.width/9, 0.5 * self.bounds.size.height)
        iconCenterForOneThirdScreenNearestSlot = CGPointMake(self.bounds.size.width/3.8, 0.5 * self.bounds.size.height)
        labelCenterForOneThirdScreenDueAtStatus = CGPointMake(0.5 * self.bounds.size.width, 0.5 * self.bounds.size.height)
        labelCenterForLeftAlignedDueAtStatus = CGPointMake(self.bounds.size.width/1.3, 0.5 * self.bounds.size.height)
        labelCenterForNotLeftAlignedDueAtStatus = CGPointMake(self.bounds.size.width/1.7, 0.5 * self.bounds.size.height)
        labelCenterForTwoThirdScreenAdministeredStatus = CGPointMake(self.bounds.size.width/1.4, 0.5 * self.bounds.size.height)
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    func addViewElements() {
        
        //add UI elements programmatically
        let contentFrame : CGRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        statusLabel = UILabel.init(frame: contentFrame)
        self.addSubview(statusLabel!)
        statusLabel?.font = statusLabelFont()
        statusLabel?.numberOfLines = 0
        let appDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
        if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow){
            statusIcon = UIImageView.init(frame: CGRectMake(0, 0, 17.5, 17.5))
        } else {
            statusIcon = UIImageView.init(frame: CGRectMake(0, 0, 26, 26))
            self.addSubview(statusIcon!)
        }
        statusIcon!.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        administerButton = DCAdministerButton.init(frame: contentFrame)
        self.addSubview(administerButton!)
        self.sendSubviewToBack(administerButton!)
        administerButton?.addTarget(self, action: #selector(DCMedicationAdministrationStatusView.administerButtonClicked(_:)), forControlEvents: .TouchUpInside)
    }
    
    // Resets the frame and content of view elements, to prevent previous state being maintained while the status view is being reused
    func resetViewElements() {
        
        let contentFrame : CGRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        statusLabel?.frame = contentFrame
        statusLabel?.font = statusLabelFont()
        statusLabel?.numberOfLines = 0
        let appDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
        if (appDelegate.windowState == DCWindowState.oneThirdWindow){
            statusIcon?.frame = CGRectMake(0, 0, 17.5, 17.5)
        } else {
            statusIcon?.frame = CGRectMake(0, 0, 25, 25)
        }
        
        statusIcon?.center = centerPoint
        statusIcon?.hidden = true
        statusLabel?.text = ""
    }
    
    func refreshViewWithUpdatedFrame() {
        
        //include all elements whose frames are to be updated
        let contentFrame : CGRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        administerButton?.frame = contentFrame
        centerPoint = CGPointMake(0.5 * self.bounds.size.width, 0.5 * self.bounds.size.height)
        statusIcon?.center = centerPoint
    }

    func updateAdministrationStatusViewWithMedicationSlotDictionary(slotDictionary : NSDictionary) {
        
        medicationSlotDictionary = slotDictionary.copy() as? NSDictionary
        if let timeSlotsArray  = medicationSlotDictionary?["timeSlots"] {
            slotsCount = timeSlotsArray.count
            if timeSlotsArray.count > 0 {
                configureStatusViewForTimeArray(timeSlotsArray as! [DCMedicationSlot])
            }
        }
    }
    
    func statusLabelFont () -> UIFont {
        
        //update status label font
        let font : UIFont
        if (isOneThirdScreen) {
            font = UIFont.systemFontOfSize(10.0)
        } else {
            font = UIFont.systemFontOfSize(12.0)
        }
        return font
    }
    
    func configureStatusViewForWeekDateAndMedicationStatus(weeksDate : NSDate , isActive : Bool) {
        
        weekDate = weeksDate
        let currentSystemDate : NSDate = NSDate()//DCDateUtility.dateInCurrentTimeZone(NSDate())
        let currentDateString = DCDateUtility.dateStringFromDate(currentSystemDate, inFormat: SHORT_DATE_FORMAT)
        let weekDateString = DCDateUtility.dateStringFromDate(weekDate, inFormat: SHORT_DATE_FORMAT)
        if !isActive {
            self.backgroundColor = INACTIVE_BACKGROUND_COLOR
        } else {
            if (currentDateString == weekDateString && !isOneThirdScreen) {
                self.backgroundColor = CURRENT_DAY_BACKGROUND_COLOR
            } else {
                self.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
    func configureStatusViewForTimeArray(timeSlotsArray : NSArray) {
        
        timeArray = timeSlotsArray
        let initialSlot = timeArray.objectAtIndex(0) as? DCMedicationSlot
//        let currentSystemDate : NSDate = NSDate() //DCDateUtility.dateInCurrentTimeZone(NSDate())
//        let currentDateString = DCDateUtility.dateStringFromDate(currentSystemDate, inFormat: SHORT_DATE_FORMAT)
        let initialSlotDateString = DCDateUtility.dateStringFromDate(initialSlot?.time, inFormat: SHORT_DATE_FORMAT)
        if (currentDateString == initialSlotDateString) {
            // both falls on the same day
            configureStatusViewForToday()
        } else {
            if (initialSlot!.time.compare(currentSystemDate) == NSComparisonResult.OrderedDescending) {
                //next day
                configureStatusViewForComingDay()
            } else if (initialSlot!.time.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
                //previous day
                configureStatusViewForPastDay()
            }
        }
      }
    
    func positionStatusLabelAndIconForDueAtOrNotAdministeredStatus(leftAlign : Bool) {
        
        statusLabel?.hidden = false
        statusIcon?.hidden = false
        if isOneThirdScreen {
//            statusIcon!.center = CGPointMake(self.bounds.size.width/8.2, self.bounds.size.height/2);
//            statusLabel?.center = CGPointMake(self.bounds.size.width/2 - 5, self.bounds.size.height/2);
            statusIcon!.center = iconCenterForOneThirdScreenDueAtStatus
            statusLabel!.center = labelCenterForOneThirdScreenDueAtStatus
        } else {
            statusIcon!.center = CGPointMake(self.bounds.size.width/7.2, self.bounds.size.height/2)
            if leftAlign == true {
                statusLabel?.center = CGPointMake(self.bounds.size.width/1.3, self.bounds.size.height/2);
            } else {
                statusLabel?.center = CGPointMake(self.bounds.size.width/1.7, self.bounds.size.height/2);
            }
        }
      }
    
    func configureStatusViewForToday() {
        
        //populate view for current day, display medication due at initial time
        var overDueCount : NSInteger = 0
        var administeredCount : NSInteger = 0
        var omissionRefusalCount : NSInteger = 0
        let currentSystemDate : NSDate = NSDate()
        for slot in timeArray as [AnyObject] {
            let medication = slot as! DCMedicationSlot
        let timeIntervalFromCurrentTime = medication.time.timeIntervalSinceDate(currentSystemDate)
            if (medication.time.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
                //past time, check if any medication administration is pending
                if (medication.medicationAdministration?.actualAdministrationTime == nil) {
                    if (timeIntervalFromCurrentTime >= TIME_INTERVAL_LIMIT_BEFORE_DUE_NOW && timeIntervalFromCurrentTime <= 0) {
                        // due now status has to shown
                        let dueTime = DCDateUtility.dateStringFromDate(medication.time, inFormat: TWENTYFOUR_HOUR_FORMAT)
                        self.attributedAdministrationStatusTextForScheduledTime(dueTime, inMedicationSlot: medication)
                    } else {
                        overDueCount += 1
                        break;
                    }

                 }
            }
            //check the conditions of early administrations as well
            if (medication.medicationAdministration?.actualAdministrationTime != nil) {
                if (medication.medicationAdministration?.status == ADMINISTERED || medication.medicationAdministration?.status == SELF_ADMINISTERED) {
                    administeredCount += 1
                } else if (medication.medicationAdministration?.status == REFUSED || medication.medicationAdministration?.status == OMITTED) {
                    omissionRefusalCount += 1
                }
            }
        }
        if (overDueCount > 0) {
            //display overdue label here
            displayOverDueLabel()
        } else {
            updateBackgroundColorForCurrentDay()
            updateCurrentDayStatusViewWithAdministrationCount(administrationCount:administeredCount, omittedRefusalCount: omissionRefusalCount)
        }
    }
    
    func updateBackgroundColorForCurrentDay() {
        
        if (!isOneThirdScreen) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if !self.isActive {
                    self.backgroundColor = INACTIVE_BACKGROUND_COLOR
                }
            })
        }
    }
    
    func displayOverDueLabel() {
        
        //configure overdue label
        statusLabel?.hidden = false
        statusLabel?.textColor = OVERDUE_FONT_COLOR
        statusLabel?.font = statusLabelFont()
        statusLabel?.text = NSLocalizedString("OVERDUE", comment: "Some medications are overdue")
        if isOneThirdScreen {
            statusLabel?.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        }
        statusLabel?.textAlignment = isOneThirdScreen ? .Right : .Center
    }
    
    func updateDueNowStatusInView() {
        
        //update due now status in view
        statusLabel?.hidden = false
        statusIcon?.hidden = false
        statusLabel?.font = statusLabelFont()
        statusLabel?.textAlignment = isOneThirdScreen ? .Right : .Center
        if (isOneThirdScreen) {
            statusIcon!.center = CGPointMake(self.bounds.size.width/6, self.bounds.size.height/2);
            statusLabel?.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        } else {
            positionStatusLabelAndIconForDueAtOrNotAdministeredStatus(false)
            statusLabel?.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        }
        statusLabel?.textColor = DUE_NOW_FONT_COLOR
        statusLabel?.text = NSLocalizedString("DUE_NOW", comment: "due now text")
        statusIcon?.hidden = false
        statusIcon?.image = ADMINISTRATION_DUE_NOW_IMAGE
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.backgroundColor = DUE_NOW_BACKGROUND_COLOR
        })
    }
    
    func updateAdministeredOrRejectedStatusForAdministrationCount(administrationCount administeredCount: NSInteger, omittedRefusalCount refusedCount : NSInteger) {
        
        if (administeredCount == timeArray.count) {
            if isOneThirdScreen {
                statusIcon?.center = CGPointMake(self.bounds.size.width/1.18, self.bounds.size.height/2);
                statusLabel?.text = ADMINISTERED
                statusLabel?.font = statusLabelFont()
                statusLabel?.textAlignment = .Right
                statusLabel?.textColor = PENDING_COUNT_FONT_COLOR
            } else {
                statusLabel?.hidden = true
                statusIcon?.hidden = false
            }
            statusIcon?.image = ADMINISTRATION_SUCCESS_IMAGE
        } else {
            statusIcon?.image = ADMINISTRATION_FAILURE_IMAGE
            statusLabel?.hidden = false
            statusIcon?.hidden = false
            let appDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
            if (appDelegate.windowState == DCWindowState.twoThirdWindow) {
                statusIcon!.center = CGPointMake(self.bounds.size.width/9, self.bounds.size.height/2);
                statusLabel?.center = CGPointMake(self.bounds.size.width/1.4, self.bounds.size.height/2);
            } else {
                positionStatusLabelAndIconForDueAtOrNotAdministeredStatus(true)
            }
            let statusText = String(format: "%i of %i\n%@", refusedCount, timeArray.count, NSLocalizedString("NOT_ADMINISTERED", comment: ""))
            let attributedStatusText : NSMutableAttributedString = NSMutableAttributedString(string: statusText, attributes: [NSFontAttributeName : statusLabelFont(), NSForegroundColorAttributeName : UIColor.redColor()])
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            attributedStatusText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedStatusText.length))
            statusLabel?.attributedText = attributedStatusText
            if (isOneThirdScreen) {
                statusLabel?.textAlignment = .Right
            } else {
                statusLabel?.textAlignment = .Left
            }
        }
    }
    
    func updateCurrentDayStatusViewWithAdministrationCount(administrationCount administeredCount: NSInteger, omittedRefusalCount : NSInteger) {
        
        if ((administeredCount == timeArray.count) || (administeredCount + omittedRefusalCount == timeArray.count)) {
            // all administered, so indicate area with tick mark
            updateAdministeredOrRejectedStatusForAdministrationCount(administrationCount: administeredCount, omittedRefusalCount: omittedRefusalCount)
        } else {
            let nearestSlot : DCMedicationSlot? = nearestMedicationSlotToBeAdministered()
            if (nearestSlot != nil) {
                if (nearestSlot?.medicationAdministration?.actualAdministrationTime == nil) {
                    // get date string from the nearest slot time
                    if (medicationCategory != WHEN_REQUIRED) {
                        let dueTime = DCDateUtility.dateStringFromDate(nearestSlot?.time, inFormat: TWENTYFOUR_HOUR_FORMAT)
                        statusLabel?.hidden = false
                        statusIcon?.hidden = false
                        if isOneThirdScreen {
                            statusIcon!.center = CGPointMake(self.bounds.size.width/5.5, self.bounds.size.height/2);
                            statusLabel?.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
                        } else {
                            positionStatusLabelAndIconForDueAtOrNotAdministeredStatus(true)
                        }
                        //Populate due label
                        statusIcon?.image = ADMINISTRATION_DUE_IMAGE
                        if let time = dueTime {
                            // Display due at time and number of pending items count
                            statusLabel?.attributedText = attributedAdministrationStatusTextForScheduledTime(time, inMedicationSlot: nearestSlot!)
                        }
                        statusLabel?.textAlignment = isOneThirdScreen ? .Right : .Left
                    }
                } else {
                    updateAdministeredOrRejectedStatusForAdministrationCount(administrationCount: administeredCount, omittedRefusalCount: omittedRefusalCount)
                }
            }
        }
     }
    
    func attributedAdministrationStatusTextForScheduledTime(time : String, inMedicationSlot slot : DCMedicationSlot) -> NSMutableAttributedString {
        
        let statusText = String(format: "Due at %@", time)
        let attributedStatusText : NSMutableAttributedString = NSMutableAttributedString(string: statusText, attributes: [NSFontAttributeName : statusLabelFont(), NSForegroundColorAttributeName : DUE_AT_FONT_COLOR])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedStatusText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedStatusText.length))
        let slotIndex = timeArray.indexOfObject(slot)
        let pendingCount = timeArray.count - slotIndex
        let pendingText = String(format: "\n%i of %i %@", pendingCount, slotsCount!, PENDING)
        let attributedPendingText : NSMutableAttributedString = NSMutableAttributedString(string: pendingText, attributes: [NSFontAttributeName : statusLabelFont(), NSForegroundColorAttributeName : PENDING_COUNT_FONT_COLOR])
        attributedStatusText.appendAttributedString(attributedPendingText)
        return attributedStatusText
    }
    
    func nearestMedicationSlotToBeAdministered () -> DCMedicationSlot? {
        
        //initialise medication slot to administer object
        var nearestSlot =  DCMedicationSlot.init()
        if (timeArray.count > 0) {
            for slot in (timeArray as? [DCMedicationSlot])! {
                if (slot.medicationAdministration?.actualAdministrationTime == nil) {
                    nearestSlot = slot
                    return nearestSlot
                }
            }
        }
        return nil
    }
    
    func configureStatusViewForPastDay() {
        
        //if all medications are administered indicate tick mark, if any omissions/rejections indicate x mark
        //if any pending, indicate it with pending count, pending is given priority over adimistered/omitted/refused
        var overDueCount : NSInteger = 0
        var administeredCount : NSInteger = 0
        var omissionRejectionsCount : NSInteger = 0
        for slot in timeArray as [AnyObject] {
            if let administrationDetails = slot.medicationAdministration {
                if (administrationDetails?.actualAdministrationTime == nil) {
                    //Administration details not available. administration details pending, so increment pendingcount
                    overDueCount += 1
                } else {
                    if (administrationDetails.status == ADMINISTERED || administrationDetails.status == SELF_ADMINISTERED) {
                        administeredCount += 1
                    } else if (administrationDetails.status == OMITTED || administrationDetails.status == REFUSED) {
                        omissionRejectionsCount += 1
                    } else {
                        overDueCount += 1;
                    }
                }
            }
        }
        updatePastDayStatusViewForAdministeredCount(administeredCount, overDueCountValue: overDueCount, omissionRefusalCountValue: omissionRejectionsCount)
    }
    
    func updatePastDayStatusViewForAdministeredCount(administeredCount : NSInteger, overDueCountValue overDueCount: NSInteger, omissionRefusalCountValue ommittedRefusalCount : NSInteger) {
        //populate status view for past day
        if (overDueCount > 0) {
            //display Overdue label, indicate label with text 'Overdue'
            if (medicationCategory != WHEN_REQUIRED) {
                statusIcon?.hidden = true
                statusLabel?.hidden = false
                statusLabel?.textColor = OVERDUE_FONT_COLOR
                statusLabel?.font = statusLabelFont()
                statusLabel?.text = NSLocalizedString("OVERDUE", comment: "Some medications has not been administered till now")
                statusLabel?.textAlignment = isOneThirdScreen ? .Right : .Center
            }
        } else if (administeredCount == timeArray.count || ommittedRefusalCount > 0) {
            updateAdministeredOrRejectedStatusForAdministrationCount(administrationCount: administeredCount, omittedRefusalCount: ommittedRefusalCount)
        }
    }
    
    func configureStatusViewForComingDay () {
        
        // display no of pending medications for regular medications
        if (medicationCategory != WHEN_REQUIRED) {
            if isOneThirdScreen {
                statusLabel?.hidden = false
                statusIcon?.hidden = true
                let pendingCount : NSInteger = timeArray.count
                statusLabel?.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
                statusLabel?.textColor = PENDING_FONT_COLOR
                statusLabel?.text = String(format: "%i %@", pendingCount, NSLocalizedString("PENDING", comment: ""))
                statusLabel?.textAlignment = isOneThirdScreen ? .Right : .Center
            } else {
                statusLabel?.hidden = true
                statusIcon?.hidden = false
                statusIcon?.image = ADMINISTRATION_PENDING_IMAGE
            }
        }
    }
    
    func administerMedicationWithMedicationSlot() {
        
        if let slotDictionary = medicationSlotDictionary {
            if let date = weekDate {
                delegate?.administerMedicationWithMedicationSlots(slotDictionary, atIndexPath: currentIndexPath, withWeekDate: date)
            }
        }
    }
    
    @IBAction func administerButtonClicked (sender: UIButton ) {

        if(!isOneThirdScreen){
            self.administerMedicationWithMedicationSlot()
        }
    }
    
    func administerMedicationCellTappedInOneThirdScreenAtIndexPath(indexPath : NSIndexPath) {
        
        self.administerMedicationWithMedicationSlot()
    }
}
