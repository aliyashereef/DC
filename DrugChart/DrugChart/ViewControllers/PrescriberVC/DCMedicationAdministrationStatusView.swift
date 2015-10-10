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
let ADMINISTRATION_DUE_NOW_IMAGE    =   UIImage(named: "AdministrationDueNow")
let PENDING_FONT_COLOR              =   UIColor.getColorForHexString("#acacac")
let DUE_AT_FONT_COLOR               =   UIColor.getColorForHexString("#404040")
let OVERDUE_FONT_COLOR              =   UIColor.getColorForHexString("#ff8972") // get exact color for display
let DUE_NOW_FONT_COLOR              =   UIColor.whiteColor()

@objc protocol DCMedicationAdministrationStatusProtocol:class {
    
    func administerMedicationWithMedicationSlots (medicationSLotDictionary: NSDictionary, atIndexPath indexPath: NSIndexPath ,withWeekDate date : NSDate)
}

class DCMedicationAdministrationStatusView: UIView {
    
    var medicationSlotDictionary: NSDictionary?
    var currentIndexPath: NSIndexPath?
    var weekdate : NSDate?
    var timeArray : NSArray = []
    weak var delegate:DCMedicationAdministrationStatusProtocol?

    var administerButton: UIButton?
    var statusIcon : UIImageView?
    var statusLabel : UILabel?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        addViewElements()
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    func addViewElements() {
        
        //add UI elements programmatically
        let contentFrame : CGRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        statusLabel = UILabel.init(frame: contentFrame)
        self.addSubview(statusLabel!)
        statusLabel?.textAlignment = NSTextAlignment.Center
        statusLabel?.font = UIFont.systemFontOfSize(13.0)
        statusIcon = UIImageView.init(frame: CGRectMake(0, 0, 25, 25))
        self.addSubview(statusIcon!)
        statusIcon!.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        administerButton = UIButton.init(frame: contentFrame)
        self.addSubview(administerButton!)
        administerButton?.addTarget(self, action: Selector("administerButtonClicked:"), forControlEvents: .TouchUpInside)
    }
 

    func updateAdministrationStatusViewWithMedicationSlotDictionary(slotDictionary : NSDictionary) {
        
        medicationSlotDictionary = slotDictionary
        if let timeSlotsArray  = medicationSlotDictionary?["timeSlots"] {
            if timeSlotsArray.count > 0 {
                configureStatusViewForTimeArray(timeSlotsArray as! [DCMedicationSlot])
            }
        }
    }
    
    func configureStatusViewForTimeArray(timeSlotsArray : NSArray) {
        
        timeArray = timeSlotsArray
        print("Crashing here")
        let initialSlot = timeArray.objectAtIndex(0) as? DCMedicationSlot
        print("Not going ahead here")
        
        let currentSystemDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
        let currentDateString = DCDateUtility.convertDate(currentSystemDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: SHORT_DATE_FORMAT)
        let initialSlotDateString = DCDateUtility.convertDate(initialSlot?.time, fromFormat: DEFAULT_DATE_FORMAT, toFormat: SHORT_DATE_FORMAT)
        if (currentDateString == initialSlotDateString) {
            // both falls on the same day
            configureStatusViewForTodayCurrentDay()
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
        statusIcon!.center = CGPointMake(self.bounds.size.width/5, self.bounds.size.height/2);
        statusLabel?.center = CGPointMake(self.bounds.size.width/1.7, self.bounds.size.height/2);
    }
    
    func configureStatusViewForTodayCurrentDay() {
        
        //populate view for current day, display medication due at initial time
        var overDueCount : NSInteger = 0
        var administeredCount : NSInteger = 0
        var omissionRefusalCount : NSInteger = 0
        let currentSystemDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
        var currentTime = false
        for slot in timeArray as [AnyObject] {
            let medication = slot as! DCMedicationSlot
            if (medication.time.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
                //past time, check if any medication administration is pending
                if (medication.medicationAdministration == nil) {
                    overDueCount++
                    break;
                }
            }
            else if (medication.time.compare(currentSystemDate) == NSComparisonResult.OrderedSame ) {
                //TODO: has to compare 2 dates and check if their diff is 1 mint
                currentTime = true
                break;
            }
            //check the conditions of early administrations as well
            if (medication.medicationAdministration != nil) {
                if (medication.medicationAdministration.status == ADMINISTERED) {
                    administeredCount++
                } else if (medication.medicationAdministration.status == REFUSED || medication.medicationAdministration.status == OMITTED) {
                    omissionRefusalCount++
                }
            }
        }
        if (currentTime) {
            // Due Now.. Indicate with yellow background, Due now text will be white
            adjustStatusLabelAndImageViewForCurrentDay()
            self.backgroundColor = UIColor.getColorForHexString("#f2bc53")
            statusIcon?.image = ADMINISTRATION_DUE_NOW_IMAGE
            statusLabel?.text = NSLocalizedString("DUE_NOW", comment: "")
        } else {
            if (overDueCount > 0) {
                //display overdue label here
                statusLabel?.hidden = false
                statusLabel?.textColor = OVERDUE_FONT_COLOR
                statusLabel?.text = NSLocalizedString("OVERDUE", comment: "Some medications are overdue")
            } else {
                updateCurrentDayStatusViewWithAdministrationCount(administrationCount:administeredCount, omittedRefusalCount: omissionRefusalCount)
            }
        }
    }
    
    func updateCurrentDayStatusViewWithAdministrationCount(administrationCount administeredCount: NSInteger, omittedRefusalCount : NSInteger) {
        
        let nearestSlot : DCMedicationSlot? = DCUtility.getNearestMedicationSlotToBeAdministeredFromSlotsArray(timeArray as [AnyObject]);
        if (nearestSlot != nil) {
            if (nearestSlot!.medicationAdministration == nil) {
                // get date string from the nearest slot time
                let dueTime = DCDateUtility.convertDate(nearestSlot!.time, fromFormat: DEFAULT_DATE_FORMAT, toFormat: TWENTYFOUR_HOUR_FORMAT)
                adjustStatusLabelAndImageViewForCurrentDay()
                //Populate due label
                statusIcon?.image = ADMINISTRATION_DUE_IMAGE
                statusLabel?.text = String(format: "Due at %@", dueTime)
            }
        } else {
            if (administeredCount == timeArray.count || administeredCount + omittedRefusalCount == timeArray.count) {
                // all administered, so indicate area with tick mark
                statusLabel?.hidden = true
                statusIcon?.hidden = false
                statusIcon!.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
                statusIcon?.image = (administeredCount == timeArray.count) ? ADMINISTRATION_SUCCESS_IMAGE : ADMINISTRATION_FAILURE_IMAGE
            }
        }
     }
    
    func configureStatusViewForPastDay() {
        
        //if all medications are administered indicate tick mark, if any omissions/rejections indicate x mark
        //if any pending, indicate it with pending count, pending is given priority over adimistered/omitted/refused
        var overDueCount : NSInteger = 0
        var administeredCount : NSInteger = 0
        var omissionRejectionsCount : NSInteger = 0
        for slot in timeArray as [AnyObject] {
            if let administrationDetails = slot.medicationAdministration {
                if (administrationDetails == nil) {
                    //Administration details not available. administration details pending, so increment pendingcount
                    overDueCount++
                } else {
                    if (administrationDetails.status == ADMINISTERED) {
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
        if (administeredCount == timeArray.count) {
            //display tick mark
            statusIcon?.hidden = false
            statusLabel?.hidden = true
            statusIcon?.image = ADMINISTRATION_SUCCESS_IMAGE
        } else if (overDueCount > 0) {
            //display Overdue label, indicate label with text 'Overdue'
            statusIcon?.hidden = true
            statusLabel?.hidden = false
            statusLabel?.textColor = OVERDUE_FONT_COLOR
            statusLabel?.text = NSLocalizedString("OVERDUE", comment: "Some medications has not been administered till now")
        } else if (ommittedRefusalCount > 0) {
            //display cross symbol
            statusLabel?.hidden = true
            statusIcon?.hidden = false
            statusIcon?.image = ADMINISTRATION_FAILURE_IMAGE
        }
    }
    
    func configureStatusViewForComingDay () {
        
        // display no of pending medications
        let pendingCount : NSInteger = timeArray.count
        statusLabel?.hidden = false
        statusIcon?.hidden = true
        statusLabel?.textColor = PENDING_FONT_COLOR
        statusLabel?.text = String(format: "%i %@", pendingCount, NSLocalizedString("PENDING", comment: ""))
    }
    
    @IBAction func administerButtonClicked (sender: UIButton ) {
        
        //delegate?.administerButtonClickedForViewTag(self.tag, atIndexPath: currentIndexPath!)
        if let slotDictionary = medicationSlotDictionary {
            delegate?.administerMedicationWithMedicationSlots(slotDictionary, atIndexPath: currentIndexPath!, withWeekDate: weekdate!)
        }
    }
    
}
