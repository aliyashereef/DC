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
    
    
    func configureAdministrationStatusViewForMedicationSlotDictionary(slotDictionary : NSDictionary) {
        
        medicationSlotDictionary = slotDictionary
        NSLog("slotDictionary is %@", slotDictionary)
        if let timeSlotsArray  = medicationSlotDictionary?["timeSlots"] {
            if timeSlotsArray.count > 0 {
                //let initialMedication : DCMedicationSlot? = timeSlotsArray.objectAtIndex(0) as? DCMedicationSlot
                checkForInitialMedicationSlot(timeSlotsArray as! [DCMedicationSlot])
                for slot in timeSlotsArray as! [AnyObject] {
                   // NSLog("slot time %@", slot.time)
                   // NSLog("slot status %@", slot.status)
                    if let administrationDetails = slot.medicationAdministration {
                        if (administrationDetails == nil) {
                             NSLog("Administration details not available")
                        } else {
                            NSLog("///medicationadministration is %@", (administrationDetails?.status)!)
                        }
                    } else {
                        NSLog("Administration details not available")
                    }
                }
            }
        }
    }
    
    func checkForInitialMedicationSlot(timeArray : NSArray) {
        
        let initialSlot = timeArray.objectAtIndex(0) as? DCMedicationSlot
        let currentSystemDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
        let currentDateString = DCDateUtility.convertDate(currentSystemDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: SHORT_DATE_FORMAT)
        let weekDateString = DCDateUtility.convertDate(weekdate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: SHORT_DATE_FORMAT)
        NSLog("currentDateString is %@", currentDateString)
        NSLog("weekDateString is %@", weekDateString)
        if (currentDateString == weekDateString) {
            // both falls on the same day
            NSLog("****** Today ***")
            
        } else {
            if (initialSlot!.time.compare(currentSystemDate) == NSComparisonResult.OrderedDescending) {
                NSLog("****** Next day ***")
                //next day
                let pendingCount : NSInteger = timeArray.count
                NSLog("Pending Count is %@", pendingCount)
            } else if (initialSlot!.time.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
                NSLog("**** Past day *****")
                var pendingCount : NSInteger = 0
                for slot in timeArray as [AnyObject] {
                    if let administrationDetails = slot.medicationAdministration {
                        if (administrationDetails == nil) {
                            NSLog("Administration details not available")
                            //administration details pending, so increment pendingcount
                            pendingCount++
                        } else {
                            NSLog("medicationadministration is %@", (administrationDetails?.status)!)
                        }
                    }
                    NSLog("pendingCount is %d", pendingCount)
                }
            }
        }
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
