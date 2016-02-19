//
//  DCAdministrationSuccessViewController.swift
//  DrugChart
//
//  Created by aliya on 18/02/16.
//
//

import Foundation

class DCAdministrationSuccessViewController: UIViewController ,NotesCellDelegate,BatchCellDelegate {
    
    //MARK: Variables
    
    @IBOutlet weak var administerSuccessTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var medicationSlot : DCMedicationSlot?
    var medicationDetails : DCMedicationScheduleDetails?
    var datePickerIndexPath : NSIndexPath?
    var administrationSuccessReason: NSString = EMPTY_STRING

    //MARK: View Management Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Configuring Table View Cells
    
    //Medication Details Cell
    func medicationDetailsCellAtIndexPath (indexPath :NSIndexPath) -> UITableViewCell {
        
            let cell = administerSuccessTableView.dequeueReusableCellWithIdentifier("DurationBasedInfusionCell") as? DCDurationBasedMedicationDetailsCell
            if let _ = medicationDetails {
                cell!.configureMedicationDetails(medicationDetails!)
            }
            return cell!
        }
    
    // Administration Status Cell
    func administrationStatusTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.detailLabel.text = STATUS
        administerCell.detailTextLabel?.text = ADMINISTERED
        return administerCell
    }
    
    // Checked By Cell
    func administrationCheckedByTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.detailLabel.text = "Checked By"
        administerCell.detailTextLabel?.text = ""
        return administerCell
    }
    
    // Administation reason Cell
    func administrationReasonTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.detailLabel.text = REASON
        administerCell.detailTextLabel?.text = administrationSuccessReason as String
        return administerCell
    }
    
    //Date Cell
    func administrationDateAndTimeTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.None
        administerCell.detailLabel.text = "Date and Time"
        administerCell.detailTextLabel?.text = ""
        return administerCell
    }
    
    // Notes Cell
    func notesTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCNotesTableCell) {
        
        let notesCell : DCNotesTableCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(NOTES_CELL_ID) as? DCNotesTableCell)!
        notesCell.selectedIndexPath = indexPath
        notesCell.delegate = self
        return notesCell
    }
    
    //Batch number or Dose cell
    func batchNumberOrExpiryDateTableCellAtIndexPathWithLabel(indexPath: NSIndexPath, label: NSString) -> (DCBatchNumberCell) {
        
        let expiryCell : DCBatchNumberCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(BATCH_NUMBER_CELL_ID) as? DCBatchNumberCell)!
        expiryCell.batchDelegate = self
        expiryCell.batchNumberTextField.placeholder = label as String
        expiryCell.selectedIndexPath = indexPath
        return expiryCell;
    }
    
    //Date picker Cell
    func datePickerTableCellAtIndexPath (indexPath : NSIndexPath) -> (UITableViewCell) {
    
        let pickerCell : DCDatePickerCell = (administerSuccessTableView.dequeueReusableCellWithIdentifier(DATE_STATUS_PICKER_CELL_IDENTIFIER) as? DCDatePickerCell)!
    pickerCell.configureDatePickerProperties()
        pickerCell.selectedDate = { date in
            self.medicationSlot!.medicationAdministration.actualAdministrationTime = date
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
    //MARK: TableView Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if hasInlineDatePicker() {
                return 7
            }
            return 6
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            //Medication details cell
            return self.medicationDetailsCellAtIndexPath(indexPath)
        case 1:
            //reason cell
            return self.medicationAdministrationDetailsInSecondSectionAtIndexPath(indexPath)!
        case 2:
            //Notes cell
            return self.notesTableCellAtIndexPath(indexPath)
        default :
            return self.medicationDetailsCellAtIndexPath(indexPath)
        }
    }

//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//    }
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    }
    func medicationAdministrationDetailsInSecondSectionAtIndexPath (indexPath : NSIndexPath) -> UITableViewCell? {
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
        return self.administrationDateAndTimeTableCellAtIndexPath(indexPath)
    case 4:
        if (hasInlineDatePicker()) {
            return datePickerTableCellAtIndexPath(indexPath)
        } else {
            return self.administrationCheckedByTableCellAtIndexPath(indexPath)
        }
    default :
        return nil
    }
    }
    
    // MARK: BatchNumberCellDelegate Methods
    
    func batchNumberFieldSelectedAtIndexPath(indexPath: NSIndexPath) {

    }
    
    func enteredBatchDetails(batch : String) {
        medicationSlot?.medicationAdministration?.batch = batch
    }
    
    // MARK: NotesCell Delegate Methods
    
    func notesSelected(editing : Bool, withIndexPath indexPath : NSIndexPath) {
        
    }
    
    func enteredNote(note : String) {
    }
    
    // mark:StatusList Delegate Methods
    
    func selectedMedicationStatusEntry(status: String!) {

    }
    
    // MARK: NamesList Delegate Methods
    
    func selectedUserEntry(user : DCUser!) {
        
    }

}
