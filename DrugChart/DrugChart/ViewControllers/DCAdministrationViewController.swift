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
    @IBOutlet var administerTableView: UITableView!
    var patientId : NSString = EMPTY_STRING
    var scheduleId : NSString = EMPTY_STRING
    var errorMessage : String = EMPTY_STRING
    var helper : DCSwiftObjCNavigationHelper = DCSwiftObjCNavigationHelper.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.administerTableView.rowHeight = UITableViewAutomaticDimension
        self.administerTableView.estimatedRowHeight = 44.0
    }
    
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
    //MARK: TableView Delegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    //The number of rows is determined by the medication slot status, if is administrated, the section will require 6 rows, if ommitted it may require 2 rows and 3 for the refused state.
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1 : return 1
        case 2 : return medicationSlotsArray.count
        default : break
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
        if cell == nil {
            cell = DCAdminsteredMedicationCell(style: UITableViewCellStyle.Value1, reuseIdentifier: ADMINSTER_MEDICATION_HISTORY_CELL)
        }
        
        
        return cell!
    }
    
    // MARK: Header View Methods
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1: return 0.0
        case 2: return 44.0
        default : break
        }
        return 0
    }
    
    // returns the header view
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    }
    
    
}
