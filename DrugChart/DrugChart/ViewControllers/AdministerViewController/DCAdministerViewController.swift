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
let SECURITY_PIN_VIEW_ALPHA : CGFloat = 0.3
let DISPLAY_SECURITY_PIN_ENTRY : String = "displaySecurityPinEntryViewForUser:"

enum SectionCount : NSInteger {
    
    // enum for Section Count
    case eZerothSection = 0
    case eFirstSection
    case eSecondSection
    case eThirdSection
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

    @IBOutlet weak var administerTableView: UITableView!
    @IBOutlet weak var alertMessageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var medicineRouteAndInstructionsLabel: UILabel!
    @IBOutlet var medicineNameLabel: UILabel!
    @IBOutlet var medicineDateLabel: UILabel!
    @IBOutlet weak var administerTableViewTopConstraint: NSLayoutConstraint!
    
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
    var editingIndexPath : NSIndexPath?
    var keyboardHeight : CGFloat?
    var selfAdministratedUser : DCUser? = nil
    var doneClicked : Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureViewElements()
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
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private Methods
    
    func configureViewElements () {
        
        initialiseMedicationSlotObject()
        administerTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        //check if early administration
        if (medicationDetails?.medicineCategory == WHEN_REQUIRED) {
            checkIfFrequentAdministrationForWhenRequiredMedication()
        } else {
            if (medicationSlot?.time != nil) {
                checkIfAdministrationIsEarly()
            }
        }
        administerTableView!.tableFooterView = UIView(frame: CGRectZero)
        if (alertMessage != EMPTY_STRING) {
            alertMessageLabel.hidden = false
            alertMessageLabel.text = alertMessage as String
        } else {
            alertMessageLabel.hidden = true
        }
        configureMedicationDetails()
    }
    
    func addNotifications() {
        
        //keyboard show/hide observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"), name: UIKeyboardWillShowNotification, object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func configureMedicationDetails () {
        
        medicineNameLabel.text = medicationDetails!.name
        if (medicationDetails?.route != nil) {
            populateRouteAndInstructionLabels()
        }
        let dateString : String
        if let date = medicationSlot?.time {
            dateString = DCDateUtility.dateStringFromDate(date, inFormat: DATE_MONTHNAME_YEAR_FORMAT)
        } else {
            dateString = DCDateUtility.dateStringFromDate(weekDate, inFormat: DATE_MONTHNAME_YEAR_FORMAT)
        }
        medicineDateLabel.text = dateString
    }
    
    func populateRouteAndInstructionLabels() {
        
        //fill in route and instructions in required font
        let route : String = medicationDetails!.route.stringByReplacingOccurrencesOfString(" ", withString: EMPTY_STRING)
        let attributedRouteString : NSMutableAttributedString = NSMutableAttributedString(string:route, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(16.0)])
        let attributedInstructionsString : NSMutableAttributedString
        let instructionString : String
        if (medicationDetails?.instruction != EMPTY_STRING && medicationDetails?.instruction != nil) {
            instructionString = String(format: " (%@)", (medicationDetails?.instruction)!)
        } else {
            instructionString = ""
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
        if (medicationSlotsArray.count > 0) {
            let previousMedicationSlot : DCMedicationSlot? = medicationSlotsArray.last
            let currentSystemDate : NSDate = DCDateUtility.dateInCurrentTimeZone(NSDate())
            let nextMedicationTimeInterval : NSTimeInterval? = currentSystemDate.timeIntervalSinceDate((previousMedicationSlot?.time)!)
            if (nextMedicationTimeInterval <= 2*60*60) {
                medicationSlot?.medicationAdministration.isEarlyAdministration = true
                medicationSlot?.medicationAdministration.isWhenRequiredEarlyAdministration = true
            } else {
                medicationSlot?.medicationAdministration.isEarlyAdministration = false
                medicationSlot?.medicationAdministration.isWhenRequiredEarlyAdministration = false
            }
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
        case SectionCount.eZerothSection.rawValue:
            administerCell = populatedMedicationStatusTableCellAtIndexPath(administerCell, indexPath: indexPath);
            break;
        case SectionCount.eFirstSection.rawValue:
            if (medicationSlot?.medicationAdministration?.status == ADMINISTERED) {
                administerCell = populatedMedicationDetailsCellForAdministeredStatus(administerCell, indexPath: indexPath)
            }
            else if (medicationSlot?.medicationAdministration?.status == REFUSED) {
                administerCell = medicationDetailsCellForRefusedStatus(administerCell, indexPath: indexPath)
            }
            break
        default:
            break;
        }
        return administerCell
    }
    
    func populatedMedicationDetailsCellForAdministeredStatus(cell : DCAdministerCell, indexPath: NSIndexPath) -> (DCAdministerCell) {
        
        switch indexPath.row {
        case RowCount.eZerothRow.rawValue:
            //administered by cell
            cell.titleLabel.text = NSLocalizedString("ADMINISTERED_BY", comment: "administered by title")
            cell.detailLabel.text = (medicationSlot?.medicationAdministration?.administratingUser?.displayName != nil) ? (medicationSlot?.medicationAdministration?.administratingUser?.displayName) : DEFAULT_DOCTOR_NAME
            break
        case RowCount.eFirstRow.rawValue:
            cell.titleLabel.text = NSLocalizedString("DATE_TIME", comment: "date and time")
            let dateString : String
            if let date = medicationSlot?.medicationAdministration.actualAdministrationTime {

                dateString = DCDateUtility.dateStringFromDate(DCDateUtility.dateInCurrentTimeZone(date), inFormat: ADMINISTER_DATE_TIME_FORMAT)
            } else {
                dateString = DCDateUtility.dateStringFromDate(DCDateUtility.dateInCurrentTimeZone(NSDate()), inFormat: ADMINISTER_DATE_TIME_FORMAT)
            }
            cell.detailLabel.text = dateString
            break
        case RowCount.eSecondRow.rawValue:
            //present inline picker here
            cell.titleLabel.text = NSLocalizedString("CHECKED_BY", comment: "Checked by title")
            cell.detailLabel.text = (medicationSlot?.medicationAdministration?.checkingUser?.displayName != nil) ? (medicationSlot?.medicationAdministration?.checkingUser?.displayName) : EMPTY_STRING
            break;
        case RowCount.eFourthRow.rawValue:
            break
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
                if(doneClicked == true) {
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
        if (indexPath.row == RowCount.eZerothRow.rawValue) {
            namesViewController?.title = ADMINISTRATED_BY
            namesViewController?.namesArray = userListArray
            namesViewController!.previousSelectedValue = medicationSlot?.medicationAdministration?.administratingUser?.displayName
        } else if (indexPath.row == RowCount.eSecondRow.rawValue) {
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
        statusViewController?.namesArray = [ADMINISTERED, REFUSED , OMITTED]
        statusViewController?.previousSelectedValue = medicationSlot?.medicationAdministration?.status
        statusViewController?.medicationStatusDelegate = self
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
    
    func populatedAdministeredTableViewCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == SectionCount.eFirstSection.rawValue && indexPath.row == RowCount.eThirdRow.rawValue) {
            let batchNumberCell : DCBatchNumberCell = batchNumberOrExpiryDateTableCellAtIndexPath(indexPath)
            return batchNumberCell
        } else if (indexPath.section == SectionCount.eSecondSection.rawValue) {
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
            if (indexPath.section == SectionCount.eFirstSection.rawValue && datePickerIndexPath != nil && indexPath.row == 2) {
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
        if (indexPath.section == SectionCount.eFirstSection.rawValue) {
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
            if (indexPath.section == SectionCount.eFirstSection.rawValue && datePickerIndexPath != nil && indexPath.row == 1) {
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
            } else if (medicationSlot?.medicationAdministration?.status == ADMINISTERED || medicationSlot?.medicationAdministration?.status == REFUSED) {
                return ADMINISTERED_SECTION_COUNT;
            } else {
                return 1;
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
            let administeredTableCell = populatedAdministeredTableViewCellAtIndexPath(indexPath)
            return administeredTableCell
        } else if (medicationSlot?.medicationAdministration.status == OMITTED) {
            let omittedTableCell = populatedOmittedTableViewCellAtIndexPath(indexPath)
            return omittedTableCell
        } else if (medicationSlot?.medicationAdministration.status == REFUSED){
            //refused status
            let refusedTableCell = populatedRefusedTableCellAtIndexPath(indexPath)
            return refusedTableCell
        } else {
            let administerCell : DCAdministerCell = (administerTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
            administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            administerCell.titleLabel.text = NSLocalizedString("STATUS", comment: "status title text")
            administerCell.detailLabel.text = EMPTY_STRING
            if(doneClicked == true && medicationSlot?.medicationAdministration.status == nil) {
                administerCell.titleLabel.textColor = UIColor.redColor()
            } else {
                administerCell.titleLabel.textColor = UIColor(forHexString: "#676767")
            }
            return administerCell
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
                } else {
                    if (medicationDetails?.medicineCategory == WHEN_REQUIRED) {
                       let currentDate = DCDateUtility.dateInCurrentTimeZone(NSDate())
                        administerHeaderView?.populateScheduledTimeValue(currentDate)
                    }
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
        
        administerTableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.section == SectionCount.eZerothSection.rawValue) {
            presentAdministratedStatusPopOverAtIndexPath(indexPath)
        } else if (indexPath.section == SectionCount.eFirstSection.rawValue) {
            if (medicationSlot?.medicationAdministration.status == ADMINISTERED) {
                if (indexPath.row == RowCount.eZerothRow.rawValue || indexPath.row == RowCount.eSecondRow.rawValue) {
                    displayPrescribersAndAdministersViewAtIndexPath(indexPath)
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
    
     func batchNumberFieldSelectedAtIndexPath(indexPath: NSIndexPath) {
        
        self.administerTableView.setContentOffset(CGPointMake(0, 110), animated: true)
        editingIndexPath = indexPath
    }
    
    func enteredBatchDetails(batch : String) {
        
        medicationSlot?.medicationAdministration?.batch = batch
    }
    
    // MARK: NotesCell Delegate Methods
    
    func notesSelected(editing : Bool, withIndexPath indexPath : NSIndexPath) {
        
        editingIndexPath = indexPath
        if(medicationSlot?.medicationAdministration?.status == ADMINISTERED) {
            self.administerTableView.setContentOffset(CGPointMake(0, 180), animated: true)
        } else {
            self.administerTableView.setContentOffset(CGPointMake(0, 80), animated: true)
        }
        if (editing == true && keyboardHeight != nil) {
            //animateAdministerTableViewUpWhenKeyboardShows()
        }
    }
    
    func enteredNote(note : String) {
        
        if(medicationSlot?.medicationAdministration?.status == ADMINISTERED) {
            medicationSlot?.medicationAdministration?.administeredNotes = note
        } else if (medicationSlot?.medicationAdministration?.status == REFUSED) {
            medicationSlot?.medicationAdministration?.refusedNotes = note
        } else {
            medicationSlot?.medicationAdministration?.omittedNotes = note
        }
    }
    
    // mark :StatusList Delegate Methods 
    func selectedMedicationStatusEntry(status: String!) {
        doneClicked = false
        isValid = true
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
        securityPinViewController!.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(SECURITY_PIN_VIEW_ALPHA)
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
                self.administerTableViewTopConstraint.constant = topConstraint
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
    
    func keyboardDidHide(notification : NSNotification) {
        
        editingIndexPath = nil
        administerTableViewTopConstraint.constant = 0.0
    }
    
}




