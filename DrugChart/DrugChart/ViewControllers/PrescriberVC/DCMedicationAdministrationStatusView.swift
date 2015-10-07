//
//  DCMedicationAdministrationStatusView.swift
//  DrugChart
//
//  Created by Muhammed Shaheer on 01/10/15.
//
//

import UIKit

@objc protocol DCMedicationAdministrationStatusProtocol:class {
    
    func administerMedicationWithMedicationSlots (medicationSLotDictionary: NSDictionary, atIndexPath indexPath: NSIndexPath ,withWeekDate date : NSDate)
}

class DCMedicationAdministrationStatusView: UIView {
    
    var medicationSlotDictionary: NSDictionary?
    var medicationSlot: DCMedicationSlot?
    var currentIndexPath: NSIndexPath?
    var weekdate : NSDate?
    weak var delegate:DCMedicationAdministrationStatusProtocol?

    @IBOutlet var administerButton: UIButton?
    
    
    func updateAdministrationStatusViewWithMedicationSlotDictionary(slotDictionary : NSDictionary) {
        
        medicationSlotDictionary = slotDictionary
        if let timeSlotsArray  = medicationSlotDictionary?["timeSlots"] {
            if timeSlotsArray.count > 0 {
                configureStatusViewForTimeArray(timeSlotsArray as! [DCMedicationSlot])
            }
        }
    }
    
    func configureStatusViewForTimeArray(timeArray : NSArray) {
        
        let initialSlot = timeArray.objectAtIndex(0) as? DCMedicationSlot
        let currentSystemDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
        let currentDateString = DCDateUtility.convertDate(currentSystemDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: SHORT_DATE_FORMAT)
        let initialSlotDateString = DCDateUtility.convertDate(initialSlot?.time, fromFormat: DEFAULT_DATE_FORMAT, toFormat: SHORT_DATE_FORMAT)
        NSLog("currentDateString is %@", currentDateString)
        NSLog("initialSlotDateString is %@", initialSlotDateString)
        if (currentDateString == initialSlotDateString) {
            // both falls on the same day
            configureStatusViewForTodayWithTimeArray(timeArray)
        } else {
            if (initialSlot!.time.compare(currentSystemDate) == NSComparisonResult.OrderedDescending) {
                //next day
                configureStatusViewForComingDayWithTimeArray(timeArray)
            } else if (initialSlot!.time.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
                //previous day
                configureStatusViewForPastDayWithTimeArray(timeArray)
            } else {
                // No slots available
            }
        }
    }
    
    func configureStatusViewForTodayWithTimeArray(timeArray : NSArray) {
        
        //populate view for current day, display medication due at initial time
        NSLog("****** Current day ******")
        var pendingCount : NSInteger = 0
        var administeredCount : NSInteger = 0
        var omissionRefusalCount : NSInteger = 0
        let currentSystemDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
        for slot in timeArray as [AnyObject] {
            let medication = slot as! DCMedicationSlot
            if (medication.time.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
                //past time, check if any medication administration is pending
                if (medication.medicationAdministration == nil) {
                    pendingCount++
                }
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
        let nearestSlot : DCMedicationSlot? = DCUtility.getNearestMedicationSlotToBeAdministeredFromSlotsArray(timeArray as [AnyObject]);
        if (nearestSlot != nil) {
            if (nearestSlot!.medicationAdministration == nil) {
                // get date string from the nearest slot time
                let dueTime = DCDateUtility.convertDate(nearestSlot!.time, fromFormat: DEFAULT_DATE_FORMAT, toFormat: TWENTYFOUR_HOUR_FORMAT)
                NSLog("Due time is %@", dueTime)
            }
        }
        if (administeredCount == timeArray.count) {
            // all administered, so indicate area with tick mark
        } else if (administeredCount + omissionRefusalCount == timeArray.count) {
            // indicate slot with cross mark
            
        } else if (pendingCount > 0) {
            // populate pending count label if pending count > 0
            
        }
    }
    
    func configureStatusViewForPastDayWithTimeArray(timeArray : NSArray) {
        
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
        if (administeredCount == timeArray.count) {
            //display tick mark
        } else if (overDueCount > 0) {
            //display pending label
            
        } else if (omissionRejectionsCount > 0) {
            //display cross symbol
            
        }
    }
    
    func configureStatusViewForComingDayWithTimeArray(timeArray : NSArray) {
        
        // display no of pending medications
        let pendingCount : NSInteger = timeArray.count
        NSLog("**** Next day Pending Count is %d", pendingCount)
    }
    
    @IBAction func administerButtonClicked (sender: UIButton ) {
        
        //delegate?.administerButtonClickedForViewTag(self.tag, atIndexPath: currentIndexPath!)
        if let slotDictionary = medicationSlotDictionary {
            delegate?.administerMedicationWithMedicationSlots(slotDictionary, atIndexPath: currentIndexPath!, withWeekDate: weekdate!)
        }
    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
}
