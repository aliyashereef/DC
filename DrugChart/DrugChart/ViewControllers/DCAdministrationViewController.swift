//
//  DCAdministrationViewController.swift
//  DrugChart
//
//  Created by aliya on 17/12/15.
//
//

import Foundation

class DCAdministrationViewController : UIViewController {
    
    @IBOutlet var administrationTableView: UITableView!
    var medicationSlotsArray : [DCMedicationSlot] = []
    var medicationDetails : DCMedicationScheduleDetails?
    var contentArray :[AnyObject] = []
    var slotToAdminister : DCMedicationSlot?
    var weekDate : NSDate?
    var patientId : NSString = EMPTY_STRING
    var scheduleId : NSString = EMPTY_STRING
    var errorMessage : String = EMPTY_STRING
    var helper : DCSwiftObjCNavigationHelper = DCSwiftObjCNavigationHelper.init()
    
    
    func initialiseMedicationSlotToAdministerObject () {
        
        //initialise medication slot to administer object
        slotToAdminister = DCMedicationSlot.init()
        if (medicationSlotsArray.count > 0) {
            for slot : DCMedicationSlot in medicationSlotsArray {
                if (slot.medicationAdministration?.actualAdministrationTime == nil) {
                    slotToAdminister = slot
                    break
                }
            }
        }
    }
    
    
}
