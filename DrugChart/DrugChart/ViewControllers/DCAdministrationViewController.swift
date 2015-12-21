//
//  DCAdministrationViewController.swift
//  DrugChart
//
//  Created by aliya on 17/12/15.
//
//

import Foundation

let headerString : NSString = "ADMINISTRATION DETAILS"

class DCAdministrationViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        self.administerTableView.tableFooterView = UIView(frame: CGRectZero)
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonPressed")
        self.navigationItem.leftBarButtonItem = doneButton
        initialiseMedicationSlotToAdministerObject()
        
        let dateString : String
        if let date = slotToAdminister?.time {
            dateString = DCDateUtility.dateStringFromDate(date, inFormat: DATE_MONTHNAME_YEAR_FORMAT)
        } else {
            dateString = DCDateUtility.dateStringFromDate(weekDate, inFormat: DATE_MONTHNAME_YEAR_FORMAT)
        }
        self.title = dateString
    }
    
    func configureMedicationStatusInCell (medication : DCMedicationSlot) -> NSString {
        let currentSystemDate : NSDate = DCDateUtility.dateInCurrentTimeZone(NSDate())
        let currentDateString : NSString? = DCDateUtility.dateStringFromDate(currentSystemDate, inFormat: SHORT_DATE_FORMAT)
        
        if (medication.time.compare(currentSystemDate) == NSComparisonResult.OrderedDescending){
            let slotDateString : NSString? = DCDateUtility.dateStringFromDate(slotToAdminister?.time, inFormat: SHORT_DATE_FORMAT)
            if (currentDateString != slotDateString) {
                return PENDING
            }
        }
        if let slotToAdministerDate = slotToAdminister?.time {
            if (medication.time.compare(slotToAdministerDate) == NSComparisonResult.OrderedSame) {
                return ADMINISTER_MEDICATION
            }
        }
        if (medication.medicationAdministration?.status != nil && medication.medicationAdministration.actualAdministrationTime != nil){
            return medication.status
        }
        if (medication.time.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
            if (slotToAdminister?.medicationAdministration?.actualAdministrationTime == nil){
                   return PENDING
            }
        }
        return PENDING
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 : return 1
        case 1 : return medicationSlotsArray.count
        default : break
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 0 :
            return configureMedicationDetailsCellAtIndexPath(indexPath)
        default:
            return configureAdministrationStatusCellAtIndexPath(indexPath)
        }
    }

    // MARK: Header View Methods
        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0.0
        case 1: return 40.0
        default : break
        }
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1 : return headerString as String
        default : return EMPTY_STRING
        }
    }
    
    func configureAdministrationStatusCellAtIndexPath (indexPath :NSIndexPath) -> DCAdministrationStatusCell{
        let cell = administerTableView.dequeueReusableCellWithIdentifier("AdministrationStatusCell") as? DCAdministrationStatusCell
        let medicationSlot : DCMedicationSlot = medicationSlotsArray[indexPath.row]
        if (medicationSlot.medicationAdministration?.status != nil && medicationSlot.medicationAdministration.actualAdministrationTime != nil) {
            cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }

        cell!.administrationStatusLabel.text = configureMedicationStatusInCell(medicationSlot) as String
        if cell!.administrationStatusLabel.text == ADMINISTER_MEDICATION {
            cell!.administrationStatusLabel.textColor = UIColor(forHexString:"#4A90E2")
        }
        cell?.administrationTimeLabel.text =  DCDateUtility.dateStringFromDate(medicationSlot.time, inFormat: TWENTYFOUR_HOUR_FORMAT)
        return cell!
    }
    
    func configureMedicationDetailsCellAtIndexPath (indexPath :NSIndexPath) -> DCMedicationDetailsTableViewCell {
        let cell = administerTableView.dequeueReusableCellWithIdentifier("MedicationDetailsTableViewCell") as? DCMedicationDetailsTableViewCell
        cell!.configureMedicationDetails(medicationDetails!)
        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.section == 0) {
            addBNFView()
        }
    }
    
    func doneButtonPressed(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addBNFView () {
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        let bnfViewController : DCBNFViewController? = administerStoryboard!.instantiateViewControllerWithIdentifier(BNF_STORYBOARD_ID) as? DCBNFViewController
        self.navigationController?.pushViewController(bnfViewController!, animated: true)
    }
}
