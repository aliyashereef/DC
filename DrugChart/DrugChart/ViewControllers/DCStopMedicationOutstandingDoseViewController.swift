//
//  DCStopMedicationOutstandingDoseViewController.swift
//  DrugChart
//
//  Created by aliya on 25/04/16.
//
//

import Foundation

class DCStopMedicationOutstandingDoseViewController : UIViewController {
    var inactiveDetails : DCInactiveDetails?
    var isSpecificOutstandingDose : Bool = false
    var isSavePressed : Bool = false
    var startDate : NSString = EMPTY_STRING
    
    @IBOutlet weak var outstandingDosesTableView: UITableView!

    let outstandingDoseArray = [StopMedicationConstants.MARK_NO_LONGER_REQUIRED,StopMedicationConstants.MARK_ALL_STILL_REQUIRED,StopMedicationConstants.SELECT_SPECIFIC_DOSES]
    
    let outstandingSpecificDoseArray = [StopMedicationConstants.NO_LONGER_REQUIRED,StopMedicationConstants.STILL_REQUIRED]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = StopMedicationConstants.OUTSTANDING_DOSES
        self.outstandingDosesTableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.inactiveDetails?.outstandingDose == StopMedicationConstants.SELECT_SPECIFIC_DOSES {
            isSpecificOutstandingDose = true
            self.insertSection()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isSpecificOutstandingDose {
            return 2
        }
        return 1

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case eZerothSection.rawValue:
            return outstandingDoseArray.count
        default:
            return outstandingSpecificDoseArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(StopMedicationConstants.OUTSTANDING_DOSAGE_CELL_ID)! as UITableViewCell
        cell.textLabel!.font = UIFont.systemFontOfSize(15.0)
        var doseString = EMPTY_STRING
        var outstandingDoseString = EMPTY_STRING
        switch indexPath.section {
        case eZerothSection.rawValue:
            doseString = outstandingDoseArray[indexPath.row] as String
            if inactiveDetails?.outstandingDose == doseString {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            cell.textLabel?.text = doseString
        case eFirstSection.rawValue:
            outstandingDoseString = outstandingSpecificDoseArray[indexPath.row] as String
            if inactiveDetails?.outstandingSpecificDose == outstandingDoseString {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            cell.textLabel?.text = outstandingDoseString
        default:
            break
        }
        return cell
    }
        
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
       
        switch (section){
        case eFirstSection.rawValue:
            if !self.isValidOutstandingDoses() && isSavePressed {
                let administerHeaderView = NSBundle.mainBundle().loadNibNamed(ADMINISTER_HEADER_VIEW_NIB, owner: self, options: nil)[0] as? DCAdministerTableHeaderView
                administerHeaderView!.timeLabel.hidden = true
                let errorMessage = StopMedicationConstants.OPTION_SELECTION_ERROR_MESSAGE
                administerHeaderView?.populateHeaderViewWithErrorMessage(errorMessage as String)
                return administerHeaderView
            } else if (isSpecificOutstandingDose) {
                let startDateValue = DCDateUtility.dateFromSourceString(startDate as String)
                let dateString = DCDateUtility.dateStringFromDate(startDateValue, inFormat: ADMINISTER_DATE_TIME_FORMAT)
                let headerView = NSBundle.mainBundle().loadNibNamed(WARNINGS_HEADER_VIEW_NIB, owner: self, options: nil)[0] as? DCWarningsHeaderView
                headerView!.titleLabel.text = dateString
                return headerView
            }
            return nil
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var doseString = EMPTY_STRING
        var outstandingDoseString = EMPTY_STRING
        switch indexPath.section {
        case eZerothSection.rawValue:
            isSavePressed = false
            doseString = outstandingDoseArray[indexPath.row] as String
            self.inactiveDetails?.outstandingSpecificDose = EMPTY_STRING
            self.inactiveDetails?.outstandingDose = doseString
            if indexPath.row != RowCount.eSecondRow.rawValue{
                isSpecificOutstandingDose = false
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                if !isSpecificOutstandingDose {
                    isSpecificOutstandingDose = true
                    self.insertSection()
                }
            }
            break
            case eFirstSection.rawValue:
                outstandingDoseString = outstandingSpecificDoseArray[indexPath.row] as String
                self.inactiveDetails?.outstandingSpecificDose = outstandingDoseString
            break
        default:
            break
        }
        tableView.reloadData()
    }

    func insertSection() {
    
    self.outstandingDosesTableView.beginUpdates()
    if isSpecificOutstandingDose {
        self.outstandingDosesTableView.insertSections(NSIndexSet(index: 1), withRowAnimation:.Fade)
    } else {
        self.outstandingDosesTableView.deleteSections(NSIndexSet(index: 1), withRowAnimation:.Fade)
    }
    self.outstandingDosesTableView.endUpdates()
    }
    
    func  isValidOutstandingDoses () -> Bool{
        
        var isValid = true
        if inactiveDetails?.outstandingDose == StopMedicationConstants.SELECT_SPECIFIC_DOSES && (inactiveDetails?.outstandingSpecificDose == EMPTY_STRING || inactiveDetails?.outstandingSpecificDose == nil) {
            isValid = false
        } else if inactiveDetails?.outstandingDose == EMPTY_STRING || inactiveDetails?.outstandingDose == nil {
            isValid = false
        }
        return isValid
    }
}