//
//  DCAdministrationFailureViewController.swift
//  DrugChart
//
//  Created by aliya on 18/02/16.
//
//

import Foundation

class DCAdministrationFailureViewController: DCBaseViewController ,NotesCellDelegate , StatusListDelegate, reasonDelegate{
    
    @IBOutlet var administrationFailureTableView: UITableView!
    
    //MARK: Variables
    
    var dateAndTime : NSString = EMPTY_STRING
    var medicationSlot : DCMedicationSlot?
    var medicationDetails : DCMedicationScheduleDetails?
    var isDatePickerShown : Bool = false

    //MARK: View Management Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseMedicationSlotObject()
        configureTableViewProperties()
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
        medicationSlot?.medicationAdministration.administratingUser = DCUser.init()
        medicationSlot?.medicationAdministration.scheduledDateTime = medicationSlot?.time
        medicationSlot?.medicationAdministration.statusReason = EMPTY_STRING
        medicationSlot?.medicationAdministration?.actualAdministrationTime = DCDateUtility.dateInCurrentTimeZone(NSDate())
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
        medicationSlot?.medicationAdministration.status = NOT_ADMINISTRATED
        administerCell.detailLabel?.text = NOT_ADMINISTRATED
        return administerCell
    }
    
    // Administation reason Cell
    func administrationFailureReasonTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administrationFailureTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.titleLabel.text = REASON
        administerCell.detailLabel?.text = self.medicationSlot?.medicationAdministration.statusReason
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
        notesCell.delegate = self
        return notesCell
    }
    
    //Date picker Cell
    
    func datePickerTableCellAtIndexPath (indexPath : NSIndexPath) -> (UITableViewCell) {
        
        let pickerCell : DCDatePickerCell = (administrationFailureTableView.dequeueReusableCellWithIdentifier(DATE_STATUS_PICKER_CELL_IDENTIFIER) as? DCDatePickerCell)!
        pickerCell.configureDatePickerProperties()
        pickerCell.datePicker?.maximumDate = NSDate()
        pickerCell.selectedDate = { date in
            self.medicationSlot!.medicationAdministration.actualAdministrationTime = date
            self.administrationFailureTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:RowCount.eSecondRow.rawValue, inSection:1)], withRowAnimation: UITableViewRowAnimation.None)
        }
        return pickerCell;
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
    
    func collapseOpenedPickerCell () {
        if isDatePickerShown {
            self.toggleDatePickerForSelectedIndexPath(NSIndexPath(forRow: 2, inSection: 1))
        }
    }
    
    func cellSelectionForIndexPath (indexPath : NSIndexPath) {
        switch (indexPath.row) {
        case 0:
            let statusViewController : DCAdministrationStatusTableViewController = DCAdministrationHelper.administratedStatusPopOverAtIndexPathWithStatus(indexPath, status:ADMINISTERED)
            statusViewController.previousSelectedValue = self.medicationSlot?.medicationAdministration?.status
            statusViewController.medicationStatusDelegate = self
            self.navigationController!.pushViewController(statusViewController, animated: true)
            break
        case 1:
            self.collapseOpenedPickerCell()
            let reasonViewController : DCAdministrationReasonViewController = DCAdministrationHelper.administratedReasonPopOverAtIndexPathWithStatus(NOT_ADMINISTRATED)
            reasonViewController.delegate = self
            if let reasonString = self.medicationSlot?.medicationAdministration.statusReason {
                reasonViewController.previousSelection = reasonString
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
    // MARK: NotesCell Delegate Methods
    
    func notesSelected(editing : Bool, withIndexPath indexPath : NSIndexPath) {
        self.collapseOpenedPickerCell()
        self.administrationFailureTableView.contentOffset = CGPointMake(0, 200)
    }
    
    func enteredNote(note : String) {
        medicationSlot?.medicationAdministration?.refusedNotes = note        
    }
    
    // mark:StatusList Delegate Methods
    func selectedMedicationStatusEntry(status: String!) {
        
        let parentView : DCAdministrationStatusSelectionViewController = self.parentViewController as! DCAdministrationStatusSelectionViewController
        medicationSlot?.medicationAdministration.status = status
        parentView.updateViewWithChangeInStatus(status)
    }
    
    // MARK:AdministerPickerCellDelegate Methods

    func reasonSelected(reason: String) {
        
        self.medicationSlot?.medicationAdministration.statusReason = reason
        self.administrationFailureTableView.reloadData()
    }
    
    // MARK: - keyboard Delegate Methods
    
     func keyboardDidShow(notification: NSNotification) {
        // notification methods
        let info:NSDictionary = notification.userInfo!
        let kbSize:CGSize = (info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue.size)!
        let contentInsets:UIEdgeInsets = UIEdgeInsetsMake(0.0,0.0,kbSize.height,0.0)
        administrationFailureTableView.contentInset = contentInsets
        administrationFailureTableView.scrollIndicatorInsets = contentInsets

    }
    
}