//
//  DCAdministrationSuccessViewController.swift
//  DrugChart
//
//  Created by aliya on 18/02/16.
//
//

import Foundation

class DCAdministrationSuccessViewController: DCBaseViewController ,NotesCellDelegate,BatchCellDelegate, StatusListDelegate ,reasonDelegate, NamesListDelegate, SecurityPinMatchDelegate, AdministrationDateDelegate{
    
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
    var dateTimeCellIndexPath : NSIndexPath?
    var expiryDateCellIndexPath : NSIndexPath?
    var doseCellIndexPath : NSIndexPath?
    var textFieldSelectionIndexPath : NSIndexPath?
    var isValid : Bool?
    
    let infusionRowCount = 6
    let medicationRowCount = 7
    let sectionCount = 3
    let zeroFloat : CGFloat = 0.0
    let earlyAdministrationHeaderHeight : CGFloat = 30
    
    //MARK: View Management Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.userListArray = DCAdministrationHelper.fetchAdministersAndPrescribersList()
        self.configureAdministratingUserForMedicationSlot()
        medicationSlot?.medicationAdministration?.actualAdministrationTime = NSDate()
        configureViewElements()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.administerSuccessTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.administerSuccessTableView.reloadData()
        self.collapseOpenedPickerCell()
        super.viewWillDisappear(animated)
    }
    // MARK: Private Methods
    //MARK:
    
    func initialiseMedicationSlotObject () {
        
        //initialise Medication Slot object
        medicationSlot?.medicationAdministration?.statusReason = EMPTY_STRING
        medicationSlot?.medicationAdministration?.administratingUser = DCUser.init()
        medicationSlot?.medicationAdministration?.checkingUser = DCUser.init()
        medicationSlot?.medicationAdministration?.scheduledDateTime = medicationSlot?.time
        medicationSlot?.medicationAdministration?.actualAdministrationTime = NSDate()
    }
    
    func configureTableViewProperties () {
        self.administerSuccessTableView.rowHeight = UITableViewAutomaticDimension
        self.administerSuccessTableView.estimatedRowHeight = TABLE_VIEW_ROW_HEIGHT
        self.administerSuccessTableView.tableFooterView = UIView(frame: CGRectZero)
        administerSuccessTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    }
    
    func configureViewElements () {
        configureTableViewProperties()
    }
    
    func scrollTableViewToErrorField() {
        
        // TODO: Here only notes field is taken into account, consider the reason field indexpath. if reason is empty
        // first check reason cell is visble if not scroll to reason cell, else check for notes field and scroll to last cell
        // scroll tableview to error field in case of error
        
        if (medicationSlot?.status != STARTED && medicationSlot?.medicationAdministration?.statusReason == nil || medicationSlot?.medicationAdministration?.statusReason == EMPTY_STRING){
            let reasonIndexPath =  NSIndexPath(forItem: 1, inSection: eFirstSection.rawValue)
            if ((administerSuccessTableView.indexPathsForVisibleRows?.contains(reasonIndexPath)) != nil) {
                self.scrollToTableCellAtIndexPath(reasonIndexPath)
            }
        } else if (self.medicationSlot?.medicationAdministration?.administeredNotes == EMPTY_STRING || self.medicationSlot?.medicationAdministration?.administeredNotes == nil) {
            let lastIndexPath = NSIndexPath(forItem: 0, inSection: sectionCount - 1)
            if ((administerSuccessTableView.indexPathsForVisibleRows?.contains(lastIndexPath)) != nil) {
                self.scrollToTableCellAtIndexPath(lastIndexPath)
            }
        }
     }
    
    func scrollToTableCellAtIndexPath(indexPath : NSIndexPath) {
        
        //scroll to indexPath
        administerSuccessTableView.beginUpdates()
        administerSuccessTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
        administerSuccessTableView.endUpdates()
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
        administerCell.detailLabelTrailingSpace.constant = zeroFloat
        administerCell.titleLabel.text = OUTCOME
        if (medicationSlot?.status != nil) {
            administerCell.detailLabel.text = medicationSlot?.status
            medicationSlot?.medicationAdministration?.status = medicationSlot?.status
        } else {
            administerCell.detailLabel.text = medicationSlot!.medicationAdministration?.status
        }
        return administerCell
    }
    
    // Checked By Cell
    func administrationCheckedByTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.detailLabelTrailingSpace.constant = zeroFloat
        if let checkedUser = medicationSlot?.medicationAdministration?.checkingUser?.displayName {
            administerCell.detailLabel?.text = checkedUser
        } else {
            administerCell.detailLabel?.text = EMPTY_STRING
        }
        administerCell.titleLabel.text = CHECKED_BY
        return administerCell
    }
    
    func statusReasonIsEmpty() -> Bool {
        
        return (medicationSlot?.medicationAdministration?.statusReason == nil || medicationSlot?.medicationAdministration?.statusReason == EMPTY_STRING )
    }
    
    // Administation reason Cell
    func administrationReasonTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.titleLabel.text = REASON
        administerCell.detailLabelTrailingSpace.constant = zeroFloat
        if self.statusReasonIsEmpty() {
            medicationSlot?.medicationAdministration?.statusReason = NSLocalizedString("NURSE_ADMINISTERED", comment: "")
        }
        administerCell.titleLabel.textColor = !isValid! && self.statusReasonIsEmpty() ? UIColor.redColor() : UIColor.blackColor()
        administerCell.detailLabel?.text = medicationSlot?.medicationAdministration?.statusReason
        return administerCell
    }
    
    // Administering dose cell
    func administratingDoseTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
    
        let administerCell : DCAdministerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.titleLabel.text = DOSE
        if let dosageString = medicationSlot?.medicationAdministration?.dosageString {
            administerCell.detailLabel?.text = dosageString
        } else {
            administerCell.detailLabel?.text = medicationDetails?.dosage
        }
        if !isValid! && medicationSlot?.medicationAdministration?.isDoseUpdated == true && (medicationSlot?.medicationAdministration?.doseEditReason == EMPTY_STRING || medicationSlot?.medicationAdministration?.doseEditReason == nil) {
            administerCell.titleLabel.textColor = UIColor.redColor()
        } else {
            administerCell.titleLabel.textColor = UIColor.blackColor()
        }
        return administerCell
    }
    
    //Date Cell
    func administrationDateAndTimeTableCellAtIndexPath(indexPath : NSIndexPath, label: NSString) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.None
        administerCell.titleLabel.text = label as String
        administerCell.detailLabelTrailingSpace.constant = 15.0
        var dateString : String = EMPTY_STRING
        if( label == EXPIRY_DATE_STRING) {
            if let date = medicationSlot?.medicationAdministration?.expiryDateTime {
                dateString = DCDateUtility.dateStringFromDate(date, inFormat: EXPIRY_DATE_FORMAT)
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
    func notesTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCNotesTableCell) {
        
        let notesCell : DCNotesTableCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(NOTES_CELL_ID) as? DCNotesTableCell)!
        notesCell.selectedIndexPath = indexPath
        notesCell.notesType = eNotes
        if ((self.medicationSlot?.medicationAdministration?.administeredNotes) != nil) {
            notesCell.notesTextView.text = self.medicationSlot?.medicationAdministration?.administeredNotes
        }
        notesCell.notesTextView.textColor = (!isValid! && !isValidNotes ()) ? UIColor.redColor() : UIColor(forHexString: "#8f8f95")
        notesCell.delegate = self
        return notesCell
    }
    
    //Batch number or Dose cell
    func batchNumberOrExpiryDateTableCellAtIndexPathWithLabel(indexPath: NSIndexPath, label: NSString) -> (DCBatchNumberCell) {
        
        let expiryCell : DCBatchNumberCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(BATCH_NUMBER_CELL_ID) as? DCBatchNumberCell)!
        expiryCell.batchDelegate = self
        expiryCell.batchNumberTextField.placeholder = label as String
        if label == DOSE && indexPath == doseCellIndexPath {
            if let dosageString = medicationSlot?.medicationAdministration?.dosageString {
                expiryCell.batchNumberTextField?.text = dosageString
            } else {
                expiryCell.batchNumberTextField?.text = medicationDetails?.dosage
            }
        } else if label == BATCH_NUMBER{// label is batch
            if let batchString = medicationSlot?.medicationAdministration?.batch {
                expiryCell.batchNumberTextField?.text = batchString
            } else {
                expiryCell.batchNumberTextField?.text = EMPTY_STRING
            }
        }
        expiryCell.selectedIndexPath = indexPath
        return expiryCell;
    }
    
    //Date picker Cell
    func datePickerTableCellAtIndexPath (indexPath : NSIndexPath) -> (UITableViewCell) {
        let pickerCell : DCAdministrationDatePickerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier("AdministrationDatePickerCell") as? DCAdministrationDatePickerCell)!
        pickerCell.delegate = self
        if indexPath.row == dateTimeCellIndexPath!.row + 1 {
            pickerCell.datePicker?.datePickerMode = UIDatePickerMode.DateAndTime
            pickerCell.datePicker?.maximumDate = NSDate()
        } else {
            pickerCell.datePicker?.maximumDate = nil
            pickerCell.datePicker?.datePickerMode = UIDatePickerMode.Date
        }
        pickerCell.selectedIndexPath = indexPath
    return pickerCell;
    }
    
    // MARK: Date Picker Methods
    func hasPickerForIndexPath(indexPath : NSIndexPath) -> Bool {
        
        var hasDatePicker : Bool = false
        var targetedRow : NSInteger = indexPath.row
        targetedRow += 1
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
    
    func scrollToDatePickerAtIndexPath(indexPath :NSIndexPath) {
    //scroll to date picker indexpath when when any of the date field is selected
//        if (indexPath.row != (datePickerIndexPath?.row)!-1) {
            let scrollToIndexPath : NSIndexPath = NSIndexPath(forRow:indexPath.row + 1 , inSection:indexPath.section)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.administerSuccessTableView.scrollToRowAtIndexPath(scrollToIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            })
//        }
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
            scrollToDatePickerAtIndexPath(indexPath)
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
        case eZerothSection.rawValue:
            return RowCount.eFirstRow.rawValue
        case eFirstSection.rawValue:
            var rowCount = medicationRowCount
            if medicationSlot?.status == STARTED {
                rowCount = infusionRowCount
            }
            if hasInlineDatePicker() {
                rowCount += 1
            }
            return rowCount
        case eSecondSection.rawValue:
            return RowCount.eFirstRow.rawValue
        default:
            return RowCount.eZerothRow.rawValue
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionCount
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            return UITableViewAutomaticDimension
        case SectionCount.eFirstSection.rawValue:
            if self.indexPathHasPicker(indexPath) {
                return PICKER_CELL_HEIGHT
            } else {
                return TABLE_VIEW_ROW_HEIGHT
            }
        case SectionCount.eSecondSection.rawValue:
            return NOTES_CELL_HEIGHT
        default:
            return TABLE_VIEW_ROW_HEIGHT
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            return UITableViewAutomaticDimension
        case SectionCount.eFirstSection.rawValue:
            if self.indexPathHasPicker(indexPath) {
                return PICKER_CELL_HEIGHT
            } else {
                return TABLE_VIEW_ROW_HEIGHT
            }
        case SectionCount.eSecondSection.rawValue:
            return NOTES_CELL_HEIGHT
        default:
            return TABLE_VIEW_ROW_HEIGHT
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            //Medication detail cell
            return self.medicationDetailsCellAtIndexPath(indexPath)
        case SectionCount.eFirstSection.rawValue:
            // Medication administration fields
            if medicationSlot?.status == STARTED {
                return self.administrationTableCellForStartedStatusAtIndexPath(indexPath)
            } else {
                return self.administrationTableCellForAdministratedStatusAtIndexPath(indexPath)
            }
        default:
            //Notes cell
            return self.notesTableCellAtIndexPath(indexPath)
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == eSecondSection.rawValue {
            if medicationSlot?.medicationAdministration?.isWhenRequiredEarlyAdministration == true {
                return earlyAdministrationHeaderHeight
            } else if (medicationSlot?.medicationAdministration?.isEarlyAdministration == true || medicationSlot?.medicationAdministration?.isLateAdministration == true ) {
                 return (medicationSlot?.medicationAdministration?.isEarlyAdministration == true || medicationSlot?.medicationAdministration?.isLateAdministration == true ) ? MEDICATION_DETAILS_SECTION_HEIGHT : TABLEVIEW_DEFAULT_SECTION_HEIGHT
            }
        }
        return zeroFloat
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let administerHeaderView = NSBundle.mainBundle().loadNibNamed(ADMINISTER_HEADER_VIEW_NIB, owner: self, options: nil)[0] as? DCAdministerTableHeaderView
        administerHeaderView!.timeLabel.hidden = true
        if section == eSecondSection.rawValue {
            if (!isValid! && !isValidNotes ()) {
                if (medicationSlot?.medicationAdministration?.isWhenRequiredEarlyAdministration == true) {
                    let errorMessage = NSString(format: "%@ %@", NSLocalizedString("ADMIN_FREQUENCY", comment: "when required new medication is given 2 hrs before previous one"), NSLocalizedString("EARLY_ADMIN_INLINE", comment: ""))
                    administerHeaderView?.populateHeaderViewWithErrorMessage(errorMessage as String)
                    return administerHeaderView
                } else if (medicationSlot?.medicationAdministration?.isLateAdministration == true) {
                    let errorMessage = NSString(format: "%@", NSLocalizedString("LATE_ADMIN_INLINE", comment: ""))
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

        if medicationSlot?.status == STARTED {
            cellSelectionForStartedStatusAtIndexPath(indexPath)
        } else {
            cellSelectionForAdministratedStatusAtIndexPath(indexPath)
        }
    }
    
    func cellSelectionForAdministratedStatusAtIndexPath (indexPath : NSIndexPath){
        let administerDatePickerIndexPath : NSIndexPath = NSIndexPath(forRow: 4, inSection: 0)
        switch (indexPath.row) {
        case eZerothSection.rawValue:
            let statusViewController : DCAdministrationStatusTableViewController = self.statusCellSelectedAtIndexPath(indexPath)
            self.navigationController!.pushViewController(statusViewController, animated: true)
            break
        case eFirstSection.rawValue:
            let reasonViewController : DCAdministrationReasonViewController = self.reasonCellSelectedAtIndexPath(indexPath)
            self.navigationController!.pushViewController(reasonViewController, animated: true)
        case eSecondSection.rawValue:
            let doseViewController : DCAdministratingDoseViewController = self.administratingDoseCellSelected()
            self.navigationController!.pushViewController(doseViewController, animated: true)
        case eThirdSection.rawValue:
            self.displayInlineDatePickerForRowAtIndexPath(indexPath)
            break
        case eFourthSection.rawValue:
            if (!indexPathHasPicker(administerDatePickerIndexPath)) {
                displayPrescribersAndAdministersView()
            }
            break
        case eFifthSection.rawValue:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                displayPrescribersAndAdministersView()
            }
            
        case eSixthSection.rawValue:
            if (!indexPathHasPicker(administerDatePickerIndexPath)) {
                self.expiryCellSelectedAtIndexPath(indexPath)
            }
            break
        case eSeventhSection.rawValue:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                self.expiryCellSelectedAtIndexPath(indexPath)
            }
            break
        default:
            break
        }
    }
    
    func cellSelectionForStartedStatusAtIndexPath (indexPath : NSIndexPath){
        let administerDatePickerIndexPath : NSIndexPath = NSIndexPath(forRow: 3, inSection: 0)
        switch (indexPath.row) {
        case eZerothSection.rawValue:
            let statusViewController : DCAdministrationStatusTableViewController = self.statusCellSelectedAtIndexPath(indexPath)
            self.navigationController!.pushViewController(statusViewController, animated: true)
            break
        case eFirstSection.rawValue:
            let doseViewController : DCAdministratingDoseViewController = self.administratingDoseCellSelected()
            self.navigationController!.pushViewController(doseViewController, animated: true)
        case eSecondSection.rawValue:
            self.displayInlineDatePickerForRowAtIndexPath(indexPath)
            break
        case eThirdSection.rawValue:
            if (!indexPathHasPicker(administerDatePickerIndexPath)) {
                displayPrescribersAndAdministersView()
            }
            break
        case eFourthSection.rawValue:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                displayPrescribersAndAdministersView()
            }
            
        case eFifthSection.rawValue:
            if (!indexPathHasPicker(administerDatePickerIndexPath)) {
                self.expiryCellSelectedAtIndexPath(indexPath)
            }
            break
        case eSixthSection.rawValue:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                self.expiryCellSelectedAtIndexPath(indexPath)
            }
            break
        default:
            break
        }
    }
    
    func statusCellSelectedAtIndexPath (indexPath : NSIndexPath) -> DCAdministrationStatusTableViewController {
        let statusViewController : DCAdministrationStatusTableViewController
        if let medicationStatus = medicationSlot?.status {
            statusViewController  = DCAdministrationHelper.administratedStatusPopOverAtIndexPathWithStatus(indexPath, status:medicationStatus)
            medicationSlot?.medicationAdministration?.status = medicationStatus
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
        statusViewController.medicationDetails = medicationDetails
        statusViewController.medicationStatusDelegate = self
        return statusViewController
    }
    
    func reasonCellSelectedAtIndexPath (indexPath : NSIndexPath) -> DCAdministrationReasonViewController {
        
        let reasonViewController : DCAdministrationReasonViewController = DCAdministrationHelper.administratedReasonPopOverAtIndexPathWithStatus(ADMINISTERED)
        reasonViewController.delegate = self
        if let reasonString = self.medicationSlot?.medicationAdministration?.statusReason {
            reasonViewController.previousSelection = reasonString
            reasonViewController.secondaryReason = self.medicationSlot?.medicationAdministration?.secondaryReason
        }
        return reasonViewController
    }
    
    func expiryCellSelectedAtIndexPath (indexPath : NSIndexPath) {
        
        if (self.medicationSlot?.medicationAdministration.expiryDateTime == nil) {
            self.medicationSlot?.medicationAdministration.expiryDateTime = NSDate()
            self.administerSuccessTableView.beginUpdates()
            self.administerSuccessTableView.reloadRowsAtIndexPaths([expiryDateCellIndexPath!], withRowAnimation:.Fade)
            self.administerSuccessTableView.endUpdates()
            self.performSelector(#selector(DCAdministrationSuccessViewController.displayInlineDatePickerForRowAtIndexPath(_:)), withObject: indexPath, afterDelay: 0.1)
        } else {
            self.displayInlineDatePickerForRowAtIndexPath(indexPath)
        }
    }
    
    func administratingDoseCellSelected() -> DCAdministratingDoseViewController {
        let administratingDoseViewController : DCAdministratingDoseViewController = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(ADMINISTRATING_DOSE_SB_ID) as! DCAdministratingDoseViewController
        if let dosageString = medicationSlot?.medicationAdministration?.dosageString {
            administratingDoseViewController.doseValue = dosageString
        } else {
            administratingDoseViewController.doseValue = medicationDetails?.dosage
        }
        if let doseEditReasonText = medicationSlot?.medicationAdministration?.doseEditReason {
            administratingDoseViewController.doseEditReasonText = doseEditReasonText
        }
        administratingDoseViewController.isInEditMode = (self.medicationSlot?.medicationAdministration.isDoseUpdated)!
        administratingDoseViewController.title = NSLocalizedString("DOSE", comment: "")
        administratingDoseViewController.doseValueUpdated = { dose, reason in
            self.medicationSlot?.medicationAdministration?.dosageString = dose
            if reason != REASON {
                self.medicationSlot?.medicationAdministration.doseEditReason = reason
            }
            self.administerSuccessTableView.reloadData()
        }
        administratingDoseViewController.isDoseValueUpdated = { value in
            self.medicationSlot?.medicationAdministration.isDoseUpdated = value
            
        }
        return administratingDoseViewController
    }

    func administrationTableCellForAdministratedStatusAtIndexPath (indexPath : NSIndexPath) -> UITableViewCell {
        let administerDatePickerIndexPath : NSIndexPath = NSIndexPath(forRow: 4, inSection: 0)
        dateTimeCellIndexPath  = NSIndexPath(forRow: 3, inSection: 1)
        expiryDateCellIndexPath = NSIndexPath(forRow: 6, inSection: 1)
        doseCellIndexPath  = NSIndexPath(forRow: 2, inSection: 1)
        switch indexPath.row {
        case eZerothSection.rawValue:
            //status cell
            return self.administrationStatusTableCellAtIndexPath(indexPath)
        case eFirstSection.rawValue:
            //reason cell
            return self.administrationReasonTableCellAtIndexPath(indexPath)
        case eSecondSection.rawValue:
            //Dose cell
            return self.administratingDoseTableCellAtIndexPath(indexPath)
        case eThirdSection.rawValue:
            //date and time cell
            return self.administrationDateAndTimeTableCellAtIndexPath(indexPath,label: DATE_TIME)
        case eFourthSection.rawValue:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                return datePickerTableCellAtIndexPath(indexPath)
            } else {
                return self.administrationCheckedByTableCellAtIndexPath(indexPath)
            }
        case eFifthSection.rawValue:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                return self.administrationCheckedByTableCellAtIndexPath(indexPath)
            } else {
                return self.batchNumberOrExpiryDateTableCellAtIndexPathWithLabel(indexPath,label:BATCH_NUMBER)
            }
        case eSixthSection.rawValue:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                return self.batchNumberOrExpiryDateTableCellAtIndexPathWithLabel(indexPath,label: BATCH_NUMBER)
            } else {
                return self.administrationDateAndTimeTableCellAtIndexPath(indexPath,label: EXPIRY_DATE_STRING)
            }
        case eSeventhSection.rawValue:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                return self.administrationDateAndTimeTableCellAtIndexPath(indexPath,label: EXPIRY_DATE_STRING)
            } else {
                return datePickerTableCellAtIndexPath(indexPath)
            }
        default:
            return datePickerTableCellAtIndexPath(indexPath)
        }
    }
    
    func administrationTableCellForStartedStatusAtIndexPath (indexPath :NSIndexPath) -> UITableViewCell {
        let administerDatePickerIndexPath : NSIndexPath = NSIndexPath(forRow: 3, inSection: 0)
        dateTimeCellIndexPath  = NSIndexPath(forRow: 2, inSection: 1)
        expiryDateCellIndexPath = NSIndexPath(forRow: 5, inSection: 1)
        doseCellIndexPath  = NSIndexPath(forRow: 1, inSection: 1)
        switch indexPath.row {
        case eZerothSection.rawValue:
            //status cell
            return self.administrationStatusTableCellAtIndexPath(indexPath)
        case eFirstSection.rawValue:
            //Dose cell
            return self.administratingDoseTableCellAtIndexPath(indexPath)
        case eSecondSection.rawValue:
            //date and time cell
            return self.administrationDateAndTimeTableCellAtIndexPath(indexPath,label: DATE_TIME)
        case eThirdSection.rawValue:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                return datePickerTableCellAtIndexPath(indexPath)
            } else {
                return self.administrationCheckedByTableCellAtIndexPath(indexPath)
            }
        case eFourthSection.rawValue:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                return self.administrationCheckedByTableCellAtIndexPath(indexPath)
            } else {
                return self.batchNumberOrExpiryDateTableCellAtIndexPathWithLabel(indexPath,label:BATCH_NUMBER)
            }
        case eFifthSection.rawValue:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                return self.batchNumberOrExpiryDateTableCellAtIndexPathWithLabel(indexPath,label: BATCH_NUMBER)
            } else {
                return self.administrationDateAndTimeTableCellAtIndexPath(indexPath,label: EXPIRY_DATE_STRING)
            }
        case eSixthSection.rawValue:
            if (indexPathHasPicker(administerDatePickerIndexPath)) {
                return self.administrationDateAndTimeTableCellAtIndexPath(indexPath,label: EXPIRY_DATE_STRING)
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
        let notesCell : DCNotesTableCell = self.notesTableCellAtIndexPath(NSIndexPath(forRow: 0, inSection: 2))
        if (notesCell.notesTextView.isFirstResponder()) {
            notesCell.notesTextView.resignFirstResponder()
        }
        let expiryCell : DCBatchNumberCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(BATCH_NUMBER_CELL_ID) as? DCBatchNumberCell)!
        if (expiryCell.batchNumberTextField.isFirstResponder()) {
            expiryCell.batchNumberTextField.resignFirstResponder()
        }
        self.view.endEditing(true)
    }
    
    func isValidNotes () -> Bool {
        var notesValidity = true
        if (medicationSlot?.medicationAdministration?.isEarlyAdministration == true || medicationSlot?.medicationAdministration?.isLateAdministration == true) {
            if (medicationSlot?.medicationAdministration?.administeredNotes == nil || medicationSlot?.medicationAdministration?.administeredNotes == EMPTY_STRING) {
                notesValidity = false
            }
        }
        return notesValidity
    }
    
    // MARK: BatchNumberCellDelegate Methods
    func batchNumberFieldSelectedAtIndexPath(indexPath: NSIndexPath) {
        textFieldSelectionIndexPath = indexPath
        self.collapseOpenedPickerCell()
    }
    
    func enteredBatchDetails(batch : String) {
        if textFieldSelectionIndexPath == doseCellIndexPath {
            medicationSlot?.medicationAdministration?.dosageString = batch
        } else {
            medicationSlot?.medicationAdministration?.batch = batch
        }
    }
    
    // MARK: NotesCell Delegate Methods
    func notesSelected(editing : Bool, withIndexPath indexPath : NSIndexPath) {
        textFieldSelectionIndexPath = indexPath
        self.collapseOpenedPickerCell()
    }
    
    func enteredNote(note : String) {
        medicationSlot?.medicationAdministration?.administeredNotes = note
    }
    
    // mark:StatusList Delegate Methods
    func selectedMedicationStatusEntry(status: String!) {
        let parentView : DCAdministrationStatusSelectionViewController = self.parentViewController as! DCAdministrationStatusSelectionViewController
        medicationSlot!.medicationAdministration?.status = status
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
                self.performSelector(#selector(DCAdministrationSuccessViewController.displaySecurityPinEntryViewForUser(_:)), withObject:selectedUser , afterDelay: 0.5)
            }
        administerSuccessTableView.reloadData()
    }
    
    //MARK : Security pin Match Delegate
    func securityPinMatchedForUser(user: DCUser) {
        medicationSlot?.medicationAdministration?.checkingUser = user
        self.administerSuccessTableView.reloadData()
    }

    // MARK:AdministerPickerCellDelegate Methods
    func reasonSelected(reason: String, secondaryReason : String) {
        self.medicationSlot?.medicationAdministration?.statusReason = reason
        self.medicationSlot?.medicationAdministration?.secondaryReason = secondaryReason
        self.administerSuccessTableView.reloadData()
    }
    
    func selectedDateAtIndexPath (date : NSDate, indexPath:NSIndexPath) {
        
        if indexPath.row == RowCount.eFourthRow.rawValue {
            self.medicationSlot!.medicationAdministration?.actualAdministrationTime = date
            self.administerSuccessTableView .reloadRowsAtIndexPaths([self.dateTimeCellIndexPath!], withRowAnimation:UITableViewRowAnimation.None)
        } else {
            self.medicationSlot!.medicationAdministration?.expiryDateTime = date
            self.administerSuccessTableView .reloadRowsAtIndexPaths([self.expiryDateCellIndexPath!], withRowAnimation:UITableViewRowAnimation.None)
        }
    }
    
    func keyboardDidShow(notification : NSNotification) {
            if let userInfo = notification.userInfo {
                if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                    let contentInsets: UIEdgeInsets
                        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0)
                    self.administerSuccessTableView.contentInset = contentInsets;
                    self.administerSuccessTableView.scrollIndicatorInsets = contentInsets;
                    if ((textFieldSelectionIndexPath) != nil){
                        self.administerSuccessTableView.scrollToRowAtIndexPath(textFieldSelectionIndexPath!, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                    }
                }
        }
    }
    
    func keyboardDidHide(notification :NSNotification){
        let contentInsets:UIEdgeInsets  = UIEdgeInsetsZero;
        administerSuccessTableView.contentInset = contentInsets;
        administerSuccessTableView.scrollIndicatorInsets = contentInsets;
    }
}
