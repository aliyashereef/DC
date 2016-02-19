//
//  DCAdministrationFailureViewController.swift
//  DrugChart
//
//  Created by aliya on 18/02/16.
//
//

import Foundation

class DCAdministrationFailureViewController: UIViewController ,NotesCellDelegate{
    
    @IBOutlet var administrationFailureTableView: UITableView!
    
    //MARK: Variables
    
    var administrationFailureReason : NSString = EMPTY_STRING
    var dateAndTime : NSString = EMPTY_STRING
    var medicationSlot : DCMedicationSlot?
    var medicationDetails : DCMedicationScheduleDetails?
    var isDatePickerShown : Bool = false

    //MARK: View Management Methods
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    //MARK: Configuring Table View Cells
    
    //Medication Details Cell
    func medicationDetailsCellAtIndexPath (indexPath :NSIndexPath) -> UITableViewCell {
        
        let cell = administrationFailureTableView.dequeueReusableCellWithIdentifier("DurationBasedInfusionCell") as? DCDurationBasedMedicationDetailsCell
        if let _ = medicationDetails {
            cell!.configureMedicationDetails(medicationDetails!)
        }
        return cell!
    }
    
    // Administration Status Cell
    func administrationFailureStatusTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administrationFailureTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.detailLabel.text = STATUS
        administerCell.detailTextLabel?.text = NOT_ADMINISTRATED
        return administerCell
    }
    
    // Administation reason Cell
    func administrationFailureReasonTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administrationFailureTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.detailLabel.text = REASON
        administerCell.detailTextLabel?.text = administrationFailureReason as String
        return administerCell
    }
    
    //Date Cell
    func administrationFailureDateAndTimeTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administrationFailureTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.None
        administerCell.detailLabel.text = "Date and Time"
        administerCell.detailTextLabel?.text = dateAndTime as String
        return administerCell
    }
    
    // Notes Cell
    func notesTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCNotesTableCell) {
        
        let notesCell : DCNotesTableCell = (administrationFailureTableView.dequeueReusableCellWithIdentifier(NOTES_CELL_ID) as? DCNotesTableCell)!
        notesCell.selectedIndexPath = indexPath
        notesCell.delegate = self
        return notesCell
    }
    
    //Date picker Cell
    
    func datePickerTableCellAtIndexPath (indexPath : NSIndexPath) -> (UITableViewCell) {
        
        let pickerCell : DCDatePickerCell = (administrationFailureTableView.dequeueReusableCellWithIdentifier(DATE_STATUS_PICKER_CELL_IDENTIFIER) as? DCDatePickerCell)!
        pickerCell.configureDatePickerProperties()
        pickerCell.selectedDate = { date in
            self.medicationSlot!.medicationAdministration.actualAdministrationTime = date
        }
        return pickerCell;
    }
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//    }

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
    // MARK: NotesCell Delegate Methods
    
    func notesSelected(editing : Bool, withIndexPath indexPath : NSIndexPath) {
        
    }
    
    func enteredNote(note : String) {
    }

}