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
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    var medicationSlotsArray : [DCMedicationSlot] = [DCMedicationSlot]()
    var medicationDetails : DCMedicationScheduleDetails?
    var contentArray :[AnyObject] = []
    var slotToAdminister : DCMedicationSlot?
    var weekDate : NSDate?
    @IBOutlet var administerTableView: UITableView!
    var patientId : NSString = EMPTY_STRING
    var scheduleId : NSString = EMPTY_STRING
    var errorMessage : String = EMPTY_STRING
    var helper : DCSwiftObjCNavigationHelper = DCSwiftObjCNavigationHelper.init()
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureTableViewProperties()
        self.configureNavigationBar()
        initialiseMedicationSlotToAdministerObject()
    }
    
    func configureTableViewProperties (){
        self.administerTableView.rowHeight = UITableViewAutomaticDimension
        self.administerTableView.estimatedRowHeight = 44.0
        self.administerTableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func configureNavigationBar() {
        //Navigation bar title string
        let dateString : String
        if let date = slotToAdminister?.time {
            dateString = DCDateUtility.dateStringFromDate(date, inFormat: DATE_MONTHNAME_YEAR_FORMAT)
        } else {
            dateString = DCDateUtility.dateStringFromDate(weekDate, inFormat: DATE_MONTHNAME_YEAR_FORMAT)
        }
        self.title = dateString
        // Navigation bar done button
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "doneButtonPressed")
        if (appDelegate.windowState == DCWindowState.halfWindow || appDelegate.windowState == DCWindowState.oneThirdWindow) {
            self.navigationItem.leftBarButtonItems = [doneButton]
        } else {
            let negativeSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
            negativeSpacer.width = -12
            self.navigationItem.leftBarButtonItems = [negativeSpacer,doneButton]
        }
    }
    
    func configureMedicationStatusInCell (medication : DCMedicationSlot) -> NSString {
        
        let currentSystemDate : NSDate = NSDate()
        let currentDateString : NSString? = DCDateUtility.dateStringFromDate(currentSystemDate, inFormat: SHORT_DATE_FORMAT)

        if (medication.medicationAdministration?.status != nil && medication.medicationAdministration.actualAdministrationTime != nil){
            if medication.medicationAdministration?.status == REFUSED {
                return NOT_ADMINISTRATED
            } else {
                return (medication.medicationAdministration?.status)!
            }
        }
        if medication.medicationAdministration?.status == STARTED {
            return IN_PROGRESS
        }
        //medication slot selected more than the current date
        if (medication.time.compare(currentSystemDate) == NSComparisonResult.OrderedDescending){
            let slotDateString : NSString? = DCDateUtility.dateStringFromDate(slotToAdminister?.time, inFormat: SHORT_DATE_FORMAT)
            if (currentDateString != slotDateString && medication.medicationAdministration?.status == nil) {
                return PENDING
            } else if (medication.medicationAdministration?.status != nil) {
                if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationDetails!) {
                    return IN_PROGRESS
                } else {
                    return medication.medicationAdministration.status
                }
            }
        }
        if let slotToAdministerDate = slotToAdminister?.time {
            if (medication.time.compare(slotToAdministerDate) == NSComparisonResult.OrderedSame) {
                if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationDetails!) {
                    return ADMINISTER_NOW
                } else {
                    return ADMINISTER_MEDICATION
                }
            }
        }
        //medication slot selected less than the current date
        if (medication.time.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
            if (medication.medicationAdministration?.status != nil) {
                if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationDetails!) {
                    return IN_PROGRESS
                } else {
                return medication.medicationAdministration.status
                }
            } else if (slotToAdminister?.medicationAdministration?.actualAdministrationTime == nil){
                   return PENDING
            }
        }
        return PENDING
    }
    
    func initialiseMedicationSlotToAdministerObject () {
        //initialise medication slot to administer object
        slotToAdminister = DCMedicationSlot.init()

        if (medicationDetails?.medicineCategory == WHEN_REQUIRED) {
            let today : NSDate = NSDate()
            let order = NSCalendar.currentCalendar().compareDate(weekDate! , toDate:today,
                toUnitGranularity: .Day)
            if order == NSComparisonResult.OrderedSame {
                slotToAdminister?.time = NSDate()
                medicationSlotsArray.append(slotToAdminister!)
            }
        } else {
            if (medicationSlotsArray.count > 0) {
                for slot : DCMedicationSlot in medicationSlotsArray {
                    if (slot.medicationAdministration?.actualAdministrationTime == nil && slot.medicationAdministration == nil) {
                        slotToAdminister = slot
                        break
                    }
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
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1 : return headerString as String
        default : return EMPTY_STRING
        }
    }
    
    func configureAdministrationStatusCellAtIndexPath (indexPath :NSIndexPath) -> DCAdministrationStatusCell{
        let cell = administerTableView.dequeueReusableCellWithIdentifier("AdministrationStatusCell") as? DCAdministrationStatusCell
        let medicationSlot : DCMedicationSlot = medicationSlotsArray[indexPath.row]
        if (medicationSlot.medicationAdministration?.status != nil || medicationSlot.medicationAdministration?.actualAdministrationTime != nil) {
            cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell!.statusLabelTrailingSpace.constant = 5.0
        } else {
            cell!.statusLabelTrailingSpace.constant = 15.0
        }

        cell!.administrationStatusLabel.text = configureMedicationStatusInCell(medicationSlot) as String
        if (cell!.administrationStatusLabel.text == ADMINISTER_MEDICATION ||
            cell!.administrationStatusLabel.text == ADMINISTER_NOW ){
            cell!.administrationStatusLabel.textColor = UIColor(forHexString:"#4A90E2")
        } else {
            cell!.administrationStatusLabel.textColor = UIColor(forHexString:"#676767")
        }
        cell?.administrationTimeLabel.text =  DCDateUtility.dateStringFromDate(medicationSlot.time, inFormat: TWENTYFOUR_HOUR_FORMAT)
        return cell!
    }
    
    func configureMedicationDetailsCellAtIndexPath (indexPath :NSIndexPath) -> UITableViewCell {
        
        if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationDetails!){
            let cell = administerTableView.dequeueReusableCellWithIdentifier("DurationBasedInfusionCell") as? DCDurationBasedMedicationDetailsCell
            if let _ = medicationDetails {
                cell!.configureMedicationDetails(medicationDetails!)
            }
            return cell!
        } else {
            let cell = administerTableView.dequeueReusableCellWithIdentifier("MedicationDetailsTableViewCell") as? DCMedicationDetailsTableViewCell
            if let _ = medicationDetails {
                cell!.configureMedicationDetails(medicationDetails!)
            }
            return cell!
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.section == 0) {
            addBNFView()
        } else {
            
            let cell = administerTableView.cellForRowAtIndexPath(indexPath) as? DCAdministrationStatusCell
            if cell?.administrationStatusLabel.text != PENDING {
                let medicationSlot : DCMedicationSlot = medicationSlotsArray[indexPath.row]
                if (cell?.administrationStatusLabel.text == ADMINISTER_MEDICATION || cell?.administrationStatusLabel.text == ADMINISTER_NOW || cell?.administrationStatusLabel.text == "In progress") {
                    slotToAdminister?.time = medicationSlot.time
                    addAdministerViewWithStatus((cell?.administrationStatusLabel.text)!)
                } else {
                    if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationDetails!) && cell?.administrationStatusLabel.text == ADMINISTERED {
                        self.transitToAdminsisterGraphViewController(indexPath.row)
                    } else {
                        addMedicationHistoryViewAtIndex(indexPath.row)
                    }
                }
            }
        }
    }
    
    func transitToAdminsisterGraphViewController(index : NSInteger) {
        
        //add medication History view controller
        let AdministerGraphStoryboard : UIStoryboard? = UIStoryboard(name:ADMINISTER_GRAPH, bundle: nil)
        let administerGraphViewController = AdministerGraphStoryboard!.instantiateViewControllerWithIdentifier(ADMINISTER_GRAPH_STORYBOARD_ID) as? DCAdministerGraphViewController
        administerGraphViewController?.weekDate = weekDate
        administerGraphViewController?.medicationDetails = medicationDetails
        administerGraphViewController?.medicationSlotArray = [medicationSlotsArray[index]]
        self.navigationController?.pushViewController(administerGraphViewController!, animated: true)
    }
    
    func doneButtonPressed() {
        
        slotToAdminister = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addBNFView () {
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        let bnfViewController : DCBNFViewController? = administerStoryboard!.instantiateViewControllerWithIdentifier(BNF_STORYBOARD_ID) as? DCBNFViewController
        self.navigationController?.pushViewController(bnfViewController!, animated: true)
    }
    
    func addAdministerViewWithStatus(status : NSString) {
        
        //add administer view controller
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        let administerStatusViewController : DCAdministrationStatusSelectionViewController? = administerStoryboard!.instantiateViewControllerWithIdentifier(ADMINISTRATION_STATUS_CHANGE_VIEW_CONTROLLER) as? DCAdministrationStatusSelectionViewController
        administerStatusViewController?.medicationSlot = slotToAdminister
        administerStatusViewController?.weekDate = weekDate
        administerStatusViewController?.patientId = patientId
        administerStatusViewController?.statusState = status as String
        administerStatusViewController?.helper = helper
        if (medicationSlotsArray.count > 0) {
            administerStatusViewController?.medicationSlot = slotToAdminister
            var medicationArray : [DCMedicationSlot] = [DCMedicationSlot]()
            if let toAdministerArray : [DCMedicationSlot] = medicationSlotsArray {
                var slotCount = 0
                    for slot : DCMedicationSlot in toAdministerArray {
                        if (slot.medicationAdministration?.actualAdministrationTime == nil) {
                            medicationArray.insert(slot, atIndex: slotCount)
                            slotCount++
                        }
                    }
                }
                administerStatusViewController?.medicationSlotsArray = (medicationDetails?.medicineCategory == WHEN_REQUIRED) ? medicationSlotsArray : medicationArray
            }
            administerStatusViewController?.medicationDetails = medicationDetails
//            administerStatusViewController?.alertMessage = errorMessage
        let navigationController : UINavigationController = UINavigationController(rootViewController: administerStatusViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.presentViewController(navigationController, animated: true, completion:nil)
    }
    
    func addMedicationHistoryViewAtIndex(index : NSInteger) {
        
        //add medication History view controller
        let MedicationHistoryStoryboard : UIStoryboard? = UIStoryboard(name:MEDICATION_HISTORY, bundle: nil)
        let medicationHistoryViewController = MedicationHistoryStoryboard!.instantiateViewControllerWithIdentifier(MEDICATION_STORYBOARD_ID) as? DCMedicationHistoryViewController
            medicationHistoryViewController?.weekDate = weekDate
            medicationHistoryViewController?.medicationDetails = medicationDetails
        medicationHistoryViewController?.medicationSlotArray = [medicationSlotsArray[index]]
        self.navigationController?.pushViewController(medicationHistoryViewController!, animated: true)
    }
}
