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
let INITIAL_SECTION_ROW_COUNT : NSInteger = 2
let STATUS_ROW_COUNT : NSInteger = 1
let ADMINISTERED_SECTION_ROW_COUNT : NSInteger = 4
let OMITTED_OR_REFUSED_SECTION_ROW_COUNT : NSInteger = 1
let NOTES_SECTION_ROW_COUNT : NSInteger = 1
let INITIAL_SECTION_HEIGHT : CGFloat = 0.0
let TABLEVIEW_DEFAULT_SECTION_HEIGHT : CGFloat = 20.0
let MEDICATION_DETAILS_SECTION_HEIGHT : CGFloat = 40.0
let MEDICATION_DETAILS_CELL_INDEX : NSInteger = 1
let DATE_PICKER_VIEW_CELL_HEIGHT : CGFloat = 200.0

enum SectionCount : NSInteger {

    case eZerothSection = 0
    case eFirstSection
    case eSecondSection
    case eThirdSection
}

class DCAdministerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotesCellDelegate, BatchNumberCellDelegate, NamesListDelegate, AdministerPickerCellDelegate {

    @IBOutlet weak var administerTableView: UITableView!
    @IBOutlet weak var alertMessageLabel: UILabel!
    
    var medicationSlot : DCMedicationSlot?
    var medicationDetails : DCMedicationScheduleDetails?
    var usersListWebService : DCUsersListWebService?
    var statusCellSelected : Bool = false
    var userListArray : NSMutableArray? = []
    var popOverIndexPath : NSIndexPath?
    var alertMessage : NSString = EMPTY_STRING
    var datePickerIndexPath : NSIndexPath?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureViewElements()
        fetchAdministersAndPrescribersList()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        usersListWebService?.cancelPreviousRequest()
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private Methods
    
    func configureViewElements () {
        
        if (medicationSlot == nil) {
            medicationSlot = DCMedicationSlot.init()
        }
        if(medicationSlot?.administerMedication == nil) {
            medicationSlot?.administerMedication = DCAdministerMedication.init()
            medicationSlot?.administerMedication.medicationStatus = ADMINISTERED
        }
        administerTableView!.layoutMargins = UIEdgeInsetsZero
        administerTableView!.separatorInset = UIEdgeInsetsZero
        if (alertMessage != EMPTY_STRING) {
            alertMessageLabel.hidden = false
            alertMessageLabel.text = alertMessage as String
        } else {
            alertMessageLabel.hidden = true
        }
    }

    func fetchAdministersAndPrescribersList () {
        
        //fetch administers and prescribers list
        usersListWebService = DCUsersListWebService.init()
        usersListWebService!.getUsersListWithCallback { (users, error) -> Void in
            if (error == nil) {
                for userDict in users {
                    let displayName = userDict["displayName"] as! String?
                    self.userListArray! .addObject(displayName!)
                }
                self.userListArray!.insertObject(SELF_ADMINISTERED_TITLE, atIndex: 0)
            }
        }
     }
    
    func configureAdministerTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        var administerCell : DCAdministerCell = (administerTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        switch indexPath.section {
        case 0:
            let dateString : String
            if indexPath.row == 0 {
                if let date = medicationSlot?.time {
                    dateString = DCDateUtility.convertDate(date, fromFormat: DEFAULT_DATE_FORMAT, toFormat: "d LLLL yyyy")
                } else {
                    let currentDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
                    dateString = DCDateUtility.convertDate(currentDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: "d LLLL yyyy")
                }
                administerCell.titleLabel.text = dateString
            }
            administerCell.layoutMargins = UIEdgeInsetsZero
            administerCell.accessoryType = UITableViewCellAccessoryType.None
            break;
        case 1:
            administerCell = getPopulatedMedicationStatusTableCellAtIndexPath(administerCell, indexPath: indexPath);
            administerCell.layoutMargins = UIEdgeInsetsZero
            break;
        case 2:
            if (medicationSlot?.administerMedication?.medicationStatus == ADMINISTERED) {
                administerCell = getPopulatedMedicationDetailsCellForAdministeredStatus(administerCell, indexPath: indexPath)
            }
            else if (medicationSlot?.administerMedication?.medicationStatus == REFUSED) {
                administerCell = getMedicationDetailsCellForRefusedStatus(administerCell, indexPath: indexPath)
            }
            administerCell.accessoryType = UITableViewCellAccessoryType.None
            break
        default:
            break;
        }
        return administerCell
    }
    
    func getPopulatedMedicationDetailsCellForAdministeredStatus(cell : DCAdministerCell, indexPath: NSIndexPath) -> (DCAdministerCell) {
        
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = NSLocalizedString("ADMINISTERED_BY", comment: "administered by title")
            cell.detailLabel.text = (medicationSlot?.administerMedication.administeredBy != nil) ? (medicationSlot?.administerMedication.administeredBy) : DEFAULT_DOCTOR_NAME
            break
        case 1:
            cell.titleLabel.text = NSLocalizedString("DATE_TIME", comment: "date and time")
            let dateString : String
            if let date = medicationSlot?.administerMedication.medicationTime {
                dateString = DCDateUtility.convertDate(DCDateUtility.getDateInCurrentTimeZone(date), fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
            } else {
                let currentDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
                dateString = DCDateUtility.convertDate(currentDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
            }
            cell.detailLabel.text = dateString
            break
        case 2:
            //presnt inline picker here
            cell.titleLabel.text = NSLocalizedString("CHECKED_BY", comment: "Checked by title")
            cell.detailLabel.text = (medicationSlot?.administerMedication.checkedBy != nil) ? (medicationSlot?.administerMedication.checkedBy) : DEFAULT_NURSE_NAME
            break;
        case 4:
            break
        default:
            break
        }
        
        return cell
    }
    
    func getMedicationDetailsCellForRefusedStatus(cell : DCAdministerCell, indexPath: NSIndexPath) -> (DCAdministerCell) {
        
        cell.titleLabel.text = NSLocalizedString("DATE_TIME", comment: "date and time")
        let dateString : String
        if let date = medicationSlot?.administerMedication.medicationTime {
            dateString = DCDateUtility.convertDate(DCDateUtility.getDateInCurrentTimeZone(date), fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
        } else {
            let currentDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
            dateString = DCDateUtility.convertDate(currentDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
        }
        cell.detailLabel.text = dateString
        return cell
    }
    
    func getBatchNumberOrExpiryDateTableCellAtIndexPath(indexPath: NSIndexPath) -> (DCBatchNumberCell) {
        
        let expiryCell : DCBatchNumberCell = (administerTableView.dequeueReusableCellWithIdentifier(BATCH_NUMBER_CELL_ID) as? DCBatchNumberCell)!
        expiryCell.delegate = self
        return expiryCell;
    }
    
    func getPopulatedMedicationDetailsCellForRefusedStatus(cell : DCAdministerCell, indexPath: NSIndexPath) -> (DCAdministerCell) {
        
        return cell
    }
    
    func getPopulatedMedicationDetailsCellForOmittedStatus(cell : DCAdministerCell, indexPath: NSIndexPath) -> (DCAdministerCell) {
        
        return cell
    }
    
    func getPopulatedMedicationStatusTableCellAtIndexPath(cell : DCAdministerCell, indexPath: NSIndexPath) -> (DCAdministerCell) {
        
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = NSLocalizedString("STATUS", comment: "status title text")
            if (medicationSlot?.administerMedication?.medicationStatus != nil) {
                cell.detailLabel.text = medicationSlot?.administerMedication?.medicationStatus
            } else {
                cell.detailLabel.text = ADMINISTERED
            }
            cell.accessoryType = UITableViewCellAccessoryType.None
            return cell
        case 1:
            cell.titleLabel.text = ADMINISTERED
            cell.detailLabel.text = EMPTY_STRING
            cell.accessoryType = (medicationSlot?.administerMedication.medicationStatus == ADMINISTERED) ?UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            return cell
        case 2:
            cell.titleLabel.text = REFUSED
            cell.detailLabel.text = EMPTY_STRING
            cell.accessoryType = (medicationSlot?.administerMedication.medicationStatus == REFUSED) ?UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            return cell
        case 3:
            cell.titleLabel.text = OMITTED
            cell.detailLabel.text = EMPTY_STRING
            cell.accessoryType = (medicationSlot?.administerMedication.medicationStatus == OMITTED) ?UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            return cell
        default:
            return cell
        }
    }
    
    func getNotesTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCNotesTableCell) {
        
        let notesCell : DCNotesTableCell = (administerTableView.dequeueReusableCellWithIdentifier(NOTES_CELL_ID) as? DCNotesTableCell)!
        notesCell.delegate = self
        return notesCell
    }
    
    func configureMedicationDetailsCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerMedicationDetailsCell) {
        
        let medicationCell : DCAdministerMedicationDetailsCell = (administerTableView.dequeueReusableCellWithIdentifier(ADMINISTER_MEDICATION_DETAILS_CELL_ID) as? DCAdministerMedicationDetailsCell!)!
        if medicationDetails != nil {
            medicationCell.populateCellWithMedicationDetails(medicationDetails!)
        }
        return medicationCell
    }
    
    func presentPrescribersAndAdministersPopOverViewAtIndexPath (indexPath : NSIndexPath) {
        
        popOverIndexPath = indexPath
        let namesViewController : NameSelectionTableViewController? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(NAMES_LIST_VIEW_STORYBOARD_ID) as? NameSelectionTableViewController
        namesViewController?.namesArray = userListArray
        namesViewController?.namesDelegate = self
        if (indexPath.row == 0) {
            namesViewController!.previousSelectedValue = medicationSlot?.administerMedication.administeredBy
        } else if (indexPath.row == 2) {
           namesViewController!.previousSelectedValue = medicationSlot?.administerMedication.checkedBy
        }
        let navigationController : UINavigationController? = UINavigationController(rootViewController: namesViewController!)
        navigationController?.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = navigationController?.popoverPresentationController
        namesViewController!.preferredContentSize = CGSizeMake(300,300)
        popover?.permittedArrowDirections = .Up
        popover?.preferredContentSize
        let cell = administerTableView.cellForRowAtIndexPath(indexPath) as! DCAdministerCell?
        popover!.sourceView = cell?.popoverButton
        self.presentViewController(navigationController!, animated: true, completion: nil)
    }
    
    func getDatePickerCellAtIndexPath(indexPath : NSIndexPath) -> DCAdministerPickerCell {
        
        var pickerCell = administerTableView.dequeueReusableCellWithIdentifier(ADMINISTER_PICKER_CELL_ID) as? DCAdministerPickerCell
        if (pickerCell == nil) {
            let bundle = NSBundle(forClass: self.dynamicType)
            let nib = UINib(nibName: "DCAdministerPickerCell", bundle: bundle)
            pickerCell = nib.instantiateWithOwner(self, options: nil)[0] as? DCAdministerPickerCell
        }
        pickerCell?.delegate = self
        return pickerCell!
    }
    
    // MARK: Date Picker Methods
    
    func hasPickerForIndexPath(indexPath : NSIndexPath) -> Bool {
        
        var hasDatePicker : Bool = false
        var targetedRow : NSInteger = indexPath.row
        targetedRow++
        let checkDatePickerCell : UITableViewCell? = administerTableView.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection: indexPath.section))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(101) as? UIDatePicker
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
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: 2)]
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
            administerTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row + 1, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Fade)
            datePickerIndexPath = nil
        }
        if (sameCellClicked == false) {
            // hide the old date picker and display the new one
            let rowToReveal : NSInteger = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal : NSIndexPath = NSIndexPath(forRow: rowToReveal, inSection: 2)
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
            return 1
        } else {

            if (medicationSlot?.administerMedication.medicationStatus == OMITTED) {
                return OMITTED_SECTION_COUNT;
            } else {
                return ADMINISTERED_SECTION_COUNT;
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case SectionCount.eZerothSection.rawValue:
            return INITIAL_SECTION_ROW_COUNT
        case SectionCount.eFirstSection.rawValue:
            return (statusCellSelected ? 4 : STATUS_ROW_COUNT)
        case SectionCount.eSecondSection.rawValue:
            var rowCount = 0
            if (medicationSlot?.administerMedication.medicationStatus  == OMITTED || medicationSlot?.administerMedication.medicationStatus == REFUSED) {
                rowCount = 1
            } else {
                rowCount = ADMINISTERED_SECTION_ROW_COUNT
            }
            if (hasInlineDatePicker()) {
                rowCount++
            }
            return rowCount
        case SectionCount.eThirdSection.rawValue:
            return NOTES_SECTION_ROW_COUNT
        default:
            break;
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0 && indexPath.row == MEDICATION_DETAILS_CELL_INDEX) {
            let medicationDetailsCell : DCAdministerMedicationDetailsCell = configureMedicationDetailsCellAtIndexPath(indexPath)
            return medicationDetailsCell
         } else {
            if (medicationSlot?.administerMedication.medicationStatus == ADMINISTERED) {
                if (indexPath.section == 2 && indexPath.row == 3) {
                    let batchNumberCell : DCBatchNumberCell = getBatchNumberOrExpiryDateTableCellAtIndexPath(indexPath)
                    return batchNumberCell
                } else if (indexPath.section == 3) {
                    let notesCell : DCNotesTableCell = getNotesTableCellAtIndexPath(indexPath)
                    notesCell.notesType = eNotes
                    notesCell.notesTextView.textColor = UIColor.getColorForHexString("#8f8f95")
                    notesCell.notesTextView.text = notesCell.getHintText()
                    return notesCell
                } else {
                    if (indexPath.section == 2 && datePickerIndexPath != nil && indexPath.row == 2) {
                        //display picker
                        let pickerCell : DCAdministerPickerCell = getDatePickerCellAtIndexPath(indexPath)
                        return pickerCell
                    } else {
                        let administerCell : DCAdministerCell = configureAdministerTableCellAtIndexPath(indexPath)
                        return administerCell
                    }
                }
            } else if (medicationSlot?.administerMedication.medicationStatus == OMITTED) {
                if (indexPath.section == 2) {
                    let notesCell : DCNotesTableCell = getNotesTableCellAtIndexPath(indexPath)
                    notesCell.notesType = eReason
                    notesCell.notesTextView.textColor = UIColor.getColorForHexString("#8f8f95")
                    notesCell.notesTextView.text = notesCell.getHintText()
                    return notesCell
                } else {
                    let administerCell : DCAdministerCell = configureAdministerTableCellAtIndexPath(indexPath)
                    return administerCell
                }
            } else {
                //refused status
                if (indexPath.section == 3) {
                    let notesCell : DCNotesTableCell = getNotesTableCellAtIndexPath(indexPath)
                    notesCell.notesType = eReason
                    notesCell.notesTextView.textColor = UIColor.getColorForHexString("#8f8f95")
                    notesCell.notesTextView.text = notesCell.getHintText()
                    return notesCell
                } else {
                    if (indexPath.section == 2 && datePickerIndexPath != nil && indexPath.row == 1) {
                        //display picker
                        let pickerCell : DCAdministerPickerCell = getDatePickerCellAtIndexPath(indexPath)
                        return pickerCell
                    } else {
                        let administerCell : DCAdministerCell = configureAdministerTableCellAtIndexPath(indexPath)
                        return administerCell
                    }
                }
             }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 0) {
            return INITIAL_SECTION_HEIGHT
        } else if (section == 1) {
            return MEDICATION_DETAILS_SECTION_HEIGHT
        } else {
            return TABLEVIEW_DEFAULT_SECTION_HEIGHT
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (indexPath.section == 0 && indexPath.row == 1) {
            return 74.0
        } else if (indexPath.section == 2) {
            if (medicationSlot?.administerMedication.medicationStatus == OMITTED) {
                return 125.0
            } else if (medicationSlot?.administerMedication.medicationStatus == ADMINISTERED) {
                return (indexPath.row == 2 && hasInlineDatePicker()) ? DATE_PICKER_VIEW_CELL_HEIGHT : 41.0
            } else {
                //refused status
                return (indexPath.row == 1 && hasInlineDatePicker()) ? DATE_PICKER_VIEW_CELL_HEIGHT : 41.0
            }
        } else if (indexPath.section == 3) {
            return 125.0
        } else {
            return 41.0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (section == 1) {
            let administerHeaderView = NSBundle.mainBundle().loadNibNamed(ADMINISTER_HEADER_VIEW_NIB, owner: self, options: nil)[0] as? DCAdministerTableHeaderView
            if (medicationSlot?.time != nil) {
                administerHeaderView?.populateScheduledTimeValue((medicationSlot?.time)!)
            }
            return administerHeaderView
        }
        return nil;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 1) {
            let administerIndexPath : NSIndexPath = NSIndexPath(forRow: 1, inSection: 1)
            let omittedIndexpath : NSIndexPath = NSIndexPath(forItem: 2, inSection: 1)
            let refusedIndexPath : NSIndexPath = NSIndexPath(forItem: 3, inSection: 1)
            let indexPathsArray : [NSIndexPath] = [administerIndexPath, omittedIndexpath, refusedIndexPath]
            switch indexPath.row {
            case 0:
                //display status views, insert views below this
                if (statusCellSelected == false) {
                    statusCellSelected = true
                    tableView.insertRowsAtIndexPaths(indexPathsArray, withRowAnimation: .Fade)
                } else {
                    statusCellSelected = false
                }
                break
            case 1:
                medicationSlot?.administerMedication.medicationStatus = ADMINISTERED
                statusCellSelected = false
                break
            case 2:
                medicationSlot?.administerMedication.medicationStatus = REFUSED
                statusCellSelected = false
                break
            case 3:
                medicationSlot?.administerMedication.medicationStatus = OMITTED
                statusCellSelected = false
                break
            default:
                break
            }
            administerTableView .reloadData()
        } else if (indexPath.section == 2) {
            if (medicationSlot?.administerMedication.medicationStatus == ADMINISTERED) {
                if (indexPath.row == 0 || indexPath.row == 2) {
                    presentPrescribersAndAdministersPopOverViewAtIndexPath(indexPath)
                } else if (indexPath.row == 1) {
                    displayInlineDatePickerForRowAtIndexPath(indexPath)
                }
            } else if (medicationSlot?.administerMedication.medicationStatus == REFUSED) {
                if (indexPath.row == 0) {
                    displayInlineDatePickerForRowAtIndexPath(indexPath)
                }
            }
        }
    }
    
    // MARK: BatchNumberCellDelegate Methods
    
    func batchNumberFieldSelected() {
        
        self.administerTableView.setContentOffset(CGPointMake(0, 130), animated: true)
    }
    
    // MARK: NotesCell Delagate Methods
    
    func notesSelected(editing : Bool) {
      
        if (editing == true) {
            self.administerTableView.setContentOffset(CGPointMake(0, 200), animated: true)
        } else {
            self.administerTableView.setContentOffset(CGPointZero, animated: true)
        }
    }
    
    // MARK: NamesList Delegate Methods
    
    func selectedUserEntry(user : String!) {
        
        if (popOverIndexPath?.row == 0) {
            //administered by
            medicationSlot?.administerMedication.administeredBy = user
        } else if (popOverIndexPath?.row == 2) {
            //checked by
            medicationSlot?.administerMedication.checkedBy = user
        }
        administerTableView.reloadRowsAtIndexPaths([popOverIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    // MARK:AdministerPickerCellDelegate Methods
    
    func newDateValueSelected(newDate : NSDate) {
        
        NSLog("selected date is %@", newDate)
        if (datePickerIndexPath != nil) {
            if (datePickerIndexPath?.row == 2 || datePickerIndexPath?.row == 1) {
                medicationSlot?.administerMedication.medicationTime = newDate
                administerTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:datePickerIndexPath!.row - 1, inSection: datePickerIndexPath!.section)], withRowAnimation: UITableViewRowAnimation.None)
            }
        }
    }
}




