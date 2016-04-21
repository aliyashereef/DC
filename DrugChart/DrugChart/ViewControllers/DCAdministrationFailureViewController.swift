//
//  DCAdministrationFailureViewController.swift
//  DrugChart
//
//  Created by aliya on 18/02/16.
//
//

import Foundation

let ADMINISTER_FAILURE_TABLE_SECTION_COUNT = 3

class DCAdministrationFailureViewController: DCBaseViewController ,NotesCellDelegate , StatusListDelegate, reasonDelegate, AdministrationDateDelegate{
    
    @IBOutlet var administrationFailureTableView: UITableView!
    
    //MARK: Variables
    
    var dateAndTime : NSString = EMPTY_STRING
    var medicationSlot : DCMedicationSlot?
    var medicationDetails : DCMedicationScheduleDetails?
    var isDatePickerShown : Bool = false
    var isValid : Bool?
    
    //MARK: View Management Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseMedicationSlotObject()
        configureTableViewProperties()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.administrationFailureTableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func configureTableViewProperties () {
        self.administrationFailureTableView.rowHeight = UITableViewAutomaticDimension
        self.administrationFailureTableView.estimatedRowHeight = 44.0
        self.administrationFailureTableView.tableFooterView = UIView(frame: CGRectZero)
        administrationFailureTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    }

    func initialiseMedicationSlotObject () {
        
        //initialise Medication Slot object
        if (medicationSlot == nil) {
            medicationSlot = DCMedicationSlot.init()
        }
        medicationSlot?.medicationAdministration = DCMedicationAdministration.init()
        medicationSlot?.medicationAdministration?.administratingUser = DCUser.init()
        medicationSlot?.medicationAdministration?.scheduledDateTime = medicationSlot?.time
        medicationSlot?.medicationAdministration?.statusReason = EMPTY_STRING
        medicationSlot?.medicationAdministration?.actualAdministrationTime = NSDate()
    }
    
    func scrollTableViewToErrorField() {
        
         // scroll tableview to error field in case of error
        if (!isValidReason()){
            let reasonIndexPath =  NSIndexPath(forItem: 1, inSection: eFirstSection.rawValue)
            if ((administrationFailureTableView.indexPathsForVisibleRows?.contains(reasonIndexPath)) != nil) {
                self.scrollToTableCellAtIndexPath(reasonIndexPath)
            }
        } else if (!isValidNotes()) {
            let lastIndexPath = NSIndexPath(forItem: 0, inSection: ADMINISTER_FAILURE_TABLE_SECTION_COUNT - 1)
            if ((administrationFailureTableView.indexPathsForVisibleRows?.contains(lastIndexPath)) != nil) {
                self.scrollToTableCellAtIndexPath(lastIndexPath)
            }
        }
    }
    
    func scrollToTableCellAtIndexPath(indexPath : NSIndexPath) {
        
        //scroll to indexPath
        administrationFailureTableView.beginUpdates()
        administrationFailureTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
        administrationFailureTableView.endUpdates()
    }
    
    //MARK: TableView Delegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return 1
        case 1:
            if isDatePickerShown {
                return 4
            }
            return 3
        case 2:
            return 1
        default :
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            return self.medicationDetailsCellAtIndexPath(indexPath)
        case 1:
            return self.medicationAdministrationDetailsInSecondSectionAtIndexPath(indexPath)
        case 2:
            return self.notesTableCellAtIndexPath(indexPath)
        default:
            return self.medicationDetailsCellAtIndexPath(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            return UITableViewAutomaticDimension
        case SectionCount.eFirstSection.rawValue:
            if indexPath.row == 3 {
                return DATE_PICKER_VIEW_CELL_HEIGHT
            } else {
                return 44
            }
        case SectionCount.eSecondSection.rawValue:
            return NOTES_CELL_HEIGHT
        default:
            return 44
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 2) {
            if medicationSlot?.medicationAdministration?.isWhenRequiredEarlyAdministration == true {
                return 30
            } else if (medicationSlot?.medicationAdministration?.isEarlyAdministration == true || medicationSlot?.medicationAdministration?.isLateAdministration == true ) {
                return (medicationSlot?.medicationAdministration?.isEarlyAdministration == true || medicationSlot?.medicationAdministration?.isLateAdministration == true ) ? MEDICATION_DETAILS_SECTION_HEIGHT : TABLEVIEW_DEFAULT_SECTION_HEIGHT
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let administerHeaderView = NSBundle.mainBundle().loadNibNamed(ADMINISTER_HEADER_VIEW_NIB, owner: self, options: nil)[0] as? DCAdministerTableHeaderView
        administerHeaderView!.timeLabel.hidden = true
        if (section == 2) {
            if (!isValid! && !isValidNotes()) {
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        administrationFailureTableView.deselectRowAtIndexPath(indexPath, animated: true)
        administrationFailureTableView.resignFirstResponder()
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
    }
    
    //MARK: Configuring Table View Cells
    
    //Medication Details Cell
    func medicationDetailsCellAtIndexPath (indexPath :NSIndexPath) -> UITableViewCell {
                
        if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationDetails!){
            let cell = administrationFailureTableView.dequeueReusableCellWithIdentifier("DurationBasedInfusionCell") as? DCDurationBasedMedicationDetailsCell
            if let _ = medicationDetails {
                cell!.configureMedicationDetails(medicationDetails!)
            }
            return cell!
        } else {
            let cell = administrationFailureTableView.dequeueReusableCellWithIdentifier("MedicationDetailsTableViewCell") as? DCMedicationDetailsTableViewCell
            if let _ = medicationDetails {
                cell!.configureMedicationDetails(medicationDetails!)
            }
            return cell!
        }
    }
    
    // Administration Status Cell
    func administrationFailureStatusTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administrationFailureTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.titleLabel.text = STATUS
        medicationSlot?.medicationAdministration?.status = NOT_ADMINISTRATED
        administerCell.detailLabel?.text = NOT_ADMINISTRATED
        return administerCell
    }
    
    // Administation reason Cell
    func administrationFailureReasonTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administrationFailureTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.titleLabel.text = REASON
        administerCell.titleLabel.textColor = (!isValid! && !isValidReason()) ? UIColor.redColor() : UIColor.blackColor()
        administerCell.detailLabel?.text = self.medicationSlot?.medicationAdministration?.statusReason
        return administerCell
    }
    
    //Date Cell
    func administrationFailureDateAndTimeTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administrationFailureTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.None
        administerCell.titleLabel.text = "Date & Time"
        administerCell.detailLabelTrailingSpace.constant = 15.0
        var dateString : String = EMPTY_STRING
        if let date = medicationSlot!.medicationAdministration?.actualAdministrationTime {
            dateString = DCDateUtility.dateStringFromDate(date, inFormat: ADMINISTER_DATE_TIME_FORMAT)
        }
        administerCell.detailLabel?.text = dateString
        return administerCell
    }
    
    // Notes Cell
    func notesTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCNotesTableCell) {
        
        let notesCell : DCNotesTableCell = (administrationFailureTableView.dequeueReusableCellWithIdentifier(NOTES_CELL_ID) as? DCNotesTableCell)!
        notesCell.selectedIndexPath = indexPath
        notesCell.notesType = eNotes
        notesCell.notesTextView.textColor = (isValid! || isValidNotes()) ? UIColor(forHexString: "#8f8f95") : UIColor.redColor()
        notesCell.delegate = self
        return notesCell
    }
    
    //Date picker Cell
    
    func datePickerTableCellAtIndexPath (indexPath : NSIndexPath) -> (UITableViewCell) {
        
        let pickerCell : DCAdministrationDatePickerCell = (administrationFailureTableView.dequeueReusableCellWithIdentifier("AdministrationFailurePickerCell") as? DCAdministrationDatePickerCell)!
        pickerCell.selectedIndexPath = indexPath
        pickerCell.delegate = self
        pickerCell.datePicker?.maximumDate = NSDate()
        return pickerCell;
    }
    
    func selectedDateAtIndexPath (date : NSDate, indexPath:NSIndexPath) {
        self.medicationSlot!.medicationAdministration?.actualAdministrationTime = date
        self.administrationFailureTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:RowCount.eSecondRow.rawValue, inSection:1)], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func collapseOpenedPickerCell () {
        if isDatePickerShown {
            self.toggleDatePickerForSelectedIndexPath(NSIndexPath(forRow: 2, inSection: 1))
        }
    }
    
    func cellSelectionForIndexPath (indexPath : NSIndexPath) {
        switch (indexPath.row) {
        case 0:
            let statusViewController : DCAdministrationStatusTableViewController = DCAdministrationHelper.administratedStatusPopOverAtIndexPathWithStatus(indexPath, status:ADMINISTERED)
            statusViewController.medicationDetails = medicationDetails
            statusViewController.previousSelectedValue = NOT_ADMINISTRATED
            statusViewController.medicationStatusDelegate = self
            self.navigationController!.pushViewController(statusViewController, animated: true)
            break
        case 1:
            self.collapseOpenedPickerCell()
            let reasonViewController : DCAdministrationReasonViewController = DCAdministrationHelper.administratedReasonPopOverAtIndexPathWithStatus(NOT_ADMINISTRATED)
            reasonViewController.delegate = self
            reasonViewController.isValid = isValid
            if let reasonString = self.medicationSlot?.medicationAdministration?.statusReason {
                reasonViewController.previousSelection = reasonString
                reasonViewController.secondaryReason = self.medicationSlot?.medicationAdministration?.secondaryReason
            }
            self.navigationController!.pushViewController(reasonViewController, animated: true)
        case 2:
            self.toggleDatePickerForSelectedIndexPath(indexPath)
        default:
            break
        }
    }
    
    func medicationAdministrationDetailsInSecondSectionAtIndexPath (indexPath : NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return self.administrationFailureStatusTableCellAtIndexPath(indexPath)
        case 1:
            return self.administrationFailureReasonTableCellAtIndexPath(indexPath)
        case 2:
            return self.administrationFailureDateAndTimeTableCellAtIndexPath(indexPath)
        case 3:
            return datePickerTableCellAtIndexPath(indexPath)
        default :
            return self.administrationFailureStatusTableCellAtIndexPath(indexPath)
        }
    }
    
    func toggleDatePickerForSelectedIndexPath(indexPath : NSIndexPath) {
        
        administrationFailureTableView.beginUpdates()
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)]
        // check if 'indexPath' has an attached date picker below it
        if (isDatePickerShown) {
            // found a picker below it, so remove it
            administrationFailureTableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
            isDatePickerShown = false
        } else {
            // didn't find a picker below it, so we should insert it
            administrationFailureTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
            isDatePickerShown = true
        }
        administrationFailureTableView.endUpdates()
    }
    
    func isValidReason() -> Bool {
        var reasonValidity = true
        let reason = medicationSlot?.medicationAdministration?.statusReason!
        let secondaryReason = self.medicationSlot?.medicationAdministration?.secondaryReason
        if (reason == nil || reason == EMPTY_STRING) {
            reasonValidity = false
        }
        if (reason == "Not Administered other" && (secondaryReason == EMPTY_STRING || secondaryReason == nil)) {
            reasonValidity = false
        }
        return reasonValidity
    }
    
    func isValidNotes () -> Bool {
        var notesValidity = true
        if (medicationSlot?.medicationAdministration?.isEarlyAdministration == true || medicationSlot?.medicationAdministration?.isLateAdministration == true) {
            if (medicationSlot?.medicationAdministration?.refusedNotes == nil || medicationSlot?.medicationAdministration?.refusedNotes == EMPTY_STRING) {
                notesValidity = false
            }
        }
        return notesValidity
    }
    
    // MARK: NotesCell Delegate Methods
    
    func notesSelected(editing : Bool, withIndexPath indexPath : NSIndexPath) {
        self.collapseOpenedPickerCell()
    }
    
    func enteredNote(note : String) {
        medicationSlot?.medicationAdministration?.refusedNotes = note
    }
    
    // mark:StatusList Delegate Methods
    func selectedMedicationStatusEntry(status: String!) {
        
        let parentView : DCAdministrationStatusSelectionViewController = self.parentViewController as! DCAdministrationStatusSelectionViewController
        medicationSlot?.medicationAdministration?.status = status
        parentView.updateViewWithChangeInStatus(status)
    }
    
    // MARK:AdministerPickerCellDelegate Methods

    func reasonSelected(reason: String, secondaryReason : String) {
    
        self.medicationSlot?.medicationAdministration?.statusReason = reason
        self.medicationSlot?.medicationAdministration?.secondaryReason = secondaryReason
        self.administrationFailureTableView.reloadData()
    }
    
    // MARK: - keyboard Delegate Methods
    
    func keyboardDidShow(notification : NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                        let contentInsets: UIEdgeInsets
                        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0)
                        self.administrationFailureTableView.contentInset = contentInsets;
                        self.administrationFailureTableView.scrollIndicatorInsets = contentInsets;
                        self.administrationFailureTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            }
        }
    }
    
    func keyboardDidHide(notification :NSNotification){
        
        let contentInsets:UIEdgeInsets  = UIEdgeInsetsZero;
        administrationFailureTableView.contentInset = contentInsets;
        administrationFailureTableView.scrollIndicatorInsets = contentInsets;
        administrationFailureTableView.beginUpdates()
        administrationFailureTableView.endUpdates()
    }
}