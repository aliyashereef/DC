//
//  DCAdministrationInProgressViewController.swift
//  DrugChart
//
//  Created by aliya on 25/02/16.
//
//

import Foundation

class DCAdministrationInProgressViewController : UIViewController,StatusListDelegate,NotesCellDelegate {
    
    @IBOutlet weak var administerInProgressTableView: UITableView!
    var medicationSlot : DCMedicationSlot?
    var medicationDetails : DCMedicationScheduleDetails?
    var isDatePickerShown : Bool = false

    override func viewDidLoad() {
        
        super.viewDidLoad()
        initialiseMedicationSlotObject()
        configureTableViewProperties()
    }
    
    // MARK: Private Methods
    func initialiseMedicationSlotObject () {
        
        //initialise Medication Slot object
        if (medicationSlot == nil) {
            medicationSlot = DCMedicationSlot.init()
        }
        if(medicationSlot?.medicationAdministration == nil) {
            medicationSlot?.medicationAdministration = DCMedicationAdministration.init()
            medicationSlot?.medicationAdministration.checkingUser = DCUser.init()
            medicationSlot?.medicationAdministration.administratingUser = DCUser.init()
        }
    }
    func configureTableViewProperties (){
        
        self.administerInProgressTableView.rowHeight = UITableViewAutomaticDimension
        self.administerInProgressTableView.estimatedRowHeight = 44.0
        self.administerInProgressTableView.tableFooterView = UIView(frame: CGRectZero)
        administerInProgressTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    }
    
    //MARK: Configuring Table View Cells
    
    //Medication Details Cell
    func medicationDetailsCellAtIndexPath (indexPath :NSIndexPath) -> UITableViewCell {
        
        let cell = administerInProgressTableView.dequeueReusableCellWithIdentifier("DurationBasedInfusionCell") as? DCDurationBasedMedicationDetailsCell
        if let _ = medicationDetails {
            cell!.configureMedicationDetails(medicationDetails!)
        }
        return cell!
    }
    
    // Administration Status Cell
    func administrationStatusTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administerInProgressTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.detailLabelTrailingSpace.constant = 0.0
        administerCell.titleLabel.text = STATUS
        administerCell.detailLabel?.text = medicationSlot?.medicationAdministration.status
        return administerCell
    }
    
    //Date Cell
    func administrationDateAndTimeTableCell() -> DCAdministerCell {
        
        let administerCell : DCAdministerCell = (administerInProgressTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.None
        administerCell.titleLabel.text = "Date & Time"
        administerCell.detailLabelTrailingSpace.constant = 15.0
        var dateString : String = EMPTY_STRING
        if let date = medicationSlot?.medicationAdministration?.actualAdministrationTime {
                dateString = DCDateUtility.dateStringFromDate(date, inFormat: ADMINISTER_DATE_TIME_FORMAT)
        }
        administerCell.detailLabel?.text = dateString
        return administerCell
    }
    
    //Date picker Cell
    func datePickerTableCellAtIndexPath (indexPath : NSIndexPath) -> (UITableViewCell) {
        let pickerCell : DCDatePickerCell = (administerInProgressTableView.dequeueReusableCellWithIdentifier(DATE_STATUS_PICKER_CELL_IDENTIFIER) as? DCDatePickerCell)!
        pickerCell.configureDatePickerProperties()
        pickerCell.selectedDate = { date in
            self.medicationSlot!.medicationAdministration.actualAdministrationTime = date
            self.administerInProgressTableView .reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)], withRowAnimation:UITableViewRowAnimation.None)
        }
        return pickerCell;
    }
    
    // Notes Cell
    func notesTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCNotesTableCell) {
        
        let notesCell : DCNotesTableCell = (administerInProgressTableView.dequeueReusableCellWithIdentifier(NOTES_CELL_ID) as? DCNotesTableCell)!
        notesCell.selectedIndexPath = indexPath
        notesCell.notesType = eNotes
        notesCell.delegate = self
        return notesCell
    }
    
    //MARK: TableView Delegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            if ((medicationSlot?.medicationAdministration.status) != nil) {
                if isDatePickerShown {
                    return 3
                }else {
                    return 2
                }
            } else {
                return 1
            }
        case 3:
            return 1
        default :
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if ((medicationSlot!.medicationAdministration.status) != nil) {
            return 4
        } else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            return self.medicationDetailsCellAtIndexPath(indexPath)
        case 1:
            // cell for graph
            let cell = administerInProgressTableView.dequeueReusableCellWithIdentifier("progressViewDisplayCell") as? DCAdministerProgressViewGraphCell
            return cell!

        case 2:
            switch indexPath.row {
            case 0:
                return self.administrationStatusTableCellAtIndexPath(indexPath)
            case 1:
                return self.administrationDateAndTimeTableCell()
            default:
                return self.datePickerTableCellAtIndexPath(indexPath)
            }
        default:
            return self.notesTableCellAtIndexPath(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            return UITableViewAutomaticDimension
        case SectionCount.eFirstSection.rawValue:
                return 70
        case SectionCount.eSecondSection.rawValue:
            if indexPath.row == 2 {
                return DATE_PICKER_VIEW_CELL_HEIGHT
            } else {
                return 44
            }
        default:
            return NOTES_CELL_HEIGHT
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        administerInProgressTableView.deselectRowAtIndexPath(indexPath, animated: true)
        let notesCell : DCNotesTableCell = (administerInProgressTableView.dequeueReusableCellWithIdentifier(NOTES_CELL_ID) as? DCNotesTableCell)!
        if notesCell.notesTextView.isFirstResponder() {
            notesCell.notesTextView.resignFirstResponder()
        }
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            self.collapseOpenedDatePicker()
            self.navigationController?.pushViewController(DCAdministrationHelper.addBNFView(), animated: true)
            break
        case SectionCount.eSecondSection.rawValue:
            switch indexPath.row {
            case 0:
                let statusViewController : DCAdministrationStatusTableViewController = DCAdministrationHelper.administratedStatusPopOverAtIndexPathWithStatus(indexPath, status:IN_PROGRESS)
                statusViewController.previousSelectedValue = self.medicationSlot?.medicationAdministration?.status
                statusViewController.medicationStatusDelegate = self
                self.collapseOpenedDatePicker()
                self.navigationController!.pushViewController(statusViewController, animated: true)
                break
            case 1:
                self.toggleDatePickerForSelectedIndexPath(indexPath)
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    func collapseOpenedDatePicker () {
        if isDatePickerShown {
            self.toggleDatePickerForSelectedIndexPath(NSIndexPath(forRow: 1, inSection: 2))
        }
    }
    
    func toggleDatePickerForSelectedIndexPath(indexPath : NSIndexPath) {
        
        administerInProgressTableView.beginUpdates()
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)]
        // check if 'indexPath' has an attached date picker below it
        if (isDatePickerShown) {
            // found a picker below it, so remove it
            administerInProgressTableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
            isDatePickerShown = false
        } else {
            // didn't find a picker below it, so we should insert it
            administerInProgressTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
            isDatePickerShown = true
        }
        administerInProgressTableView.endUpdates()
    }
    
    // mark:StatusList Delegate Methods
    func selectedMedicationStatusEntry(status: String!) {
        
//        let parentView : DCAdministrationStatusSelectionViewController = self.parentViewController as! DCAdministrationStatusSelectionViewController
        medicationSlot?.medicationAdministration.status = status
        self.administerInProgressTableView.reloadData()
    }
    
    // MARK: NotesCell Delegate Methods
    func notesSelected(editing : Bool, withIndexPath indexPath : NSIndexPath) {
        self.collapseOpenedDatePicker()
    }
    
    func enteredNote(note : String) {
        
    }
    
    
}
