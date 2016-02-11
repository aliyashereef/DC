//
//  AdministerViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/22/15.
//
//

import UIKit

let ADMINISTERED_SECTION_COUNT : NSInteger = 4
let OMITTED_SECTION_COUNT : NSInteger = 3
let REFUSED_SECTION_COUNT : NSInteger = 3

let INITIAL_SECTION_ROW_COUNT : NSInteger = 2
let STATUS_ROW_COUNT : NSInteger = 1
let ADMINISTERED_SECTION_ROW_COUNT : NSInteger = 4
let OMITTED_OR_REFUSED_SECTION_ROW_COUNT : NSInteger = 1
let NOTES_SECTION_ROW_COUNT : NSInteger = 1
let INITIAL_SECTION_HEIGHT : CGFloat = 0.0
let TABLEVIEW_DEFAULT_SECTION_HEIGHT : CGFloat = 20.0
let MEDICATION_DETAILS_SECTION_HEIGHT : CGFloat = 0.0
let MEDICATION_DETAILS_CELL_INDEX : NSInteger = 0
let DATE_PICKER_VIEW_CELL_HEIGHT : CGFloat = 200.0
let NOTES_CELL_HEIGHT : CGFloat = 125.0
let TABLE_CELL_DEFAULT_HEIGHT : CGFloat = 41.0
let DATE_PICKER_CELL_TAG : NSInteger = 101
let SECURITY_PIN_VIEW_ALPHA : CGFloat = 0.3
let DISPLAY_SECURITY_PIN_ENTRY : String = "displaySecurityPinEntryViewForUser:"

enum SectionCount : NSInteger {
    
    // enum for Section Count
    case eZerothSection = 0
    case eFirstSection
    case eSecondSection
    case eThirdSection
    case eFourthSection
}

enum RowCount : NSInteger {
    
    //enum for row count
    case eZerothRow = 0
    case eFirstRow
    case eSecondRow
    case eThirdRow
    case eFourthRow
}

class DCAdministerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotesCellDelegate, NamesListDelegate, AdministerPickerCellDelegate , SecurityPinMatchDelegate, StatusListDelegate, BatchCellDelegate {

    var saveButton: UIBarButtonItem?
    var cancelButton : UIBarButtonItem?
    @IBOutlet weak var administerTableView: UITableView!
    @IBOutlet weak var alertMessageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var medicationSlot : DCMedicationSlot?
    var medicationDetails : DCMedicationScheduleDetails?
    var medicationSlotsArray : [DCMedicationSlot] = [DCMedicationSlot]()
    var usersListWebService : DCUsersListWebService?
    var statusCellSelected : Bool = false
    var userListArray : NSMutableArray? = []
    var popOverIndexPath : NSIndexPath?
    var alertMessage : NSString = EMPTY_STRING
    var datePickerIndexPath : NSIndexPath?
    var isValid : Bool = true
    var weekDate : NSDate?
    var editingIndexPath : NSIndexPath?
    var keyboardHeight : CGFloat?
    var selfAdministratedUser : DCUser? = nil
    var saveClicked : Bool = false
    var patientId : NSString = EMPTY_STRING
    var helper : DCSwiftObjCNavigationHelper = DCSwiftObjCNavigationHelper.init()
    var status : NSString?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureViewElements()
        configureNavigationBar()
        fetchAdministersAndPrescribersList()
        addNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        usersListWebService?.cancelPreviousRequest()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private Methods
    
    func configureTableViewProperties (){
        
        self.administerTableView.rowHeight = UITableViewAutomaticDimension
        self.administerTableView.estimatedRowHeight = 44.0
        self.administerTableView.tableFooterView = UIView(frame: CGRectZero)
        administerTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    }
    
    func configureViewElements () {
        
        configureTableViewProperties()
        initialiseMedicationSlotObject()
        //check if early administration
        if (medicationDetails?.medicineCategory == WHEN_REQUIRED) {
            checkIfFrequentAdministrationForWhenRequiredMedication()
        } else {
            if (medicationSlot?.time != nil) {
                checkIfAdministrationIsEarly()
            }
        }
        if (alertMessage != EMPTY_STRING) {
            alertMessageLabel.hidden = false
            alertMessageLabel.text = alertMessage as String
        } else {
            alertMessageLabel.hidden = true
        }
    }
    
    func configureNavigationBar() {
        //Navigation bar title string
        let dateString : String
        if let date = medicationSlot?.time {
            dateString = DCDateUtility.dateStringFromDate(date, inFormat: DATE_MONTHNAME_YEAR_FORMAT)
        } else {
            dateString = DCDateUtility.dateStringFromDate(weekDate, inFormat: DATE_MONTHNAME_YEAR_FORMAT)
        }
        let slotDate = DCDateUtility.dateStringFromDate(medicationSlot!.time, inFormat: TWENTYFOUR_HOUR_FORMAT)
        self.title = "\(dateString), \(slotDate)"
        // Navigation bar done button
        saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "saveButtonPressed")
        cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonPressed")
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = saveButton
    }

    func addNotifications() {
        
        //keyboard show/hide observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"), name: UIKeyboardWillShowNotification, object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func initialiseMedicationSlotObject () {
        
        //initialise Medication Slot object
        if (medicationSlot == nil) {
            medicationSlot = DCMedicationSlot.init()
        }
        if(medicationSlot?.medicationAdministration == nil) {
            medicationSlot?.medicationAdministration = DCMedicationAdministration.init()
            medicationSlot?.medicationAdministration.checkingUser = DCUser.init()
            medicationSlot?.medicationAdministration.administratingUser = DCUser.init()
            medicationSlot?.medicationAdministration.scheduledDateTime = medicationSlot?.time
        }
    }
    
    func resetSavedAdministrationDetails () {
        
        //reset saved administration details
        medicationSlot?.medicationAdministration = nil
    }
    
    func checkIfAdministrationIsEarly () {
        
        //check if administration is early
        let currentSystemDate : NSDate = DCDateUtility.dateInCurrentTimeZone(NSDate())
        let nextMedicationTimeInterval : NSTimeInterval? = (medicationSlot?.time)!.timeIntervalSinceDate(currentSystemDate)
        if (nextMedicationTimeInterval  >= 60*60) {
            // is early administration
            medicationSlot?.medicationAdministration.isEarlyAdministration = true
            //display early administration error message
        } else {
            medicationSlot?.medicationAdministration.isEarlyAdministration = false
        }
    }
    
    func checkIfFrequentAdministrationForWhenRequiredMedication () {
        
        //check if frequent administration for when required medication
        if medicationSlotsArray.count > 1 {
            let previousMedicationSlot : DCMedicationSlot? = medicationSlotsArray[medicationSlotsArray.count - 2]
            let currentSystemDate : NSDate = DCDateUtility.dateInCurrentTimeZone(NSDate())
            let nextMedicationTimeInterval : NSTimeInterval? = currentSystemDate.timeIntervalSinceDate((previousMedicationSlot?.time)!)
            if (nextMedicationTimeInterval <= 2*60*60) {
                medicationSlot?.medicationAdministration.isEarlyAdministration = true
                medicationSlot?.medicationAdministration.isWhenRequiredEarlyAdministration = true
            } else {
                medicationSlot?.medicationAdministration.isEarlyAdministration = false
                medicationSlot?.medicationAdministration.isWhenRequiredEarlyAdministration = false
            }
        } else {
            medicationSlot?.medicationAdministration.isEarlyAdministration = false
            medicationSlot?.medicationAdministration.isWhenRequiredEarlyAdministration = false
        }
    }
    
    func fetchAdministersAndPrescribersList () {
        
        //fetch administers and prescribers list
        usersListWebService = DCUsersListWebService.init()
        usersListWebService!.getUsersListWithCallback { (users, error) -> Void in
            if (error == nil) {
                for userDictionary in users {
                    let displayName = userDictionary[DISPLAY_NAME_KEY] as! String?
                    let identifier = userDictionary[IDENTIFIER_KEY] as! String?
                    let user : DCUser = DCUser.init()
                    user.displayName = displayName
                    user.userIdentifier = identifier
                    self.userListArray! .addObject(user)
                }
                let selfAdministratedPatientName = SELF_ADMINISTERED_TITLE
                let selfAdministratedPatientIdentifier = EMPTY_STRING
                self.selfAdministratedUser = DCUser.init()
                self.selfAdministratedUser!.displayName = selfAdministratedPatientName
                self.selfAdministratedUser!.userIdentifier = selfAdministratedPatientIdentifier
                self.userListArray!.insertObject(self.selfAdministratedUser!, atIndex: 0)
                self.medicationSlot?.medicationAdministration?.administratingUser = self.selfAdministratedUser
                self.medicationSlot?.medicationAdministration?.isSelfAdministered = true
                self.administerTableView.reloadData()
            }
        }
     }
    
    func validateAndReloadAdministerView() {
        
        //validate and reload administer view
        isValid = false
        if (medicationSlot?.medicationAdministration.status == nil) {
            
        }
        administerTableView.reloadData()
    }
    
    func configureAdministerTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        var administerCell : DCAdministerCell = (administerTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        switch indexPath.section {
            
        case SectionCount.eFirstSection.rawValue:
            if indexPath.row == RowCount.eZerothRow.rawValue {
                administerCell = populatedMedicationStatusTableCellAtIndexPath(administerCell, indexPath: indexPath);
            } else {
                if (medicationSlot?.medicationAdministration?.status == ADMINISTERED || medicationSlot?.medicationAdministration?.status == STARTED) {
                    administerCell = populatedMedicationDetailsCellForAdministeredStatus(administerCell, indexPath: indexPath)
                }
                else if (medicationSlot?.medicationAdministration?.status == REFUSED) {
                    administerCell = medicationDetailsCellForRefusedStatus(administerCell, indexPath: indexPath)
                }
            }
            break
        default:
            break;
        }
        return administerCell
    }
    
    func populatedMedicationDetailsCellForAdministeredStatus(cell : DCAdministerCell, indexPath: NSIndexPath) -> (DCAdministerCell) {
        
        switch indexPath.row {
        case RowCount.eFirstRow.rawValue:
            //administered by cell
            cell.titleLabel.text = NSLocalizedString("ADMINISTERED_BY", comment: "administered by title")
            cell.detailLabel.text = (medicationSlot?.medicationAdministration?.administratingUser?.displayName != nil) ? (medicationSlot?.medicationAdministration?.administratingUser?.displayName) : DEFAULT_DOCTOR_NAME
            break
        case RowCount.eSecondRow.rawValue:
            cell.titleLabel.text = NSLocalizedString("DATE_TIME", comment: "date and time")
            let dateString : String
            if let date = medicationSlot?.medicationAdministration.actualAdministrationTime {

                dateString = DCDateUtility.dateStringFromDate(DCDateUtility.dateInCurrentTimeZone(date), inFormat: ADMINISTER_DATE_TIME_FORMAT)
            } else {
                dateString = DCDateUtility.dateStringFromDate(DCDateUtility.dateInCurrentTimeZone(NSDate()), inFormat: ADMINISTER_DATE_TIME_FORMAT)
            }
            cell.detailLabel.text = dateString
            break
        case RowCount.eThirdRow.rawValue,RowCount.eFourthRow.rawValue:

            //present inline picker here
            cell.titleLabel.text = NSLocalizedString("CHECKED_BY", comment: "Checked by title")
            cell.detailLabel.text = (medicationSlot?.medicationAdministration?.checkingUser?.displayName != nil) ? (medicationSlot?.medicationAdministration?.checkingUser?.displayName) : EMPTY_STRING
            break;
        default:
            break
        }
        return cell
    }
    
    func medicationDetailsCellForRefusedStatus(cell : DCAdministerCell, indexPath: NSIndexPath) -> (DCAdministerCell) {
        
        //select date when medication status is refused
        cell.titleLabel.text = NSLocalizedString("DATE_TIME", comment: "date and time")
        let dateString : String
        if let date = medicationSlot?.medicationAdministration.actualAdministrationTime {

            dateString = DCDateUtility.dateStringFromDate(DCDateUtility.dateInCurrentTimeZone(date), inFormat: ADMINISTER_DATE_TIME_FORMAT)
        } else {
            dateString = DCDateUtility.dateStringFromDate(DCDateUtility.dateInCurrentTimeZone(NSDate()), inFormat: ADMINISTER_DATE_TIME_FORMAT)
        }
        cell.detailLabel.text = dateString
        return cell
    }
    
    func batchNumberOrExpiryDateTableCellAtIndexPath(indexPath: NSIndexPath) -> (DCBatchNumberCell) {
        
        //batch number or expiry field
        let expiryCell : DCBatchNumberCell = (administerTableView.dequeueReusableCellWithIdentifier(BATCH_NUMBER_CELL_ID) as? DCBatchNumberCell)!
        expiryCell.batchDelegate = self
        expiryCell.selectedIndexPath = indexPath
        return expiryCell;
    }
    
    func populatedMedicationStatusTableCellAtIndexPath(cell : DCAdministerCell, indexPath: NSIndexPath) -> (DCAdministerCell) {
        
        switch indexPath.row {
        case RowCount.eZerothRow.rawValue:
            //status cell
            cell.titleLabel.text = NSLocalizedString("STATUS", comment: "status title text")
            if (medicationSlot?.medicationAdministration?.status != nil) {
                cell.titleLabel.textColor = UIColor(forHexString: "#676767")
                cell.detailLabel.text = medicationSlot?.medicationAdministration?.status
            } else {
                if(saveClicked == true) {
                    cell.titleLabel.textColor = UIColor.redColor()
                } else {
                    cell.titleLabel.textColor = UIColor(forHexString: "#676767")
                }
            }
            return cell
        default:
            return cell
        }
    }
    
    func notesTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCNotesTableCell) {
        
        //notes cell
        let notesCell : DCNotesTableCell = (administerTableView.dequeueReusableCellWithIdentifier(NOTES_CELL_ID) as? DCNotesTableCell)!
        notesCell.selectedIndexPath = indexPath
        notesCell.delegate = self
        return notesCell
    }
        
    func displayPrescribersAndAdministersViewAtIndexPath (indexPath : NSIndexPath) {
        
        popOverIndexPath = indexPath
        let namesViewController : DCNameSelectionTableViewController? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(NAMES_LIST_VIEW_STORYBOARD_ID) as? DCNameSelectionTableViewController
        namesViewController?.namesDelegate = self
        if (indexPath.row == RowCount.eFirstRow.rawValue) {
            namesViewController?.title = ADMINISTRATED_BY
            namesViewController?.namesArray = userListArray
            namesViewController!.previousSelectedValue = medicationSlot?.medicationAdministration?.administratingUser?.displayName
        } else {
            namesViewController?.title = CHECKED_BY
            let checkedByList : NSMutableArray = []
            checkedByList.addObjectsFromArray(userListArray! as [AnyObject])
            if (self.selfAdministratedUser != nil) {
                checkedByList.removeObject(self.selfAdministratedUser!)
            }
            namesViewController?.namesArray = checkedByList
           namesViewController!.previousSelectedValue = medicationSlot?.medicationAdministration?.checkingUser?.displayName
        }
        self.navigationController!.pushViewController(namesViewController!,animated: true)
    }
    
    func presentAdministratedStatusPopOverAtIndexPath (indexPath : NSIndexPath) {
        
        let statusViewController : DCAdministrationStatusTableViewController? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(STATUS_LIST_VIEW_SB_ID) as? DCAdministrationStatusTableViewController
        statusViewController?.previousSelectedValue = medicationSlot?.medicationAdministration?.status
        statusViewController?.medicationStatusDelegate = self
        statusViewController?.status = self.status as! String
        statusViewController?.title = NSLocalizedString("STATUS", comment: "")
        self.navigationController!.pushViewController(statusViewController!, animated: true)
    }

    func datePickerCellAtIndexPath(indexPath : NSIndexPath) -> DCAdministerPickerCell {
        
        var pickerCell = administerTableView.dequeueReusableCellWithIdentifier(ADMINISTER_PICKER_CELL_ID) as? DCAdministerPickerCell
        if (pickerCell == nil) {
            let bundle = NSBundle(forClass: self.dynamicType)
            let nib = UINib(nibName: "DCAdministerPickerCell", bundle: bundle)
            pickerCell = nib.instantiateWithOwner(self, options: nil)[0] as? DCAdministerPickerCell
        }
        pickerCell?.delegate = self
        return pickerCell!
    }
    
    func isMedicationDurationBasedInfusion () -> Bool {
        // T0 Do : This is a temporary method to implement the status display for the duration based infusion , when the API gets updated - modifications needed.
        if (medicationDetails?.route == "Subcutaneous" || medicationDetails?.route == "Intravenous"){
            return true
        } else {
            return false
        }
    }
    
    func populatedAdministeredTableViewCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == SectionCount.eSecondSection.rawValue && indexPath.row == RowCount.eZerothRow.rawValue) {
            let batchNumberCell : DCBatchNumberCell = batchNumberOrExpiryDateTableCellAtIndexPath(indexPath)
            return batchNumberCell
        } else if (indexPath.section == SectionCount.eThirdSection.rawValue) {
            let notesCell : DCNotesTableCell = notesTableCellAtIndexPath(indexPath)
            notesCell.notesType = eNotes
            notesCell.notesTextView.textColor = (!isValid && medicationSlot?.medicationAdministration?.isEarlyAdministration == true) ? UIColor.redColor() : UIColor(forHexString: "#8f8f95")

            if let administrationNotes =  medicationSlot?.medicationAdministration.administeredNotes {
                notesCell.notesTextView.text = administrationNotes
            } else {
                notesCell.notesTextView.text = notesCell.hintText()
            }
            return notesCell
        } else {
            if (indexPath.section == SectionCount.eFirstSection.rawValue && datePickerIndexPath != nil && indexPath.row == 3) {
                //display picker
                let pickerCell : DCAdministerPickerCell = datePickerCellAtIndexPath(indexPath)
                return pickerCell
            } else {
                let administerCell : DCAdministerCell = configureAdministerTableCellAtIndexPath(indexPath)
                return administerCell
            }
        }
    }
    
    func populatedOmittedTableViewCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        //omitted cell status
        if (indexPath.section == SectionCount.eSecondSection.rawValue) {
            let notesCell : DCNotesTableCell = notesTableCellAtIndexPath(indexPath)
            notesCell.notesType = eReason
            notesCell.notesTextView.textColor = !isValid ? UIColor.redColor() : UIColor(forHexString: "#8f8f95")
            if let notes =  medicationSlot?.medicationAdministration.omittedNotes {
                notesCell.notesTextView.text = notes
            } else {
                notesCell.notesTextView.text = notesCell.hintText()
            }
            return notesCell
        } else {
            let administerCell : DCAdministerCell = configureAdministerTableCellAtIndexPath(indexPath)
            return administerCell
        }
    }
    
    func populatedRefusedTableCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == SectionCount.eSecondSection.rawValue) {
            let notesCell : DCNotesTableCell = notesTableCellAtIndexPath(indexPath)
            notesCell.notesType = eReason 
            notesCell.notesTextView.textColor = (!isValid && medicationSlot?.medicationAdministration?.isEarlyAdministration == true) ? UIColor.redColor() : UIColor(forHexString: "#8f8f95")
            if let notes =  medicationSlot?.medicationAdministration.refusedNotes {
                notesCell.notesTextView.text = notes
            } else {
                notesCell.notesTextView.text = notesCell.hintText()
            }
            return notesCell
        } else {
            if (indexPath.section == SectionCount.eFirstSection.rawValue && datePickerIndexPath != nil && indexPath.row == RowCount.eSecondRow.rawValue) {
                //display picker
                let pickerCell : DCAdministerPickerCell = datePickerCellAtIndexPath(indexPath)
                return pickerCell
            } else {
                let administerCell : DCAdministerCell = configureAdministerTableCellAtIndexPath(indexPath)
                return administerCell
            }
        }
    }
    
    func loadMedicationDetailsSectionForSelectedIndexPath(indexPath : NSIndexPath) {
        
        //medication details section display
        let administerIndexPath : NSIndexPath = NSIndexPath(forRow: RowCount.eFirstRow.rawValue, inSection: indexPath.section)
        let omittedIndexpath : NSIndexPath = NSIndexPath(forItem: RowCount.eSecondRow.rawValue, inSection: indexPath.section)
        let refusedIndexPath : NSIndexPath = NSIndexPath(forItem: RowCount.eThirdRow.rawValue, inSection: indexPath.section)
        let indexPathsArray : [NSIndexPath] = [administerIndexPath, omittedIndexpath, refusedIndexPath]
        switch indexPath.row {
        case RowCount.eZerothRow.rawValue:
            //display status views, insert views below this
            if (statusCellSelected == false) {
                statusCellSelected = true
                administerTableView.insertRowsAtIndexPaths(indexPathsArray, withRowAnimation: .Automatic)
            } else {
                statusCellSelected = false
            }
            break
        case RowCount.eFirstRow.rawValue:
            medicationSlot?.medicationAdministration.status = ADMINISTERED
            statusCellSelected = false
            break
        case RowCount.eSecondRow.rawValue:
            medicationSlot?.medicationAdministration.status = REFUSED
            statusCellSelected = false
            break
        case RowCount.eThirdRow.rawValue:
            medicationSlot?.medicationAdministration.status = OMITTED
            statusCellSelected = false
            break
        default:
            break
        }
        administerTableView .reloadData()
    }
    
    // MARK: Date Picker Methods
    
    func hasPickerForIndexPath(indexPath : NSIndexPath) -> Bool {
        
        var hasDatePicker : Bool = false
        var targetedRow : NSInteger = indexPath.row
        targetedRow++
        let checkDatePickerCell : UITableViewCell? = administerTableView.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection: indexPath.section))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(DATE_PICKER_CELL_TAG) as? UIDatePicker
        hasDatePicker = (checkDatePicker != nil) ? true : false
        return hasDatePicker
    }
    
    func hasInlineDatePicker() -> Bool {
        
        return(datePickerIndexPath != nil)
    }
    
    func indexPathHasPicker(indexPath : NSIndexPath) -> Bool {
        
        let pickerCellPresent = (datePickerIndexPath?.row == indexPath.row)
        if ((hasInlineDatePicker() == true) && (pickerCellPresent == true)) {
            return true
        } else {
            return false
        }
    }
    
    func toggleDatePickerForSelectedIndexPath(indexPath : NSIndexPath) {
        
        administerTableView.beginUpdates()
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)]
        // check if 'indexPath' has an attached date picker below it
        if (hasPickerForIndexPath(indexPath) == true) {
            // found a picker below it, so remove it
            administerTableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            // didn't find a picker below it, so we should insert it
            administerTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        }
        administerTableView.endUpdates()
    }

    func displayInlineDatePickerForRowAtIndexPath(indexPath : NSIndexPath) {
        
        // display the date picker inline with the table content
        administerTableView.beginUpdates()
        var before : Bool = false
        if (hasInlineDatePicker()) {
            before = datePickerIndexPath?.row < indexPath.row
        }
        var sameCellClicked = false
        if (hasInlineDatePicker()) {
            sameCellClicked = ((datePickerIndexPath?.row)! - 1 == indexPath.row)
            administerTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row + 1, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Fade)
            datePickerIndexPath = nil
        }
        if (sameCellClicked == false) {
            // hide the old date picker and display the new one
            let rowToReveal : NSInteger = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal : NSIndexPath = NSIndexPath(forRow: rowToReveal, inSection: 1)
            toggleDatePickerForSelectedIndexPath(indexPath)
            datePickerIndexPath = NSIndexPath(forRow: indexPathToReveal.row + 1, inSection: indexPathToReveal.section)
        }
        // always deselect the row containing the start or end date
        administerTableView.deselectRowAtIndexPath(indexPath, animated: true)
        administerTableView.endUpdates()
    }
    
    // MARK: TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (alertMessage != EMPTY_STRING) {
            return 0
        } else {

            if (medicationSlot?.medicationAdministration?.status == OMITTED) {
                return OMITTED_SECTION_COUNT;
            } else if (medicationSlot?.medicationAdministration?.status == ADMINISTERED || medicationSlot?.medicationAdministration?.status == STARTED) {
                return ADMINISTERED_SECTION_COUNT;
            } else if (medicationSlot?.medicationAdministration?.status == REFUSED){
                return REFUSED_SECTION_COUNT;
            }else {
                return 2
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case SectionCount.eZerothSection.rawValue:
            return 1
        case SectionCount.eFirstSection.rawValue:
            var rowCount = 1
            if (medicationSlot?.medicationAdministration?.status == REFUSED) {
                rowCount = 2
                if (hasInlineDatePicker()) {
                    rowCount++
                }
            }else if (medicationSlot?.medicationAdministration?.status == ADMINISTERED || medicationSlot?.medicationAdministration?.status == STARTED){
                rowCount = ADMINISTERED_SECTION_ROW_COUNT
                if (hasInlineDatePicker()) {
                    rowCount++
                }
            }
            return rowCount
        case SectionCount.eSecondSection.rawValue:
            return 1
        case SectionCount.eThirdSection.rawValue:
            return NOTES_SECTION_ROW_COUNT
        default:
            break;
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0 :
            if self.isMedicationDurationBasedInfusion() {
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
        default:
                if (medicationSlot?.medicationAdministration?.status == ADMINISTERED || medicationSlot?.medicationAdministration?.status == STARTED) {
                    //configure tablecells for medication status administered
                    let administeredTableCell = populatedAdministeredTableViewCellAtIndexPath(indexPath)
                    saveButton?.enabled = true
                    return administeredTableCell
                } else if (medicationSlot?.medicationAdministration?.status == OMITTED) {
                    let omittedTableCell = populatedOmittedTableViewCellAtIndexPath(indexPath)
                    saveButton?.enabled = true
                    return omittedTableCell
                } else if (medicationSlot?.medicationAdministration?.status == REFUSED){
                    //refused status
                    let refusedTableCell = populatedRefusedTableCellAtIndexPath(indexPath)
                    saveButton?.enabled = true
                    return refusedTableCell
                } else if (medicationSlot?.medicationAdministration?.status == ENDED || medicationSlot?.medicationAdministration?.status == PAUSED){
                    var administerCell : DCAdministerCell = (administerTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
                    administerCell = populatedMedicationStatusTableCellAtIndexPath(administerCell, indexPath: indexPath);
                    return administerCell
                } else {
                    let administerCell : DCAdministerCell = (administerTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
                    administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                    if self.isMedicationDurationBasedInfusion() && status == IN_PROGRESS{
                        administerCell.titleLabel.text = "Status Change"
                    } else {
                        administerCell.titleLabel.text = NSLocalizedString("STATUS", comment: "status title text")
                    }
                    administerCell.detailLabel.text = EMPTY_STRING
                    if(saveClicked == true && medicationSlot?.medicationAdministration?.status == nil) {
                        administerCell.titleLabel.textColor = UIColor.redColor()
                    } else {
                        saveButton?.enabled = false
                        administerCell.titleLabel.textColor = UIColor(forHexString: "#676767")
                    }
                    return administerCell
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionIndex : NSInteger = numberOfSectionsInTableView(tableView)
        if (section == sectionIndex - 1 && sectionIndex != 2) {
            return (medicationSlot?.medicationAdministration?.isEarlyAdministration == true) ? MEDICATION_DETAILS_SECTION_HEIGHT : TABLEVIEW_DEFAULT_SECTION_HEIGHT
        } else if (section == SectionCount.eFirstSection.rawValue) {
            return MEDICATION_DETAILS_SECTION_HEIGHT
        } else if (section == SectionCount.eThirdSection.rawValue) {
            return TABLEVIEW_DEFAULT_SECTION_HEIGHT
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            return UITableViewAutomaticDimension
        case SectionCount.eFirstSection.rawValue :
            if indexPath.row == RowCount.eZerothRow.rawValue {
                return TABLE_CELL_DEFAULT_HEIGHT
            } else {
                if (medicationSlot?.medicationAdministration.status == OMITTED) {
                    return NOTES_CELL_HEIGHT
                } else if (medicationSlot?.medicationAdministration.status == ADMINISTERED || medicationSlot?.medicationAdministration?.status == STARTED) {
                    return (indexPath.row == RowCount.eThirdRow.rawValue && hasInlineDatePicker()) ? DATE_PICKER_VIEW_CELL_HEIGHT : TABLE_CELL_DEFAULT_HEIGHT
                } else {
                    //refused status
                    return (indexPath.row == RowCount.eSecondRow.rawValue && hasInlineDatePicker()) ? DATE_PICKER_VIEW_CELL_HEIGHT : TABLE_CELL_DEFAULT_HEIGHT
                }
            }
        case SectionCount.eSecondSection.rawValue:
            if (medicationSlot?.medicationAdministration.status == REFUSED) {
                return NOTES_CELL_HEIGHT
            }else if (medicationSlot?.medicationAdministration.status == OMITTED) {
                return NOTES_CELL_HEIGHT
            }  else {
                return TABLE_CELL_DEFAULT_HEIGHT
            }
        case SectionCount.eThirdSection.rawValue:
            return NOTES_CELL_HEIGHT
        default:
            return TABLE_CELL_DEFAULT_HEIGHT
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionCount : NSInteger = numberOfSectionsInTableView(tableView)
        let administerHeaderView = NSBundle.mainBundle().loadNibNamed(ADMINISTER_HEADER_VIEW_NIB, owner: self, options: nil)[0] as? DCAdministerTableHeaderView
        administerHeaderView!.timeLabel.hidden = true
        if (section == sectionCount - 1 && sectionCount != 2) {
            if (medicationSlot?.medicationAdministration.status == OMITTED){
                let errorMessage = NSString(format: "%@", NSLocalizedString("OMMITED_REQUIRE_REASON", comment:""))
                administerHeaderView?.populateHeaderViewWithErrorMessage(errorMessage as String)
                return administerHeaderView
            }
            if (medicationSlot?.medicationAdministration?.isEarlyAdministration == true) {
                if (medicationSlot?.medicationAdministration?.isWhenRequiredEarlyAdministration == true) {
                    let errorMessage = NSString(format: "%@ %@", NSLocalizedString("ADMIN_FREQUENCY", comment: "when required new medication is given 2 hrs before previous one"), NSLocalizedString("EARLY_ADMIN_INLINE", comment: ""))
                    administerHeaderView?.populateHeaderViewWithErrorMessage(errorMessage as String)
                    return administerHeaderView
                } else {
                    administerHeaderView?.populateHeaderViewWithErrorMessage(NSLocalizedString("EARLY_ADMIN_INLINE", comment: "early administration when medication is attempted 1 hr before scheduled time"))
                    return administerHeaderView
                }
            }
        }
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        administerTableView.deselectRowAtIndexPath(indexPath, animated: true)
        administerTableView.resignFirstResponder()
        if (indexPath.section == SectionCount.eZerothSection.rawValue) {
            addBNFView()
        }
        if (indexPath.section == SectionCount.eFirstSection.rawValue) {
            if indexPath.row == RowCount.eZerothRow.rawValue {
                presentAdministratedStatusPopOverAtIndexPath(indexPath)
            } else {
                if (medicationSlot?.medicationAdministration.status == ADMINISTERED || medicationSlot?.medicationAdministration?.status == STARTED) {
                    if (indexPath.row == RowCount.eSecondRow.rawValue) {
                        displayInlineDatePickerForRowAtIndexPath(indexPath)
                    } else {
                        displayPrescribersAndAdministersViewAtIndexPath(indexPath)
                    }
                } else if (medicationSlot?.medicationAdministration.status == REFUSED) {
                    if (indexPath.row == RowCount.eFirstRow.rawValue) {
                        displayInlineDatePickerForRowAtIndexPath(indexPath)
                    }
                }
            }
        }
    }
    
    
    // MARK: BatchNumberCellDelegate Methods
    
     func batchNumberFieldSelectedAtIndexPath(indexPath: NSIndexPath) {
        let pickerIndexPath :NSIndexPath = NSIndexPath(forRow: 2, inSection: 1)
        editingIndexPath = indexPath
        if hasInlineDatePicker() {
            UIView.animateWithDuration(0.0, animations: {
                self.displayInlineDatePickerForRowAtIndexPath(pickerIndexPath)
                }, completion: {
                    (value: Bool) in
                    self.administerTableView.setContentOffset(CGPointMake(0,180), animated: true)
            })
        } else {
            self.administerTableView.setContentOffset(CGPointMake(0,180), animated: true)
        }
    }
    
    func enteredBatchDetails(batch : String) {
        
        medicationSlot?.medicationAdministration?.batch = batch
    }
    
    // MARK: NotesCell Delegate Methods
    
    func notesSelected(editing : Bool, withIndexPath indexPath : NSIndexPath) {
        
        editingIndexPath = indexPath
        var pickerIndexPath :NSIndexPath
        if(self.medicationSlot?.medicationAdministration?.status == ADMINISTERED || medicationSlot?.medicationAdministration?.status == STARTED) {
            pickerIndexPath = NSIndexPath(forRow: 2, inSection: 1)
        } else {
            pickerIndexPath = NSIndexPath(forRow: 1, inSection: 1)
        }
        if hasInlineDatePicker() {
            UIView.animateWithDuration(0.0, animations: {
                self.displayInlineDatePickerForRowAtIndexPath(pickerIndexPath)
                }, completion: {
                    (value: Bool) in
                    if(self.medicationSlot?.medicationAdministration?.status == ADMINISTERED || self.medicationSlot?.medicationAdministration?.status == STARTED) {
                        self.administerTableView.setContentOffset(CGPointMake(0, 300), animated: true)
                    } else {
                        self.administerTableView.setContentOffset(CGPointMake(0, 100), animated: true)
                    }
            })
        } else {
            if(self.medicationSlot?.medicationAdministration?.status == ADMINISTERED || medicationSlot?.medicationAdministration?.status == STARTED) {
                self.administerTableView.setContentOffset(CGPointMake(0, 300), animated: true)
            } else {
                self.administerTableView.setContentOffset(CGPointMake(0, 100), animated: true)
            }        }
        if (editing == true && keyboardHeight != nil) {
            //animateAdministerTableViewUpWhenKeyboardShows()
        }
    }
    
    func enteredNote(note : String) {
        
        if(medicationSlot?.medicationAdministration?.status == ADMINISTERED || medicationSlot?.medicationAdministration?.status == STARTED) {
            medicationSlot?.medicationAdministration?.administeredNotes = note
        } else if (medicationSlot?.medicationAdministration?.status == REFUSED) {
            medicationSlot?.medicationAdministration?.refusedNotes = note
        } else {
            medicationSlot?.medicationAdministration?.omittedNotes = note
        }
    }
    
    // mark :StatusList Delegate Methods 
    
    func selectedMedicationStatusEntry(status: String!) {
        saveClicked = false
        isValid = true
        if status == ADMINISTERED {
            medicationSlot?.medicationAdministration.status = ADMINISTERED
        } else if status == REFUSED {
            medicationSlot?.medicationAdministration.status = REFUSED
        } else if status == OMITTED{
            medicationSlot?.medicationAdministration.status = OMITTED
        }else {
            medicationSlot?.medicationAdministration.status = status
        }
        administerTableView .reloadData()
    }
    
    // MARK: NamesList Delegate Methods
    
    func selectedUserEntry(user : DCUser!) {
            if (popOverIndexPath?.row == RowCount.eFirstRow.rawValue) {
                //administered by
                medicationSlot?.medicationAdministration?.administratingUser = user
                if user.displayName != SELF_ADMINISTERED {
                    medicationSlot?.medicationAdministration?.isSelfAdministered = false
                }
            } else {
                //checked by
                if (user == DEFAULT_NURSE_NAME) {
                    medicationSlot?.medicationAdministration?.checkingUser = user
                } else {
                    var selectedUser = DCUser.init()
                    selectedUser = user
                    self.performSelector("displaySecurityPinEntryViewForUser:", withObject:selectedUser , afterDelay: 0.5)
                }
            }
        administerTableView .reloadData()
    }
    
    func displaySecurityPinEntryViewForUser(user : DCUser ) {
        let securityPinViewController : DCAdministratedByPinVerificationViewController? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(SECURITY_PIN_VIEW_CONTROLLER) as? DCAdministratedByPinVerificationViewController
        securityPinViewController?.delegate = self
        securityPinViewController?.user = user
        securityPinViewController?.transitioningDelegate = securityPinViewController
        securityPinViewController?.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        securityPinViewController!.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(SECURITY_PIN_VIEW_ALPHA)
        securityPinViewController!.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.presentViewController(securityPinViewController!, animated: true, completion: nil)
    }
    
    // MARK:AdministerPickerCellDelegate Methods
    
    func newDateValueSelected(newDate : NSDate) {
        if (datePickerIndexPath != nil) {
            if (datePickerIndexPath?.row == RowCount.eThirdRow.rawValue || datePickerIndexPath?.row == RowCount.eSecondRow.rawValue) {
                medicationSlot?.medicationAdministration.actualAdministrationTime = newDate
                if medicationSlot?.medicationAdministration.status == ADMINISTERED || medicationSlot?.medicationAdministration?.status == STARTED {
                    administerTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:RowCount.eSecondRow.rawValue, inSection: datePickerIndexPath!.section)], withRowAnimation: UITableViewRowAnimation.None)
                } else {
                    administerTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:RowCount.eFirstRow.rawValue, inSection: datePickerIndexPath!.section)], withRowAnimation: UITableViewRowAnimation.None)
                }
            }
        }
    }
    
    //MARK : Security pin Match Delegate
    func securityPinMatchedForUser(user: DCUser) {
        
        medicationSlot?.medicationAdministration?.checkingUser = user
        print(popOverIndexPath?.row)
        if hasInlineDatePicker() {
            let pickerIndexPath :NSIndexPath = NSIndexPath(forRow: 4, inSection: 1)
            administerTableView.reloadRowsAtIndexPaths([pickerIndexPath], withRowAnimation: UITableViewRowAnimation.None)
        } else {
            administerTableView.reloadRowsAtIndexPaths([popOverIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    
    //MARK : Keyboard Delegate Methods
    
    func animateAdministerTableViewUpWhenKeyboardShows() {
        
        //view handling on keyboard appear
        if (editingIndexPath != nil) {
            var editedAreaHeight : CGFloat = 0.0
            var topConstraint : CGFloat = 0.0
            if (medicationSlot?.medicationAdministration?.status == REFUSED) {
                editedAreaHeight =  TABLEVIEW_DEFAULT_SECTION_HEIGHT*(CGFloat)(((editingIndexPath?.section)!+1))*(CGFloat)(OMITTED_SECTION_COUNT) + TABLE_CELL_DEFAULT_HEIGHT*(CGFloat)(3)
                if (editedAreaHeight > keyboardHeight!/2) {
                    topConstraint = 0 - keyboardHeight!/4
                }
            } else if (medicationSlot?.medicationAdministration?.status == OMITTED) {
                editedAreaHeight =  TABLEVIEW_DEFAULT_SECTION_HEIGHT*(CGFloat)(((editingIndexPath?.section)!+1))*(CGFloat)(OMITTED_SECTION_COUNT) + TABLE_CELL_DEFAULT_HEIGHT*(CGFloat)(2)
                if (editedAreaHeight > keyboardHeight!/2) {
                    topConstraint = 0 - keyboardHeight!/4
                }
            } else {
                editedAreaHeight =  TABLEVIEW_DEFAULT_SECTION_HEIGHT*(CGFloat)(((editingIndexPath?.section)!+1))*(CGFloat)(OMITTED_SECTION_COUNT)
                if (editingIndexPath?.row == 0) {
                    editedAreaHeight += TABLE_CELL_DEFAULT_HEIGHT*(CGFloat)(6)
                    if (editedAreaHeight > keyboardHeight!/2) {
                        topConstraint = 0 - keyboardHeight!/2
                    }
                } else {
                    editedAreaHeight += TABLE_CELL_DEFAULT_HEIGHT*(CGFloat)(5)
                    if (editedAreaHeight > keyboardHeight!/2) {
                        topConstraint = 0 - keyboardHeight!/4
                    }
                }
            }
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                print(topConstraint)
//              self.administerTableViewTopConstraint.constant = topConstraint
            })
        }
    }
    
    func keyboardDidShow(notification : NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                keyboardHeight = keyboardSize.height
                //animateAdministerTableViewUpWhenKeyboardShows()
            }
        }
    }
    
    func addBNFView () {
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        let bnfViewController : DCBNFViewController? = administerStoryboard!.instantiateViewControllerWithIdentifier(BNF_STORYBOARD_ID) as? DCBNFViewController
        self.navigationController?.pushViewController(bnfViewController!, animated: true)
    }
    
    func keyboardDidHide(notification : NSNotification) {
        
        editingIndexPath = nil
    }
    
    func saveButtonPressed() {
        
        //perform administer medication api call here
        self.saveClicked = true
        if(entriesAreValid()) {
            self.activityIndicator.startAnimating()
            self.isValid = true
            self.callAdministerMedicationWebService()
        } else {
            // show entries in red
            self.validateAndReloadAdministerView()
        }
    }
    
    func cancelButtonPressed() {
        
        self.resetSavedAdministrationDetails()
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    //MARK: API Integration
    func medicationAdministrationDictionary() -> NSDictionary {
        
        let administerDictionary : NSMutableDictionary = [:]
        let scheduledDateString : NSString
        if (self.medicationSlot?.medicationAdministration?.scheduledDateTime != nil) {
            scheduledDateString = DCDateUtility.dateStringFromDate(medicationSlot?.medicationAdministration?.scheduledDateTime, inFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        } else {
            scheduledDateString = DCDateUtility.dateStringFromDate(NSDate(), inFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        }
        administerDictionary.setValue(scheduledDateString, forKey:SCHEDULED_ADMINISTRATION_TIME)
        let dateFormatter : NSDateFormatter = NSDateFormatter.init()
        dateFormatter.dateFormat = EMIS_DATE_FORMAT
        if (medicationSlot?.medicationAdministration?.actualAdministrationTime != nil) {
            let administeredDateString : NSString = dateFormatter.stringFromDate((medicationSlot?.medicationAdministration?.actualAdministrationTime)!)
            administerDictionary.setValue(administeredDateString, forKey:ACTUAL_ADMINISTRATION_TIME)
        } else {
            administerDictionary.setValue(dateFormatter.stringFromDate(NSDate()), forKey:ACTUAL_ADMINISTRATION_TIME)
            medicationSlot?.medicationAdministration?.actualAdministrationTime = DCDateUtility.dateInCurrentTimeZone(NSDate())
        }
        // To Do : for the sake of display of infusions , untill the API gets updated, this value need to be changed dynamic.
        var adminStatus = medicationSlot?.medicationAdministration?.status
        if (adminStatus == STARTED) {
            medicationSlot?.medicationAdministration?.status = IN_PROGRESS
            adminStatus = ADMINISTERED
        }
        administerDictionary.setValue(adminStatus, forKey: ADMINISTRATION_STATUS)
        if let administratingStatus : Bool = medicationSlot?.medicationAdministration?.isSelfAdministered.boolValue {
            if administratingStatus == false {
                administerDictionary.setValue(medicationSlot?.medicationAdministration?.administratingUser!.userIdentifier, forKey:"AdministratingUserIdentifier")
            }
            administerDictionary.setValue(administratingStatus, forKey: IS_SELF_ADMINISTERED)
        }
        //TO DO : Configure the dosage and batch number from the form.
        if let dosage = self.medicationDetails?.dosage {
            administerDictionary.setValue(dosage, forKey: ADMINISTRATING_DOSAGE)
        }
        if let batch = self.medicationSlot?.medicationAdministration?.batch {
            administerDictionary.setValue(batch, forKey: ADMINISTRATING_BATCH)
        }
        let notes : NSString  = administrationNotesBasedOnMedicationStatus ((self.medicationSlot?.medicationAdministration?.status)!)
        administerDictionary.setValue(notes, forKey:ADMINISTRATING_NOTES)
        
        //TODO: currently hardcoded as ther is no expiry field in UI
        // administerDictionary.setValue("2015-10-23T19:40:00.000Z", forKey: EXPIRY_DATE)
        return administerDictionary
    }
    
    func callAdministerMedicationWebService() {
        
        let administerMedicationWebService : DCAdministerMedicationWebService = DCAdministerMedicationWebService.init()
        let parameterDictionary : NSDictionary = medicationAdministrationDictionary()
        administerMedicationWebService.administerMedicationForScheduleId((medicationDetails?.scheduleId)! as String, forPatientId:patientId as String , withParameters:parameterDictionary as [NSObject : AnyObject]) { (array, error) -> Void in
            self.activityIndicator.stopAnimating()
            if error == nil {
                let presentingViewController = self.presentingViewController as! UINavigationController
                let parentView = presentingViewController.presentingViewController as! UINavigationController
                let prescriberMedicationListViewController : DCPrescriberMedicationViewController = parentView.viewControllers.last as! DCPrescriberMedicationViewController
                let administationViewController : DCAdministrationViewController = presentingViewController.viewControllers.last as! DCAdministrationViewController
                administationViewController.activityIndicatorView.startAnimating()
                self.dismissViewControllerAnimated(true, completion: {
                    self.helper.reloadPrescriberMedicationHomeViewControllerWithCompletionHandler({ (Bool) -> Void in
                        prescriberMedicationListViewController.medicationSlotArray = self.medicationSlotsArray
                        prescriberMedicationListViewController.reloadAdministrationScreenWithMedicationDetails()
                        administationViewController.activityIndicatorView.stopAnimating()
                    })
                })
            } else {
                if Int(error.code) == Int(NETWORK_NOT_REACHABLE) {
                    self.displayAlertWithTitle("ERROR", message: NSLocalizedString("INTERNET_CONNECTION_ERROR", comment:""))
                } else if Int(error.code) == Int(WEBSERVICE_UNAVAILABLE)  {
                    self.displayAlertWithTitle("ERROR", message: NSLocalizedString("WEBSERVICE_UNAVAILABLE", comment:""))
                } else {
                    self.displayAlertWithTitle("ERROR", message:"Administration Failed")
                }
            }
        }
    }
    
    func displayAlertWithTitle(title : NSString, message : NSString ) {
        //display alert view for view controllers
        let alertController : UIAlertController = UIAlertController(title: title as String, message: message as String, preferredStyle: UIAlertControllerStyle.Alert)
        let action : UIAlertAction = UIAlertAction(title: OK_BUTTON_TITLE, style: UIAlertActionStyle.Default, handler: { action in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(action)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Return the note string based on the administrating status
    func administrationNotesBasedOnMedicationStatus (status : NSString) -> NSString{
        var noteString : NSString = EMPTY_STRING
        if (status == ADMINISTERED || status == SELF_ADMINISTERED || status == STARTED)  {
            if let administeredNotes = self.medicationSlot?.medicationAdministration?.administeredNotes {
                noteString = administeredNotes
            }
        } else if status == REFUSED {
            if let refusedNotes = self.medicationSlot?.medicationAdministration?.refusedNotes {
                noteString =  refusedNotes
            }
        } else {
            if let omittedNotes = self.medicationSlot?.medicationAdministration?.omittedNotes {
                noteString = omittedNotes
            }
        }
        return noteString
    }
    
    func entriesAreValid() -> (Bool) {
        
        // check if the values entered are valid
        var isValid : Bool = true
        let medicationStatus = self.medicationSlot?.medicationAdministration.status
        //notes will be mandatory always for omitted ones , it will be mandatory for administered/refused for early administration, currently checked for all cases
        if (medicationStatus == OMITTED) {
            //omitted medication status
            let omittedNotes = self.medicationSlot?.medicationAdministration.omittedNotes
            if (omittedNotes == EMPTY_STRING || omittedNotes == nil) {
                isValid = false
            }
        } else if (medicationStatus == nil) {
            isValid = false
        }
        
        if (self.medicationSlot?.medicationAdministration?.isEarlyAdministration == true) {
            
            //early administration condition
            if (medicationStatus == ADMINISTERED || medicationStatus == STARTED) {
                //administered medication status
                let notes : String? = self.medicationSlot?.medicationAdministration?.administeredNotes
                if (notes == EMPTY_STRING || notes == nil) {
                    isValid = false
                }
            } else if (medicationStatus == REFUSED) {
                //refused medication status
                let refusedNotes = self.medicationSlot?.medicationAdministration.refusedNotes
                if (refusedNotes == EMPTY_STRING || refusedNotes == nil) {
                    isValid = false
                }
            }
        }
        return isValid
    }
    
}




