//
//  AdministerViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/22/15.
//
//

import UIKit

let ADMINISTERED_SECTION_COUNT : NSInteger = 3
let OMITTED_SECTION_COUNT : NSInteger = 2
let INITIAL_SECTION_ROW_COUNT : NSInteger = 1
let STATUS_ROW_COUNT : NSInteger = 1
let ADMINISTERED_SECTION_ROW_COUNT : NSInteger = 4
let OMITTED_OR_REFUSED_SECTION_ROW_COUNT : NSInteger = 1
let NOTES_SECTION_ROW_COUNT : NSInteger = 1
let INITIAL_SECTION_HEIGHT : CGFloat = 0.0
let TABLEVIEW_DEFAULT_SECTION_HEIGHT : CGFloat = 20.0
let MEDICATION_DETAILS_SECTION_HEIGHT : CGFloat = 40.0
let MEDICATION_DETAILS_CELL_INDEX : NSInteger = 0
let DATE_PICKER_VIEW_CELL_HEIGHT : CGFloat = 200.0
let NOTES_CELL_HEIGHT : CGFloat = 125.0
let TABLE_CELL_DEFAULT_HEIGHT : CGFloat = 41.0
let DATE_PICKER_CELL_TAG : NSInteger = 101
//let ADMINISTER_IN_ONE_HOUR : NSTimeInterval = 60*60
let DISPLAY_SECURITY_PIN_ENTRY : String = "displaySecurityPinEntryViewForUser:"

enum SectionCount : NSInteger {

    case eZerothSection = 0
    case eFirstSection
    case eSecondSection
    case eThirdSection
}

enum RowCount : NSInteger {
    
    case eZerothRow = 0
    case eFirstRow
    case eSecondRow
    case eThirdRow
    case eFourthRow
}

class DCAdministerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotesCellDelegate, BatchNumberCellDelegate, NamesListDelegate, AdministerPickerCellDelegate , SecurityPinMatchDelegate, StatusListDelegate {

    @IBOutlet weak var administerTableView: UITableView!
    @IBOutlet weak var alertMessageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var medicineRouteAndInstructionsLabel: UILabel!
    @IBOutlet var medicineNameLabel: UILabel!
    @IBOutlet var medicineDateLabel: UILabel!
    
    var medicationSlot : DCMedicationSlot?
    var medicationDetails : DCMedicationScheduleDetails?
    var medicationSlotsArray : [DCMedicationSlot] = []
    var usersListWebService : DCUsersListWebService?
    var statusCellSelected : Bool = false
    var userListArray : NSMutableArray? = []
    var popOverIndexPath : NSIndexPath?
    var alertMessage : NSString = EMPTY_STRING
    var datePickerIndexPath : NSIndexPath?
    var isValid : Bool = true
    var weekDate : NSDate?
    
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
        
        initialiseMedicationSlotObject()
        //check if early administration
        if (medicationSlot?.time != nil) {
            checkIfAdministrationIsEarly()
            checkIfFrequentAdministrationForWhenRequiredMedication()
        }
        administerTableView!.layoutMargins = UIEdgeInsetsZero
        administerTableView!.separatorInset = UIEdgeInsetsZero
        administerTableView!.tableFooterView = UIView(frame: CGRectZero)
        if (alertMessage != EMPTY_STRING) {
            alertMessageLabel.hidden = false
            alertMessageLabel.text = alertMessage as String
        } else {
            alertMessageLabel.hidden = true
        }
        configureMedicationDetails()
    }
    
    func configureMedicationDetails () {
        medicineNameLabel.text = medicationDetails!.name
        if (medicationDetails?.route != nil) {
            populateRouteAndInstructionLabels()
        }
        let dateString : String
        if let date = medicationSlot?.time {
            dateString = DCDateUtility.convertDate(date, fromFormat: DEFAULT_DATE_FORMAT, toFormat: "d LLLL yyyy")
        } else {
            dateString = DCDateUtility.convertDate(weekDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: "d LLLL yyyy")
        }
        medicineDateLabel.text = dateString
    }
    
    func populateRouteAndInstructionLabels() {
        let route : String = medicationDetails!.route.stringByReplacingOccurrencesOfString(" ", withString: EMPTY_STRING)
        let attributedRouteString : NSMutableAttributedString = NSMutableAttributedString(string:route, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(16.0)])
        let attributedInstructionsString : NSMutableAttributedString
        let instructionString : String
        if (medicationDetails?.instruction != EMPTY_STRING && medicationDetails?.instruction != nil) {
            instructionString = String(format: " (%@)", (medicationDetails?.instruction)!)
        } else {
            instructionString = " (As Directed)"
        }
        attributedInstructionsString  = NSMutableAttributedString(string: instructionString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12.0)])
        attributedRouteString.appendAttributedString(attributedInstructionsString)
        self.medicineRouteAndInstructionsLabel.attributedText = attributedRouteString;
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
            medicationSlot?.medicationAdministration.status = ADMINISTERED
            medicationSlot?.medicationAdministration.scheduledDateTime = medicationSlot?.time
        }
    }
    
    func resetSavedAdministrationDetails () {
        
        //reset saved administration details
        medicationSlot?.medicationAdministration = nil
    }
    
    func checkIfAdministrationIsEarly () {
        
        //check if administration is early
        let currentSystemDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
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
        if (medicationDetails?.medicineCategory == WHEN_REQUIRED_VALUE) {
            if (medicationSlotsArray.count > 0) {
                let slotIndex = medicationSlotsArray.indexOf(medicationSlot!)
                if (slotIndex != 0) {
                    let previousMedicationSlot : DCMedicationSlot? = medicationSlotsArray[slotIndex! - 1]
                    let currentSystemDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
                    let nextMedicationTimeInterval : NSTimeInterval? = (previousMedicationSlot?.time)!.timeIntervalSinceDate(currentSystemDate)
                    if (nextMedicationTimeInterval >= 2*60*60) {
                        medicationSlot?.medicationAdministration.isEarlyAdministration = true
                        medicationSlot?.medicationAdministration.isWhenRequiredEarlyAdministration = true
                    } else {
                        medicationSlot?.medicationAdministration.isEarlyAdministration = false
                        medicationSlot?.medicationAdministration.isWhenRequiredEarlyAdministration = false
                    }
                }
            }
        }
    }
    
    func fetchAdministersAndPrescribersList () {
        
        //fetch administers and prescribers list
        usersListWebService = DCUsersListWebService.init()
        usersListWebService!.getUsersListWithCallback { (users, error) -> Void in
            if (error == nil) {
                for userDict in users {
                    let displayName = userDict["displayName"] as! String?
                    let identifier = userDict["identifier"] as! String?
                    let user : DCUser = DCUser.init()
                    user.displayName = displayName
                    user.userIdentifier = identifier
                    self.userListArray! .addObject(user)
                }
                let selfAdministratedPatientName = SELF_ADMINISTERED_TITLE
                let selfAdministratedPatientIdentifier = EMPTY_STRING
                let selfAdministratedUser : DCUser = DCUser.init()
                selfAdministratedUser.displayName = selfAdministratedPatientName
                selfAdministratedUser.userIdentifier = selfAdministratedPatientIdentifier
                self.userListArray!.insertObject(selfAdministratedUser, atIndex: 0)
                self.medicationSlot?.medicationAdministration.administratingUser = selfAdministratedUser
                self.medicationSlot?.medicationAdministration.isSelfAdministered = true
                self.administerTableView.reloadData()
            }
        }
     }
    
    func validateAndReloadAdministerView() {
        
        //validate and reload administer view
        isValid = false
        administerTableView.reloadData()
    }
    
    func configureAdministerTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        var administerCell : DCAdministerCell = (administerTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            administerCell = getPopulatedMedicationStatusTableCellAtIndexPath(administerCell, indexPath: indexPath);
            administerCell.layoutMargins = UIEdgeInsetsZero
            break;
        case SectionCount.eFirstSection.rawValue:
            if (medicationSlot?.medicationAdministration?.status == ADMINISTERED) {
                administerCell = getPopulatedMedicationDetailsCellForAdministeredStatus(administerCell, indexPath: indexPath)
            }
            else if (medicationSlot?.medicationAdministration?.status == REFUSED) {
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
        case RowCount.eZerothRow.rawValue:
            cell.titleLabel.text = NSLocalizedString("ADMINISTERED_BY", comment: "administered by title")
            cell.detailLabel.text = (medicationSlot?.medicationAdministration?.administratingUser?.displayName != nil) ? (medicationSlot?.medicationAdministration?.administratingUser?.displayName) : DEFAULT_DOCTOR_NAME
            break
        case RowCount.eFirstRow.rawValue:
            cell.titleLabel.text = NSLocalizedString("DATE_TIME", comment: "date and time")
            let dateString : String
            if let date = medicationSlot?.medicationAdministration.actualAdministrationTime {
                dateString = DCDateUtility.convertDate(DCDateUtility.getDateInCurrentTimeZone(date), fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
            } else {
                dateString = DCDateUtility.convertDate(DCDateUtility.getDateInCurrentTimeZone(NSDate()), fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
            }
            cell.detailLabel.text = dateString
            break
        case RowCount.eSecondRow.rawValue:
            //present inline picker here
            cell.titleLabel.text = NSLocalizedString("CHECKED_BY", comment: "Checked by title")
            cell.detailLabel.text = (medicationSlot?.medicationAdministration?.checkingUser?.displayName != nil) ? (medicationSlot?.medicationAdministration?.checkingUser?.displayName) : DEFAULT_NURSE_NAME
            break;
        case RowCount.eFourthRow.rawValue:
            break
        default:
            break
        }
        
        return cell
    }
    
    func getMedicationDetailsCellForRefusedStatus(cell : DCAdministerCell, indexPath: NSIndexPath) -> (DCAdministerCell) {
        
        cell.titleLabel.text = NSLocalizedString("DATE_TIME", comment: "date and time")
        let dateString : String
        if let date = medicationSlot?.medicationAdministration.actualAdministrationTime {
            dateString = DCDateUtility.convertDate(DCDateUtility.getDateInCurrentTimeZone(date), fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
        } else {
            dateString = DCDateUtility.convertDate(DCDateUtility.getDateInCurrentTimeZone(NSDate()), fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
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
        case RowCount.eZerothRow.rawValue:
            cell.titleLabel.text = NSLocalizedString("STATUS", comment: "status title text")
            if (medicationSlot?.medicationAdministration?.status != nil) {
                cell.detailLabel.text = medicationSlot?.medicationAdministration?.status
            } else {
                cell.detailLabel.text = ADMINISTERED
            }
            cell.accessoryType = UITableViewCellAccessoryType.None
            return cell
        case RowCount.eFirstRow.rawValue:
            cell.titleLabel.text = ADMINISTERED
            cell.detailLabel.text = EMPTY_STRING
            cell.accessoryType = (medicationSlot?.medicationAdministration.status == ADMINISTERED) ?UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            return cell
        case RowCount.eSecondRow.rawValue:
            cell.titleLabel.text = REFUSED
            cell.detailLabel.text = EMPTY_STRING
            cell.accessoryType = (medicationSlot?.medicationAdministration.status == REFUSED) ?UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            return cell
        case RowCount.eThirdRow.rawValue:
            cell.titleLabel.text = OMITTED
            cell.detailLabel.text = EMPTY_STRING
            cell.accessoryType = (medicationSlot?.medicationAdministration.status == OMITTED) ?UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
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
    
//    func configureMedicationDetailsCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerMedicationDetailsCell) {
//        
//        let medicationCell : DCAdministerMedicationDetailsCell = (administerTableView.dequeueReusableCellWithIdentifier(ADMINISTER_MEDICATION_DETAILS_CELL_ID) as? DCAdministerMedicationDetailsCell!)!
//        if medicationDetails != nil {
//            medicationCell.populateCellWithMedicationDetails(medicationDetails!)
//        }
//        return medicationCell
//    }
    
    func presentPrescribersAndAdministersPopOverViewAtIndexPath (indexPath : NSIndexPath) {
        
        popOverIndexPath = indexPath
        let namesViewController : NameSelectionTableViewController? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(NAMES_LIST_VIEW_STORYBOARD_ID) as? NameSelectionTableViewController
        namesViewController?.namesArray = userListArray
        namesViewController?.namesDelegate = self
        if (indexPath.row == RowCount.eZerothRow.rawValue) {
            namesViewController!.previousSelectedValue = medicationSlot?.medicationAdministration?.administratingUser?.displayName
        } else if (indexPath.row == RowCount.eSecondRow.rawValue) {
           namesViewController!.previousSelectedValue = medicationSlot?.medicationAdministration?.checkingUser?.displayName
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
    
    func presentAdministratedStatusPopOverAtIndexPath (indexPath : NSIndexPath) {
        
        let namesViewController : DCAdministrationStatusTableViewController? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(STATUS_LIST_VIEW_SB_ID) as? DCAdministrationStatusTableViewController
        namesViewController?.medicationStatusDelegate = self

        let navigationController : UINavigationController? = UINavigationController(rootViewController: namesViewController!)
        navigationController?.modalPresentationStyle = UIModalPresentationStyle.Popover
        self.presentViewController(navigationController!, animated: true, completion: nil)

        let popover = navigationController?.popoverPresentationController
        namesViewController!.preferredContentSize = CGSizeMake(250,90)
        popover?.permittedArrowDirections = .Up
        popover?.preferredContentSize
        let cell = administerTableView.cellForRowAtIndexPath(indexPath) as! DCAdministerCell?
        popover!.sourceView = cell?.popoverButton
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
    
    func getPopulatedAdministeredTableViewCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == SectionCount.eFirstSection.rawValue && indexPath.row == RowCount.eThirdRow.rawValue) {
            let batchNumberCell : DCBatchNumberCell = getBatchNumberOrExpiryDateTableCellAtIndexPath(indexPath)
            return batchNumberCell
        } else if (indexPath.section == SectionCount.eSecondSection.rawValue) {
            let notesCell : DCNotesTableCell = getNotesTableCellAtIndexPath(indexPath)
            notesCell.notesType = eNotes
            notesCell.notesTextView.textColor = (!isValid && medicationSlot?.medicationAdministration?.isEarlyAdministration == true) ? UIColor.redColor() : UIColor.getColorForHexString("#8f8f95")
            notesCell.notesTextView.text = notesCell.getHintText()
            return notesCell
        } else {
            if (indexPath.section == SectionCount.eFirstSection.rawValue && datePickerIndexPath != nil && indexPath.row == 2) {
                //display picker
                let pickerCell : DCAdministerPickerCell = getDatePickerCellAtIndexPath(indexPath)
                return pickerCell
            } else {
                let administerCell : DCAdministerCell = configureAdministerTableCellAtIndexPath(indexPath)
                return administerCell
            }
        }
    }
    
    func getPopulatedOmittedTableViewCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == SectionCount.eSecondSection.rawValue) {
            let notesCell : DCNotesTableCell = getNotesTableCellAtIndexPath(indexPath)
            notesCell.notesType = eReason
            notesCell.notesTextView.textColor = !isValid ? UIColor.redColor() : UIColor.getColorForHexString("#8f8f95")
            notesCell.notesTextView.text = notesCell.getHintText()
            return notesCell
        } else {
            let administerCell : DCAdministerCell = configureAdministerTableCellAtIndexPath(indexPath)
            return administerCell
        }
    }
    
    func getPopulatedRefusedTableCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == SectionCount.eSecondSection.rawValue) {
            let notesCell : DCNotesTableCell = getNotesTableCellAtIndexPath(indexPath)
            notesCell.notesType = eReason
            notesCell.notesTextView.textColor = (!isValid && medicationSlot?.medicationAdministration?.isEarlyAdministration == true) ? UIColor.redColor() : UIColor.getColorForHexString("#8f8f95")
            notesCell.notesTextView.text = notesCell.getHintText()
            return notesCell
        } else {
            if (indexPath.section == SectionCount.eFirstSection.rawValue && datePickerIndexPath != nil && indexPath.row == 1) {
                //display picker
                let pickerCell : DCAdministerPickerCell = getDatePickerCellAtIndexPath(indexPath)
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
            } else if (medicationSlot?.medicationAdministration?.status == ADMINISTERED || medicationSlot?.medicationAdministration?.status == REFUSED) {
                return ADMINISTERED_SECTION_COUNT;
            } else {
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case SectionCount.eZerothSection.rawValue:
            return (statusCellSelected ? 4 : STATUS_ROW_COUNT)
        case SectionCount.eFirstSection.rawValue:
            var rowCount = 0
            if (medicationSlot?.medicationAdministration?.status  == OMITTED || medicationSlot?.medicationAdministration?.status == REFUSED) {
                rowCount = 1
            } else {
                rowCount = ADMINISTERED_SECTION_ROW_COUNT
            }
            if (hasInlineDatePicker()) {
                rowCount++
            }
            return rowCount
        case SectionCount.eSecondSection.rawValue:
            return NOTES_SECTION_ROW_COUNT
        default:
            break;
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (medicationSlot?.medicationAdministration.status == ADMINISTERED) {
            //configure tablecells for medication status administered
            let administeredTableCell = getPopulatedAdministeredTableViewCellAtIndexPath(indexPath)
            return administeredTableCell
        } else if (medicationSlot?.medicationAdministration.status == OMITTED) {
            let omittedTableCell = getPopulatedOmittedTableViewCellAtIndexPath(indexPath)
            return omittedTableCell
        } else {
            //refused status
            let refusedTableCell = getPopulatedRefusedTableCellAtIndexPath(indexPath)
            return refusedTableCell
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let sectionCount : NSInteger = numberOfSectionsInTableView(tableView)
        if (section == sectionCount - 1 && sectionCount != 1) {
            return (medicationSlot?.medicationAdministration?.isEarlyAdministration == true) ? MEDICATION_DETAILS_SECTION_HEIGHT : TABLEVIEW_DEFAULT_SECTION_HEIGHT
        } else if (section == SectionCount.eZerothSection.rawValue) {
            return MEDICATION_DETAILS_SECTION_HEIGHT
        } else if (section == SectionCount.eFirstSection.rawValue) {
            return 0
        } else {
            return TABLEVIEW_DEFAULT_SECTION_HEIGHT
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
            
        case SectionCount.eZerothSection.rawValue :
            return TABLE_CELL_DEFAULT_HEIGHT
        case SectionCount.eFirstSection.rawValue:
            if (medicationSlot?.medicationAdministration.status == OMITTED) {
                return NOTES_CELL_HEIGHT
            } else if (medicationSlot?.medicationAdministration.status == ADMINISTERED) {
                return (indexPath.row == RowCount.eSecondRow.rawValue && hasInlineDatePicker()) ? DATE_PICKER_VIEW_CELL_HEIGHT : TABLE_CELL_DEFAULT_HEIGHT
            } else {
                //refused status
                return (indexPath.row == RowCount.eFirstRow.rawValue && hasInlineDatePicker()) ? DATE_PICKER_VIEW_CELL_HEIGHT : TABLE_CELL_DEFAULT_HEIGHT
            }
        case SectionCount.eSecondSection.rawValue:
            return NOTES_CELL_HEIGHT
        default:
            return TABLE_CELL_DEFAULT_HEIGHT
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionCount : NSInteger = numberOfSectionsInTableView(tableView)
        if (section == SectionCount.eZerothSection.rawValue || (section == sectionCount - 1 && sectionCount != 1)) {
            let administerHeaderView = NSBundle.mainBundle().loadNibNamed(ADMINISTER_HEADER_VIEW_NIB, owner: self, options: nil)[0] as? DCAdministerTableHeaderView
             administerHeaderView!.backgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
            if (section == SectionCount.eZerothSection.rawValue) {
                if (medicationSlot?.time != nil) {
                    administerHeaderView?.populateScheduledTimeValue((medicationSlot?.time)!)
                }
            } else {
                if (medicationSlot?.medicationAdministration?.isEarlyAdministration == true) {
                    if (medicationSlot?.medicationAdministration?.isWhenRequiredEarlyAdministration == true) {
                        let errorMessage = NSString(format: "%@ %@", NSLocalizedString("ADMIN_FREQUENCY", comment: "when required new medication is given 2 hrs before previous one"), NSLocalizedString("EARLY_ADMIN_INLINE", comment: ""))
                        administerHeaderView?.populateHeaderViewWithErrorMessage(errorMessage as String)
                    } else {
                        administerHeaderView?.populateHeaderViewWithErrorMessage(NSLocalizedString("EARLY_ADMIN_INLINE", comment: "early administration when medication is attempted 1 hr before scheduled time"))
                    }
                } else {
                    return nil
                }
            }
            return administerHeaderView
        }
        return nil;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        if (datePickerIndexPath != nil) {
//            NSLog("******* DatePickerIndexPath section: %d row: %d", (datePickerIndexPath?.section)!, (datePickerIndexPath?.row)!)
//            NSLog("****** indexPath section: %d row: %d", indexPath.section, indexPath.row)
//        }
//        if (datePickerIndexPath != nil && indexPath.section != (datePickerIndexPath?.section)! && indexPath.row != (datePickerIndexPath?.row)! - 1) {
//            //displayInlineDatePickerForRowAtIndexPath(datePickerIndexPath!)
//            administerTableView.beginUpdates()
//            let indexPaths = [NSIndexPath(forRow: datePickerIndexPath!.row + 1, inSection: datePickerIndexPath!.section)]
//           // if (hasPickerForIndexPath(indexPath) == true) {
//                administerTableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
//            datePickerIndexPath = nil
//          //  }
//            administerTableView.endUpdates()
//        }
        administerTableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.section == SectionCount.eZerothSection.rawValue) {
            presentAdministratedStatusPopOverAtIndexPath(indexPath)
        } else if (indexPath.section == SectionCount.eFirstSection.rawValue) {
            if (medicationSlot?.medicationAdministration.status == ADMINISTERED) {
                if (indexPath.row == RowCount.eZerothRow.rawValue || indexPath.row == RowCount.eSecondRow.rawValue) {
                    presentPrescribersAndAdministersPopOverViewAtIndexPath(indexPath)
                } else if (indexPath.row == RowCount.eFirstRow.rawValue) {
                    displayInlineDatePickerForRowAtIndexPath(indexPath)
                }
            } else if (medicationSlot?.medicationAdministration.status == REFUSED) {
                if (indexPath.row == RowCount.eZerothRow.rawValue) {
                    displayInlineDatePickerForRowAtIndexPath(indexPath)
                }
            }
        }
    }
    
    // MARK: BatchNumberCellDelegate Methods
    
    func batchNumberFieldSelected() {
        
        self.administerTableView.setContentOffset(CGPointMake(0, 130), animated: true)
    }
    
    // MARK: NotesCell Delegate Methods
    
    func notesSelected(editing : Bool) {
      
        if (editing == true) {
            self.administerTableView.setContentOffset(CGPointMake(0, 200), animated: true)
        } else {
            self.administerTableView.setContentOffset(CGPointZero, animated: true)
        }
    }
    
    func enteredNote(note : String) {
        
        if(medicationSlot?.medicationAdministration.status == ADMINISTERED) {
            medicationSlot?.medicationAdministration.administeredNotes = note
        } else if (medicationSlot?.medicationAdministration.status == REFUSED) {
            medicationSlot?.medicationAdministration.refusedNotes = note
        } else {
            medicationSlot?.medicationAdministration.omittedNotes = note
        }
    }
    
    // mark :StatusList Delegate Methods 
    func selectedMedicationStatusEntry(status: String!) {
        if status == ADMINISTERED {
            medicationSlot?.medicationAdministration.status = ADMINISTERED
        } else if status == REFUSED {
            medicationSlot?.medicationAdministration.status = REFUSED
        } else if status == OMITTED{
            medicationSlot?.medicationAdministration.status = OMITTED
        }
        administerTableView .reloadData()
    }
    
    // MARK: NamesList Delegate Methods
    
    func selectedUserEntry(user : DCUser!) {
            if (popOverIndexPath?.row == RowCount.eZerothRow.rawValue) {
                //administered by
                medicationSlot?.medicationAdministration?.administratingUser = user
                if user.displayName != SELF_ADMINISTERED {
                    medicationSlot?.medicationAdministration?.isSelfAdministered = false
                }
            } else if (popOverIndexPath?.row == RowCount.eSecondRow.rawValue) {
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
        securityPinViewController!.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        securityPinViewController!.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.presentViewController(securityPinViewController!, animated: true, completion: nil)
    }
    
    // MARK:AdministerPickerCellDelegate Methods
    
    func newDateValueSelected(newDate : NSDate) {
        
        if (datePickerIndexPath != nil) {
            if (datePickerIndexPath?.row == RowCount.eFirstRow.rawValue || datePickerIndexPath?.row == RowCount.eSecondRow.rawValue) {
                medicationSlot?.medicationAdministration.actualAdministrationTime = newDate
                administerTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:datePickerIndexPath!.row - 1, inSection: datePickerIndexPath!.section)], withRowAnimation: UITableViewRowAnimation.None)
            }
        }
    }
    
    //MARK : Security pin Match Delegate
    func securityPinMatchedForUser(user: DCUser) {
        medicationSlot?.medicationAdministration?.checkingUser = user
        administerTableView.reloadRowsAtIndexPaths([popOverIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
    }
}




