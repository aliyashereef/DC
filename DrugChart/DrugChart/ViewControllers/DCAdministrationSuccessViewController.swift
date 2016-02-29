//
//  DCAdministrationSuccessViewController.swift
//  DrugChart
//
//  Created by aliya on 18/02/16.
//
//

import Foundation

class DCAdministrationSuccessViewController: DCBaseViewController ,NotesCellDelegate,BatchCellDelegate, StatusListDelegate ,reasonDelegate, NamesListDelegate, SecurityPinMatchDelegate{
    
    //MARK: Variables
    
    @IBOutlet weak var administerSuccessTableView: UITableView!
    var medicationSlot : DCMedicationSlot?
    var weekDate : NSDate?
    var medicationDetails : DCMedicationScheduleDetails?
    var datePickerIndexPath : NSIndexPath?
    var administrationSuccessReason: NSString = EMPTY_STRING
    var saveButton: UIBarButtonItem?
    var cancelButton: UIBarButtonItem?
    var userListArray : NSMutableArray? = []
    var previousScrollOffset : CGFloat?
    var dateTimeCellIndexPath : NSIndexPath = NSIndexPath(forRow: 3, inSection: 1)
    var expiryDateCellIndexPath : NSIndexPath = NSIndexPath(forRow: 6, inSection: 1)


    //MARK: View Management Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.userListArray = DCAdministrationHelper.fetchAdministersAndPrescribersList()
        self.configureAdministratingUserForMedicationSlot()
        medicationSlot?.medicationAdministration?.actualAdministrationTime = DCDateUtility.dateInCurrentTimeZone(NSDate())
        configureViewElements()
        initialiseMedicationSlotObject()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        medicationSlot?.medicationAdministration.statusReason = EMPTY_STRING
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.collapseOpenedPickerCell()
    }
    // MARK: Private Methods
    //MARK:
    
    func initialiseMedicationSlotObject () {
        
        //initialise Medication Slot object
        medicationSlot?.medicationAdministration = DCMedicationAdministration.init()
        medicationSlot?.medicationAdministration.statusReason = EMPTY_STRING
        medicationSlot?.medicationAdministration.administratingUser = DCUser.init()
        medicationSlot?.medicationAdministration.checkingUser = DCUser.init()
        medicationSlot?.medicationAdministration.scheduledDateTime = medicationSlot?.time
        medicationSlot?.medicationAdministration?.actualAdministrationTime = DCDateUtility.dateInCurrentTimeZone(NSDate())
    }
    
    func configureTableViewProperties () {
        self.administerSuccessTableView.rowHeight = UITableViewAutomaticDimension
        self.administerSuccessTableView.estimatedRowHeight = 44.0
        self.administerSuccessTableView.tableFooterView = UIView(frame: CGRectZero)
        administerSuccessTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    }
    
    func configureViewElements () {
        configureTableViewProperties()
    }
    
    //MARK: Configuring Table View Cells
    
    //Medication Details Cell
    func medicationDetailsCellAtIndexPath (indexPath :NSIndexPath) -> UITableViewCell {
                
        if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationDetails!){
            let cell = administerSuccessTableView.dequeueReusableCellWithIdentifier("DurationBasedInfusionCell") as? DCDurationBasedMedicationDetailsCell
            if let _ = medicationDetails {
                cell!.configureMedicationDetails(medicationDetails!)
            }
            return cell!
        } else {
            let cell = administerSuccessTableView.dequeueReusableCellWithIdentifier("MedicationDetailsTableViewCell") as? DCMedicationDetailsTableViewCell
            if let _ = medicationDetails {
                cell!.configureMedicationDetails(medicationDetails!)
            }
            return cell!
        }

        }
    
    // Administration Status Cell
    func administrationStatusTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.detailLabelTrailingSpace.constant = 0.0
        administerCell.titleLabel.text = STATUS
        if (medicationSlot!.status != nil) {
            administerCell.detailLabel.text = medicationSlot!.status
            medicationSlot?.medicationAdministration.status = medicationSlot!.status
        } else {
            administerCell.detailLabel.text = medicationSlot!.medicationAdministration.status
        }
        return administerCell
    }
    
    // Checked By Cell
    func administrationCheckedByTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.detailLabelTrailingSpace.constant = 0.0
        if let checkedUser = medicationSlot?.medicationAdministration?.checkingUser?.displayName {
            administerCell.detailLabel?.text = checkedUser
        } else {
            administerCell.detailLabel?.text = EMPTY_STRING
        }
        administerCell.titleLabel.text = "Checked By"
        return administerCell
    }
    
    // Administation reason Cell
    func administrationReasonTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.titleLabel.text = REASON
        administerCell.detailLabelTrailingSpace.constant = 0.0
        administerCell.detailLabel?.text = medicationSlot?.medicationAdministration.statusReason
        return administerCell
    }
    
    //Date Cell
    func administrationDateAndTimeTableCellAtIndexPath(indexPath : NSIndexPath, label: NSString) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.None
        administerCell.titleLabel.text = label as String
        administerCell.detailLabelTrailingSpace.constant = 15.0
        var dateString : String = EMPTY_STRING
        if( label == "Expiry Date") {
            if let date = medicationSlot?.medicationAdministration?.expiryDateTime {
                dateString = DCDateUtility.dateStringFromDate(date, inFormat: BIRTH_DATE_FORMAT)
            }
        } else {
            if let date = medicationSlot?.medicationAdministration?.actualAdministrationTime {
                dateString = DCDateUtility.dateStringFromDate(date, inFormat: ADMINISTER_DATE_TIME_FORMAT)
            }
        }
        administerCell.detailLabel?.text = dateString
        return administerCell
    }
    
    // Notes Cell
    func notesTableCell() -> (DCNotesTableCell) {
        
        let notesCell : DCNotesTableCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(NOTES_CELL_ID) as? DCNotesTableCell)!
        notesCell.notesType = eNotes
        notesCell.delegate = self
        return notesCell
    }
    
    //Batch number or Dose cell
    func batchNumberOrExpiryDateTableCellAtIndexPathWithLabel(indexPath: NSIndexPath, label: NSString) -> (DCBatchNumberCell) {
        
        let expiryCell : DCBatchNumberCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(BATCH_NUMBER_CELL_ID) as? DCBatchNumberCell)!
        expiryCell.batchDelegate = self
        expiryCell.batchNumberTextField.placeholder = label as String
        if label == "Dose" {
            expiryCell.batchNumberTextField?.text = medicationDetails?.dosage
        }
        expiryCell.selectedIndexPath = indexPath
        return expiryCell;
    }
    
    //Date picker Cell
    func datePickerTableCellAtIndexPath (indexPath : NSIndexPath) -> (UITableViewCell) {
        let pickerCell : DCDatePickerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(DATE_STATUS_PICKER_CELL_IDENTIFIER) as? DCDatePickerCell)!
        if indexPath.row == dateTimeCellIndexPath.row + 1 {
            pickerCell.datePicker?.datePickerMode = UIDatePickerMode.DateAndTime
            pickerCell.datePicker?.maximumDate = NSDate()
        } else {
            pickerCell.datePicker?.datePickerMode = UIDatePickerMode.Date
        }
        pickerCell.configureDatePickerProperties()
        pickerCell.selectedDate = { date in
            if indexPath.row == 4 {
                self.medicationSlot!.medicationAdministration.actualAdministrationTime = date
                self.administerSuccessTableView .reloadRowsAtIndexPaths([self.dateTimeCellIndexPath], withRowAnimation:UITableViewRowAnimation.None)
            } else {
                self.medicationSlot!.medicationAdministration.expiryDateTime = date
                self.administerSuccessTableView .reloadRowsAtIndexPaths([self.expiryDateCellIndexPath], withRowAnimation:UITableViewRowAnimation.None)
            }
        }
    return pickerCell;
    }
    
    // MARK: Date Picker Methods
    func hasPickerForIndexPath(indexPath : NSIndexPath) -> Bool {
        
        var hasDatePicker : Bool = false
        var targetedRow : NSInteger = indexPath.row
        targetedRow++
        let checkDatePickerCell : UITableViewCell? = administerSuccessTableView.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection: indexPath.section))
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
        
        administerSuccessTableView.beginUpdates()
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)]
        // check if 'indexPath' has an attached date picker below it
        if (hasPickerForIndexPath(indexPath) == true) {
            // found a picker below it, so remove it
            administerSuccessTableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            // didn't find a picker below it, so we should insert it
            administerSuccessTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        }
        administerSuccessTableView.endUpdates()
    }
    
    func displayInlineDatePickerForRowAtIndexPath(indexPath : NSIndexPath) {
        
        // display the date picker inline with the table content
        administerSuccessTableView.resignFirstResponder()
        administerSuccessTableView.beginUpdates()
        var before : Bool = false
        if (hasInlineDatePicker()) {
            before = datePickerIndexPath?.row < indexPath.row
        }
        var sameCellClicked = false
        if (hasInlineDatePicker()) {
            sameCellClicked = ((datePickerIndexPath?.row)! - 1 == indexPath.row)
            administerSuccessTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row + 1, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Fade)
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
        administerSuccessTableView.deselectRowAtIndexPath(indexPath, animated: true)
        administerSuccessTableView.endUpdates()
    }
    
    func collapseOpenedPickerCell() {
        //close inline pickers if any present in table cell
        if ((datePickerIndexPath) != nil) {
            let previousIndexPath = NSIndexPath(forRow: datePickerIndexPath!.row - 1, inSection: datePickerIndexPath!.section)
            self.displayInlineDatePickerForRowAtIndexPath(previousIndexPath)
        }
    }
    
    //MARK: TableView Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if hasInlineDatePicker() {
                return 8
            } else {
                return 7
            }
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            return UITableViewAutomaticDimension
        case SectionCount.eFirstSection.rawValue:
            if self.indexPathHasPicker(indexPath) {
                return 216
            } else {
                return 44
            }
        case SectionCount.eSecondSection.rawValue:
            return NOTES_CELL_HEIGHT
        default:
            return 44
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            //Medication details cell
            return self.medicationDetailsCellAtIndexPath(indexPath)
        case 1:
            //reason cell
            return self.medicationAdministrationDetailsInSecondSectionAtIndexPath(indexPath)
        default:
            //Notes cell
            let notesCell : DCNotesTableCell = self.notesTableCell()
            notesCell.selectedIndexPath = indexPath
            return notesCell
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.resignKeyboard()
        administerSuccessTableView.resignFirstResponder()
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            self.navigationController?.pushViewController(DCAdministrationHelper.addBNFView(), animated: true)
            break
        case SectionCount.eFirstSection.rawValue:
            self.cellSelectionForIndexPath(indexPath)
            break
        default:
            break
        }
        administerSuccessTableView.reloadData()
        administerSuccessTableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    //MARK: Private Methods
    
    func configureAdministratingUserForMedicationSlot () {
        
        // To set the API with the administrating user value which is mandatory in the api parameter list
        let selfAdministratedPatientName = SELF_ADMINISTERED_TITLE
        let selfAdministratedPatientIdentifier = EMPTY_STRING
        let selfAdministratedUser : DCUser? = DCUser.init()
        selfAdministratedUser!.displayName = selfAdministratedPatientName
        selfAdministratedUser!.userIdentifier = selfAdministratedPatientIdentifier
        medicationSlot?.medicationAdministration?.administratingUser = selfAdministratedUser
        self.medicationSlot?.medicationAdministration?.isSelfAdministered = true
    }
    
    func cellSelectionForIndexPath (indexPath : NSIndexPath) {
        
        let administerDatePickerIndexPath : NSIndexPath = NSIndexPath(forRow: 4, inSection: 0)
        switch (indexPath.row) {
        case 0:
            let statusViewController : DCAdministrationStatusTableViewController
            if let medicationStatus = medicationSlot?.status {
                statusViewController  = DCAdministrationHelper.administratedStatusPopOverAtIndexPathWithStatus(indexPath, status:medicationStatus)
                medicationSlot?.medicationAdministration.status = medicationStatus
                statusViewController.previousSelectedValue = medicationStatus
            } else {
                if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationDetails!) {
                    statusViewController  = DCAdministrationHelper.administratedStatusPopOverAtIndexPathWithStatus(indexPath, status:STARTED)
                    statusViewController.previousSelectedValue = STARTED
                } else {
                    statusViewController  = DCAdministrationHelper.administratedStatusPopOverAtIndexPathWithStatus(indexPath, status:ADMINISTERED)
                    statusViewController.previousSelectedValue = ADMINISTERED
                }
            }
            statusViewController.medicationStatusDelegate = self
            self.navigationController!.pushViewController(statusViewController, animated: true)
            break
        case 1:
            let reasonViewController : DCAdministrationReasonViewController = DCAdministrationHelper.administratedReasonPopOverAtIndexPathWithStatus(ADMINISTERED)
            reasonViewController.delegate = self
            if let reasonString = self.medicationSlot?.medicationAdministration.statusReason {
                reasonViewController.previousSelection = reasonString
            }
            self.navigationController!.pushViewController(reasonViewController, animated: true)
        case 3:
            self.displayInlineDatePickerForRowAtIndexPath(indexPath)
            break
        case 4:
            if (!indexPathHasPicker(administerDatePickerIndexPath)) {
                displayPrescribersAndAdministersView()
            }
            break
        case 5:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                displayPrescribersAndAdministersView()
            }
            
        case 6:
            if (!indexPathHasPicker(administerDatePickerIndexPath)) {
                self.displayInlineDatePickerForRowAtIndexPath(indexPath)
            }
            break
        case 7:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                self.displayInlineDatePickerForRowAtIndexPath(indexPath)
            }
            break
        default:
            break
        }
    }
    
    func medicationAdministrationDetailsInSecondSectionAtIndexPath (indexPath : NSIndexPath) -> UITableViewCell {
        let administerDatePickerIndexPath : NSIndexPath = NSIndexPath(forRow: 4, inSection: 0)
        switch indexPath.row {
        case 0:
            //status cell
            return self.administrationStatusTableCellAtIndexPath(indexPath)
        case 1:
            //reason cell
            return self.administrationReasonTableCellAtIndexPath(indexPath)
        case 2:
            //Dose cell
            return self.batchNumberOrExpiryDateTableCellAtIndexPathWithLabel(indexPath,label: "Dose")
        case 3:
            //date and time cell
            return self.administrationDateAndTimeTableCellAtIndexPath(indexPath,label: "Date & Time")
        case 4:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                return datePickerTableCellAtIndexPath(indexPath)
            } else {
                return self.administrationCheckedByTableCellAtIndexPath(indexPath)
            }
        case 5:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                return self.administrationCheckedByTableCellAtIndexPath(indexPath)
            } else {
                return self.batchNumberOrExpiryDateTableCellAtIndexPathWithLabel(indexPath,label: "Batch Number")
            }
        case 6:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                return self.batchNumberOrExpiryDateTableCellAtIndexPathWithLabel(indexPath,label: "Batch Number")
            } else {
                return self.administrationDateAndTimeTableCellAtIndexPath(indexPath,label: "Expiry Date")
            }
        case 7:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                return self.administrationDateAndTimeTableCellAtIndexPath(indexPath,label: "Expiry Date")
            } else {
                return datePickerTableCellAtIndexPath(indexPath)
            }
        default:
            return datePickerTableCellAtIndexPath(indexPath)
        }
    }
    
    func displayPrescribersAndAdministersView () {
        
        let namesViewController : DCNameSelectionTableViewController? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(NAMES_LIST_VIEW_STORYBOARD_ID) as? DCNameSelectionTableViewController
        namesViewController?.namesDelegate = self
        namesViewController?.title = CHECKED_BY
        let checkedByList : NSMutableArray = []
        checkedByList.addObjectsFromArray(userListArray! as [AnyObject])
        namesViewController?.namesArray = checkedByList
        namesViewController!.previousSelectedValue = medicationSlot?.medicationAdministration?.checkingUser?.displayName
        self.navigationController!.pushViewController(namesViewController!,animated: true)
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
    
    func resignKeyboard() {
    //resign keyboard
    let notesCell : DCNotesTableCell = self.notesTableCell()
    if (notesCell.notesTextView.isFirstResponder()) {
    notesCell.notesTextView.resignFirstResponder()
    }
    let expiryCell : DCBatchNumberCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(BATCH_NUMBER_CELL_ID) as? DCBatchNumberCell)!
    if (expiryCell.batchNumberTextField.isFirstResponder()) {
        expiryCell.batchNumberTextField.resignFirstResponder()
    }
    self.view.endEditing(true)
    }
    
    // MARK: BatchNumberCellDelegate Methods
    func batchNumberFieldSelectedAtIndexPath(indexPath: NSIndexPath) {
        self.collapseOpenedPickerCell()
        self.administerSuccessTableView.contentOffset = CGPointMake(0, 300)
    }
    
    func enteredBatchDetails(batch : String) {
        medicationSlot?.medicationAdministration?.batch = batch
    }
    
    // MARK: NotesCell Delegate Methods
    func notesSelected(editing : Bool, withIndexPath indexPath : NSIndexPath) {
        self.collapseOpenedPickerCell()
        self.administerSuccessTableView.contentOffset = CGPointMake(0, 400)

    }
    
    func enteredNote(note : String) {
        medicationSlot?.medicationAdministration?.administeredNotes = note
    }
    
    // mark:StatusList Delegate Methods
    func selectedMedicationStatusEntry(status: String!) {
        let parentView : DCAdministrationStatusSelectionViewController = self.parentViewController as! DCAdministrationStatusSelectionViewController
        medicationSlot!.medicationAdministration.status = status
        parentView.updateViewWithChangeInStatus(status)
    }
    
    // MARK: NamesList Delegate Methods
    func selectedUserEntry(user : DCUser!) {
            //checked by
            if (user == DEFAULT_NURSE_NAME) {
                medicationSlot?.medicationAdministration?.checkingUser = user
            } else {
                var selectedUser = DCUser.init()
                selectedUser = user
                self.performSelector("displaySecurityPinEntryViewForUser:", withObject:selectedUser , afterDelay: 0.5)
            }
        administerSuccessTableView.reloadData()
    }
    
    //MARK : Security pin Match Delegate
    func securityPinMatchedForUser(user: DCUser) {
        medicationSlot?.medicationAdministration?.checkingUser = user
        self.administerSuccessTableView.reloadData()
    }

    // MARK:AdministerPickerCellDelegate Methods
    func reasonSelected(reason: String) {
        self.medicationSlot?.medicationAdministration.statusReason = reason
        self.administerSuccessTableView.reloadData()
    }
}
