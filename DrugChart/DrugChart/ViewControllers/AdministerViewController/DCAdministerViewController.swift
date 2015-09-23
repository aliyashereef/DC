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


class DCAdministerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var administerTableView: UITableView!
    
    var medicationSlot : DCMedicationSlot?
    var medicationDetails : DCMedicationScheduleDetails?
    var statusCellSelected : Bool = false
    var userListArray : [String] = []

    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureViewElements()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    
    func configureViewElements () {
        
        administerTableView!.layoutMargins = UIEdgeInsetsZero
        administerTableView!.separatorInset = UIEdgeInsetsZero
        if(medicationSlot?.administerMedication == nil) {
            medicationSlot?.administerMedication = DCAdministerMedication.init()
            medicationSlot?.administerMedication.medicationStatus = ADMINISTERED
        }
    }

    func fetchAdministersAndPrescribersList () {
        
        //fetch administers and prescribers list
        
        let usersListWebService : DCUsersListWebService = DCUsersListWebService.init()
        usersListWebService.getUsersListWithCallback { (users, error) -> Void in
            if (error == nil) {
//                for dict : NSDictionary? in users as {} {
//                    
//                }
            }
        }
     }
    
    func configureAdministerTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        var administerCell : DCAdministerCell = (administerTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.layoutMargins = UIEdgeInsetsZero
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let dateString : String? = DCDateUtility.convertDate(medicationSlot?.time, fromFormat: DEFAULT_DATE_FORMAT, toFormat: DATE_MONTHNAME_YEAR_FORMAT)
                administerCell.titleLabel.text = dateString
            }
            break;
        case 1:
            administerCell = getPopulatedMedicationStatusTableCellAtIndexPath(administerCell, indexPath: indexPath);
            break;
        case 2:
            //if (medicationSlot?.administerMedication?.medicationStatus == ADMINISTERED) {
                administerCell = getPopulatedMedicationDetailsCellForAdministeredStatus(administerCell, indexPath: indexPath)
//            } else if (medicationSlot?.administerMedication?.medicationStatus == REFUSED) {
//                
//            }
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
            cell.detailLabel.text = DEFAULT_DOCTOR_NAME
            break
        case 1:
            cell.titleLabel.text = NSLocalizedString("DATE_TIME", comment: "date and time")
            let currentDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
            let currentDateString : String = DCDateUtility.convertDate(currentDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
            cell.detailLabel.text = currentDateString
            break
        case 2:
            //presnt inline picker here
            cell.titleLabel.text = NSLocalizedString("CHECKED_BY", comment: "Checked by title")
            cell.detailLabel.text = DEFAULT_NURSE_NAME;
            break;
        case 4:
            
            break
        default:
            break
        }
        
        return cell
    }
    
    func getBatchNumberOrExpiryDateTableCellAtIndexPath(indexPath: NSIndexPath) -> (DCBatchNumberCell) {
        
        let expiryCell : DCBatchNumberCell = (administerTableView.dequeueReusableCellWithIdentifier(BATCH_NUMBER_CELL_ID) as? DCBatchNumberCell)!
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
            cell.accessoryType = (medicationSlot?.administerMedication.medicationStatus == ADMINISTERED) ?UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            return cell
        case 2:
            cell.titleLabel.text = REFUSED
            cell.accessoryType = (medicationSlot?.administerMedication.medicationStatus == REFUSED) ?UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            return cell
        case 3:
            cell.titleLabel.text = OMITTED
            cell.accessoryType = (medicationSlot?.administerMedication.medicationStatus == OMITTED) ?UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            return cell
        default:
            return cell
        }
    }
    
    func configureMedicationDetailsCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerMedicationDetailsCell) {
        
        let medicationCell : DCAdministerMedicationDetailsCell = (administerTableView.dequeueReusableCellWithIdentifier(ADMINISTER_MEDICATION_DETAILS_CELL_ID) as? DCAdministerMedicationDetailsCell!)!
        if medicationDetails != nil {
            medicationCell.populateCellWithMedicationDetails(medicationDetails!)
        }
        return medicationCell
    }
    
    func presentPrescribersAndAdministersPopOverViewAtIndexPath (indexPath : NSIndexPath) {
        
        let namesViewController : NameSelectionTableViewController? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(NAMES_LIST_VIEW_STORYBOARD_ID) as? NameSelectionTableViewController
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
    
    // MARK: TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (medicationSlot == nil) {
            return 0
        } else {
            if (medicationSlot?.status == ADMINISTERED || medicationSlot?.status == REFUSED || medicationSlot?.status == nil){
                return ADMINISTERED_SECTION_COUNT;
            } else if (medicationSlot?.status == OMITTED) {
                return OMITTED_SECTION_COUNT;
            }
            return ADMINISTERED_SECTION_COUNT;
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return INITIAL_SECTION_ROW_COUNT
        case 1:
            return (statusCellSelected ? 4 : STATUS_ROW_COUNT)
        case 2:
            if (medicationSlot?.status == OMITTED || medicationSlot?.status == REFUSED) {
                return OMITTED_OR_REFUSED_SECTION_ROW_COUNT;
            } else {
                return ADMINISTERED_SECTION_ROW_COUNT;
            }
        case 3:
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
            if (indexPath.section == 2 && indexPath.row == 3) {
                let batchNumberCell : DCBatchNumberCell = getBatchNumberOrExpiryDateTableCellAtIndexPath(indexPath)
                return batchNumberCell
            } else if (indexPath.section == 3) {
                let notesCell : DCNotesTableCell = (administerTableView.dequeueReusableCellWithIdentifier(NOTES_CELL_ID) as? DCNotesTableCell)!
                return notesCell
            } else {
                let administerCell : DCAdministerCell = configureAdministerTableCellAtIndexPath(indexPath)
                return administerCell
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
        } else if (indexPath.section == 3) {
            return 125.0
        } else {
            return 41.0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 {
            let administerHeaderView = NSBundle.mainBundle().loadNibNamed(ADMINISTER_HEADER_VIEW_NIB, owner: self, options: nil)[0] as? DCAdministerTableHeaderView
            administerHeaderView?.populateScheduledTimeValue((medicationSlot?.time)!)
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
                    tableView.deleteRowsAtIndexPaths(indexPathsArray, withRowAnimation: .Fade)
                }
                break
            case 1:
                medicationSlot?.administerMedication.medicationStatus = ADMINISTERED
                statusCellSelected = false
                tableView.deleteRowsAtIndexPaths(indexPathsArray, withRowAnimation: .Fade)
                break
            case 2:
                medicationSlot?.administerMedication.medicationStatus = REFUSED
                statusCellSelected = false
                tableView.deleteRowsAtIndexPaths(indexPathsArray, withRowAnimation: .Fade)
                break
            case 3:
                medicationSlot?.administerMedication.medicationStatus = OMITTED
                statusCellSelected = false
                tableView.deleteRowsAtIndexPaths(indexPathsArray, withRowAnimation: .Fade)
                break
            default:
                break
            }
            administerTableView .reloadData()
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0 || indexPath.row == 2) {
                presentPrescribersAndAdministersPopOverViewAtIndexPath(indexPath)
            }
        }
    }
    
    // MARK: BatchNumberCellDelegate Methods
    
    func batchNumberFieldSelected() {
        
        //    [medicationDetailsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]
        //        atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self scrollToInstructionsCellPosition];
//            });
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.administerTableView.scrollToRowAtIndexPath(NSIndexPath(forItem: 3, inSection: 2), atScrollPosition: .Bottom, animated: true)
        }
    }
}


