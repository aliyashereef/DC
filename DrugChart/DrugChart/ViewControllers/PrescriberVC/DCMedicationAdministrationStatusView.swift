//
//  DCMedicationAdministrationStatusView.swift
//  DrugChart
//
//  Created by Muhammed Shaheer on 01/10/15.
//
//

import UIKit

let ADMINISTRATION_SUCCESS_IMAGE    =   UIImage(named: "AdministrationSuccess")
let ADMINISTRATION_FAILURE_IMAGE    =   UIImage(named: "AdministrationFailure")
let ADMINISTRATION_DUE_IMAGE        =   UIImage(named: "AdministrationDue")

let ADMINISTRATION_SUCCESS_IMAGE_ONETHIRD    =   UIImage(named: "OneThirdAdminStatusSuccess")
let ADMINISTRATION_DUE_IMAGE_ONETHIRD        =   UIImage(named: "OneThirdScreenAdminStatusOverdue")
let ADMINISTRATION_FAILURE_IMAGE_ONETHIRD    =   UIImage(named: "OneThirdScreenAdminStatusRefused")
let ADMINISTRATION_OMITTED_IMAGE_ONETHIRD    =   UIImage(named: "OneThirdScreenAdminStatusOmitted")

let ADMINISTRATION_DUE_NOW_IMAGE    =   UIImage(named: "AdministrationDueNow")
let PENDING_FONT_COLOR              =   UIColor(forHexString: "#acacac")
let DUE_AT_FONT_COLOR               =   UIColor(forHexString: "#404040")
let OVERDUE_FONT_COLOR              =   UIColor(forHexString: "#ff8972") // get exact color for display
let DUE_NOW_FONT_COLOR              =   UIColor.whiteColor()
let CURRENT_DAY_BACKGROUND_COLOR    =   UIColor(forHexString: "#fafafa")

typealias AdministerButtonTappedCallback = (Bool) -> Void

protocol DCMedicationAdministrationStatusProtocol:class {
    
    func administerMedicationWithMedicationSlots (medicationSLotDictionary: NSDictionary, atIndexPath indexPath: NSIndexPath ,withWeekDate date : NSDate)
}

class DCMedicationAdministrationStatusView: UIView {
    
    var medicationSlotDictionary: NSDictionary?
    var currentIndexPath: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    var weekDate : NSDate?
    var timeArray : NSArray = []
    weak var delegate:DCMedicationAdministrationStatusProtocol?

    var administerButton: DCAdministerButton?
    var statusIcon : UIImageView?
    var statusLabel : UILabel?
    var medicationCategory : NSString?
    var startDate : NSDate?
    var endDate : NSDate?
    var isOneThirdScreen : Bool = false
    var administerButtonCallback: AdministerButtonTappedCallback!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
         addViewElements()
        administerButton?.enabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    func addViewElements() {
        
        //add UI elements programmatically
        let contentFrame : CGRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        statusLabel = UILabel.init(frame: contentFrame)
        self.addSubview(statusLabel!)
        statusLabel?.font = UIFont.systemFontOfSize(13.0)
        statusIcon = UIImageView.init(frame: CGRectMake(0, 0, 25, 25))
        self.addSubview(statusIcon!)
        statusIcon!.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        administerButton = DCAdministerButton.init(frame: contentFrame)
        self.addSubview(administerButton!)
        self.sendSubviewToBack(administerButton!)
        administerButton?.addTarget(self, action: Selector("administerButtonClicked:"), forControlEvents: .TouchUpInside)
        if (medicationCategory == WHEN_REQUIRED || medicationCategory == ONCE_MEDICATION) {
            self.disableAdministerButton()
        }
    }

    func updateAdministrationStatusViewWithMedicationSlotDictionary(slotDictionary : NSDictionary) {
        
        medicationSlotDictionary = slotDictionary.copy() as? NSDictionary
        if let timeSlotsArray  = medicationSlotDictionary?["timeSlots"] {
            if timeSlotsArray.count > 0 {
                configureStatusViewForTimeArray(timeSlotsArray as! [DCMedicationSlot])
            }
        }
    }
    
    func configureStatusViewForWeekDate(weeksDate : NSDate) {
        
        weekDate = weeksDate
        let currentSystemDate : NSDate = DCDateUtility.dateInCurrentTimeZone(NSDate())
        let currentDateString = DCDateUtility.dateStringFromDate(currentSystemDate, inFormat: SHORT_DATE_FORMAT)
        let weekDateString = DCDateUtility.dateStringFromDate(weekDate, inFormat: SHORT_DATE_FORMAT)
        if (currentDateString == weekDateString) {
            if(!isOneThirdScreen) {
                self.backgroundColor = CURRENT_DAY_BACKGROUND_COLOR
            }
        }
    }
    
    func configureStatusViewForTimeArray(timeSlotsArray : NSArray) {
        
        timeArray = timeSlotsArray
        let initialSlot = timeArray.objectAtIndex(0) as? DCMedicationSlot
        let currentSystemDate : NSDate = DCDateUtility.dateInCurrentTimeZone(NSDate())
        let currentDateString = DCDateUtility.dateStringFromDate(currentSystemDate, inFormat: SHORT_DATE_FORMAT)
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
    
    func adjustStatusLabelAndImageViewForCurrentDay () {
        
        statusLabel?.hidden = false
        statusLabel?.hidden = false
        if isOneThirdScreen {
            statusIcon!.center = CGPointMake(self.bounds.size.width/5, self.bounds.size.height/2);
            statusLabel?.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        } else {
            let appDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
            if appDelegate.windowState == DCWindowState.twoThirdWindow {
                statusIcon!.center = CGPointMake(self.bounds.size.width/5 - 3, self.bounds.size.height/2);
            }
            else {
                statusIcon!.center = CGPointMake(self.bounds.size.width/5, self.bounds.size.height/2);
            }
            statusLabel?.center = CGPointMake(self.bounds.size.width/1.7, self.bounds.size.height/2);
        }
        self.disableAdministerButton()
    }
    
    func configureStatusViewForToday() {
        
        //populate view for current day, display medication due at initial time
        var overDueCount : NSInteger = 0
        var administeredCount : NSInteger = 0
        var omissionRefusalCount : NSInteger = 0
        let currentSystemDate : NSDate = DCDateUtility.dateInCurrentTimeZone(NSDate())
        for slot in timeArray as [AnyObject] {
            let medication = slot as! DCMedicationSlot
            if (medication.time.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
                //past time, check if any medication administration is pending
                if (medication.medicationAdministration?.actualAdministrationTime == nil) {
                    overDueCount++
                    break;
                }
            }
            //check the conditions of early administrations as well
            if (medication.medicationAdministration?.actualAdministrationTime != nil) {
                if (medication.medicationAdministration?.status == ADMINISTERED || medication.medicationAdministration?.status == SELF_ADMINISTERED) {
                    administeredCount++
                } else if (medication.medicationAdministration?.status == REFUSED || medication.medicationAdministration?.status == OMITTED) {
                    omissionRefusalCount++
                }
            }
        }
        if (overDueCount > 0) {
            //display overdue label here
            statusLabel?.hidden = false
            statusLabel?.textColor = OVERDUE_FONT_COLOR
            statusLabel?.text = NSLocalizedString("OVERDUE", comment: "Some medications are overdue")
            if isOneThirdScreen {
                statusLabel?.textAlignment = NSTextAlignment.Right
            } else {
                statusLabel?.textAlignment = NSTextAlignment.Center
            }
        } else {
            updateCurrentDayStatusViewWithAdministrationCount(administrationCount:administeredCount, omittedRefusalCount: omissionRefusalCount)
        }
        self.disableAdministerButton()
    }
    
    
    func updateCurrentDayStatusViewWithAdministrationCount(administrationCount administeredCount: NSInteger, omittedRefusalCount : NSInteger) {
        
        if ((administeredCount == timeArray.count) || (administeredCount + omittedRefusalCount == timeArray.count)) {
            // all administered, so indicate area with tick mark
            statusLabel?.hidden = true
            statusIcon?.hidden = false
            self.disableAdministerButton()
            statusIcon!.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
            if isOneThirdScreen {
                statusIcon?.image = (administeredCount == timeArray.count) ? ADMINISTRATION_SUCCESS_IMAGE_ONETHIRD : ADMINISTRATION_OMITTED_IMAGE_ONETHIRD
            } else {
                statusIcon?.image = (administeredCount == timeArray.count) ? ADMINISTRATION_SUCCESS_IMAGE : ADMINISTRATION_FAILURE_IMAGE
            }
        } else {
            let nearestSlot : DCMedicationSlot? = nearestMedicationSlotToBeAdministered()
            if (nearestSlot != nil) {
                if (nearestSlot?.medicationAdministration?.actualAdministrationTime == nil) {
                    // get date string from the nearest slot time
                    if (medicationCategory != WHEN_REQUIRED) {
                        let dueTime = DCDateUtility.dateStringFromDate(nearestSlot?.time, inFormat: TWENTYFOUR_HOUR_FORMAT)
                        adjustStatusLabelAndImageViewForCurrentDay()
                        //Populate due label
                        if !isOneThirdScreen {
                            statusIcon?.image = ADMINISTRATION_DUE_IMAGE
                        } else {
                            statusIcon?.image = ADMINISTRATION_DUE_IMAGE_ONETHIRD
                        }
                        if let time = dueTime {
                            statusLabel?.text = String(format: "Due at %@", time)
                        }
                        if isOneThirdScreen {
                            statusLabel?.textAlignment = NSTextAlignment.Right
                        } else {
                            statusLabel?.textAlignment = NSTextAlignment.Center
                        }
                    }
                } else {
                    if ((administeredCount == timeArray.count) || (administeredCount + omittedRefusalCount == timeArray.count)) {
                        // all administered, so indicate area with tick mark
                        statusLabel?.hidden = true
                        statusIcon?.hidden = false
                        statusIcon!.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
                        statusIcon?.image = (administeredCount == timeArray.count) ? ADMINISTRATION_SUCCESS_IMAGE : ADMINISTRATION_FAILURE_IMAGE
                    }
                }
            }
        }
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
                    overDueCount++
                } else {
                    if (administrationDetails.status == ADMINISTERED || administrationDetails.status == SELF_ADMINISTERED) {
                        administeredCount++
                    } else if (administrationDetails.status == OMITTED || administrationDetails.status == REFUSED) {
                        omissionRejectionsCount++
                    } else {
                        overDueCount++;
                    }
                }
            }
        }
        updatePastDayStatusViewForAdministeredCount(administeredCount, overDueCountValue: overDueCount, omissionRefusalCountValue: omissionRejectionsCount)
    }
    
    func updatePastDayStatusViewForAdministeredCount(administeredCount : NSInteger, overDueCountValue overDueCount: NSInteger, omissionRefusalCountValue ommittedRefusalCount : NSInteger) {
        //populate status view for past day
        self.disableAdministerButton()
        if (administeredCount == timeArray.count) {
            //display tick mark
            statusIcon?.hidden = false
            statusLabel?.hidden = true
            if(!isOneThirdScreen) {
                statusIcon?.image = ADMINISTRATION_SUCCESS_IMAGE
            } else {
                statusIcon?.image = ADMINISTRATION_SUCCESS_IMAGE_ONETHIRD
            }
        } else if (overDueCount > 0) {
            //display Overdue label, indicate label with text 'Overdue'
            if (medicationCategory != WHEN_REQUIRED) {
                statusIcon?.hidden = true
                statusLabel?.hidden = false
                statusLabel?.textColor = OVERDUE_FONT_COLOR
                statusLabel?.text = NSLocalizedString("OVERDUE", comment: "Some medications has not been administered till now")
                if isOneThirdScreen {
                    statusLabel?.textAlignment = NSTextAlignment.Right
                } else {
                    statusLabel?.textAlignment = NSTextAlignment.Center
                }
            }
        } else if (ommittedRefusalCount > 0) {
            //display cross symbol
            statusLabel?.hidden = true
            statusIcon?.hidden = false
            if(!isOneThirdScreen) {
                administerButton?.enabled = true
                statusIcon?.image = ADMINISTRATION_FAILURE_IMAGE
            } else {
                administerButton?.enabled = false
                statusIcon?.image = ADMINISTRATION_OMITTED_IMAGE_ONETHIRD
            }
        }
    }
    
    func configureStatusViewForComingDay () {
        
        // display no of pending medications for regular medications
        if (medicationCategory != WHEN_REQUIRED) {
            let pendingCount : NSInteger = timeArray.count
            statusLabel?.hidden = false
            statusIcon?.hidden = true
            statusLabel?.textColor = PENDING_FONT_COLOR
            statusLabel?.text = String(format: "%i %@", pendingCount, NSLocalizedString("PENDING", comment: ""))
            if isOneThirdScreen {
                administerButton?.enabled = false
                statusLabel?.textAlignment = NSTextAlignment.Right
            } else {
                administerButton?.enabled = true
                statusLabel?.textAlignment = NSTextAlignment.Center
            }
        }
    }
    
    func disableAdministerButton() {
        
        if(isOneThirdScreen) {
            administerButton?.enabled = false
        } else {
            administerButton?.enabled = true
        }
    }
    
    func administerMedicationWithMedicationSlot() {
        
        if let slotDictionary = medicationSlotDictionary {
            delegate?.administerMedicationWithMedicationSlots(slotDictionary, atIndexPath: currentIndexPath, withWeekDate: weekDate!)
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
