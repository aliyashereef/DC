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
    var timeArray : NSArray = []
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
    
    func configureStatusViewForTimeArray(timeSlotsArray : NSArray) {
        
        timeArray = timeSlotsArray
        let initialSlot = timeArray.objectAtIndex(0) as? DCMedicationSlot
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
    
    func configureStatusViewForTodayCurrentDay() {
        
        //populate view for current day, display medication due at initial time
        NSLog("****** Current day ******")
        var overDueCount : NSInteger = 0
        var administeredCount : NSInteger = 0
        var omissionRefusalCount : NSInteger = 0
        let currentSystemDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
        for slot in timeArray as [AnyObject] {
            let medication = slot as! DCMedicationSlot
            if (medication.time.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
                //past time, check if any medication administration is pending
                if (medication.medicationAdministration == nil) {
                    overDueCount++
                    break;
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
        if (overDueCount > 0) {
            //display overdue label here
        } else {
            updateCurrentDayStatusViewWithAdministrationCount(administrationCount:administeredCount, omittedRefusalCount: omissionRefusalCount)
        }
    }
    
    func updateCurrentDayStatusViewWithAdministrationCount(administrationCount administeredCount: NSInteger, omittedRefusalCount : NSInteger) {
        
        let nearestSlot : DCMedicationSlot? = DCUtility.getNearestMedicationSlotToBeAdministeredFromSlotsArray(timeArray as [AnyObject]);
        if (nearestSlot != nil) {
            if (nearestSlot!.medicationAdministration == nil) {
                // get date string from the nearest slot time
                let dueTime = DCDateUtility.convertDate(nearestSlot!.time, fromFormat: DEFAULT_DATE_FORMAT, toFormat: TWENTYFOUR_HOUR_FORMAT)
                NSLog("Due time is %@", dueTime)
                //Populate due label
            }
        } else {
            if (administeredCount == timeArray.count) {
                // all administered, so indicate area with tick mark
            } else if (administeredCount + omittedRefusalCount == timeArray.count) {
                // indicate slot with cross mark
                
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
        if (administeredCount == timeArray.count) {
            //display tick mark
        } else if (overDueCount > 0) {
            //display pending label, indicate label with text 'Overdue'
            
        } else if (omissionRejectionsCount > 0) {
            //display cross symbol
            
        }
    }
    
    func configureStatusViewForComingDay () {
        
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
    
}
