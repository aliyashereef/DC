//
//  DCManageSuspensionUntilViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 10/05/16.
//
//

import UIKit

class DCManageSuspensionUntilViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SingleDoseEntryCellDelegate {
    
    var isDatePickerActive : Bool = false
    var isSpecifiedDateSelected : Bool = false
    var isSpecifiedDoseSelected : Bool = false
    var isDoseTextFieldActive : Bool = false
    var manageSuspensionDetails : DCManageSuspensionDetails?
    var selectedIndexPath : NSIndexPath?
    var manageSuspensionUpdated: ManageSuspensionUpdated = { value in }
    var saveButtonClicked : Bool = false
    var alertMessageForMismatch :NSString = "Enter Dose"

    @IBOutlet weak var manageSuspensionUntilTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = UNTIL_TITLE
        self.configureInitialView()
        manageSuspensionUntilTableView.keyboardDismissMode = .OnDrag
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(true)
        self.manageSuspensionUpdated(manageSuspensionDetails)
    }

    func configureInitialView() {
        
        if manageSuspensionDetails?.manageSuspensionUntilType == MANUALLY_SUSPENDED {
            selectedIndexPath = NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eZerothSection.rawValue)
        } else if manageSuspensionDetails?.manageSuspensionUntilType == SPECIFIED_DATE{
            isSpecifiedDateSelected = true
            selectedIndexPath = NSIndexPath(forRow: RowCount.eFirstRow.rawValue, inSection: SectionCount.eZerothSection.rawValue)
        } else if manageSuspensionDetails?.manageSuspensionUntilType == SPECIFIED_DOSE {
            isSpecifiedDoseSelected = true
            selectedIndexPath = NSIndexPath(forRow: RowCount.eSecondRow.rawValue, inSection: SectionCount.eZerothSection.rawValue)
        }
        manageSuspensionUntilTableView.reloadData()
    }

    // MARK: - TableView Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if isSpecifiedDateSelected || isSpecifiedDoseSelected{
            return SectionCount.eSecondSection.rawValue
        } else {
            return SectionCount.eFirstSection.rawValue
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case SectionCount.eZerothSection.rawValue:
            return RowCount.eThirdRow.rawValue
        case SectionCount.eFirstSection.rawValue:
            if isDatePickerActive {
                return RowCount.eSecondRow.rawValue
            } else {
                return RowCount.eFirstRow.rawValue
            }
        default:
            return RowCount.eZerothRow.rawValue
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //Set the alert entering the dose.
        if (section == eFirstSection.rawValue && saveButtonClicked && isSpecifiedDoseSelected && manageSuspensionDetails?.specifiedDose == nil) {
            return alertMessageForMismatch as String
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        //Change text color to red and change text from full upper case to desired sentence.
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.text = alertMessageForMismatch as String
            view.textLabel!.textColor = UIColor.redColor()
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch(indexPath.section) {
        case SectionCount.eZerothSection.rawValue:
            return CGFloat(NORMAL_CELL_HEIGHT)
        case SectionCount.eFirstSection.rawValue:
            if indexPath.row == RowCount.eZerothRow.rawValue {
                return CGFloat(NORMAL_CELL_HEIGHT)
            } else {
                return CGFloat(216)
            }
        default:
            return CGFloat(NORMAL_CELL_HEIGHT)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let displayCell = self.confugureCellForDisplay(indexPath)
        return displayCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.actionForCellSelectedAtIndexPath(indexPath)
    }
    
    func confugureCellForDisplay(indexPath : NSIndexPath) -> UITableViewCell {
        
        let cell : DCManageSuspensionUntilTableViewCell = manageSuspensionUntilTableView.dequeueReusableCellWithIdentifier(MANAGE_SUSPENSION_CELL) as! DCManageSuspensionUntilTableViewCell
        if selectedIndexPath == indexPath {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            if indexPath.row == RowCount.eZerothRow.rawValue {
                cell.titleLabel.text = MANUALLY_SUSPENDED
                cell.detailLabel.text = EMPTY_STRING
            } else if indexPath.row == RowCount.eFirstRow.rawValue{
                cell.titleLabel.text = SPECIFIED_DATE
                cell.detailLabel.text = EMPTY_STRING
            } else {
                cell.titleLabel.text = SPECIFIED_DOSE
                cell.detailLabel.text = EMPTY_STRING
            }
        case SectionCount.eFirstSection.rawValue:
            if isSpecifiedDateSelected {
                if indexPath.row == RowCount.eZerothRow.rawValue {
                    cell.titleLabel.text = DATE
                    if saveButtonClicked {
                        if manageSuspensionDetails?.specifiedUntilDate == nil {
                            cell.titleLabel.textColor = UIColor.redColor()
                        } else {
                            cell.titleLabel.textColor = UIColor.blackColor()
                        }
                    }
                    cell.detailLabel.text = manageSuspensionDetails?.specifiedUntilDate
                } else {
                    // date pickercell
                    let datePickerCell : DCDatePickerCell? = manageSuspensionUntilTableView.dequeueReusableCellWithIdentifier(DATE_PICKER_CELL_IDENTIFIER) as?DCDatePickerCell
                    datePickerCell?.datePicker?.minimumDate = NSDate()
                    if let untilDate = manageSuspensionDetails?.specifiedUntilDate {
                        datePickerCell?.datePicker?.date = DCDateUtility.dateFromSourceString(untilDate)
                    } else {
                        self.performSelector(#selector(DCReviewViewController.reloadReviewDateTableCellForDateValue(_:)), withObject: NSDate(), afterDelay: 0.02)
                    }
                    datePickerCell?.selectedDate = { date in
                        self.reloadReviewDateTableCellForDateValue(date)
                    }
                    return datePickerCell!
                }
            } else if isSpecifiedDoseSelected {
                return self.singleDoseEntryCellAtIndexPath(indexPath)
            }
        default:
            break
        }
        return cell
    }
    
    func singleDoseEntryCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        let singleDoseEntryCell = manageSuspensionUntilTableView.dequeueReusableCellWithIdentifier(SINGLE_DOSE_ENTRY_CELL_ID) as? DCSingleDoseEntryTableCell
        singleDoseEntryCell?.singleDoseDelegate = self
        singleDoseEntryCell?.singleDoseTextfield.delegate = singleDoseEntryCell
        //        singleDoseEntryCell?.singleDoseTextfield.becomeFirstResponder()
        if indexPath.row == RowCount.eZerothRow.rawValue {
            let singleDoseValue = NSMutableString()
            if let dose = manageSuspensionDetails?.specifiedDose {
                if dose != EMPTY_STRING {
                    singleDoseValue.appendString(dose)
                }
            }
            singleDoseEntryCell?.singleDoseTextfield.text = singleDoseValue as String
        }
        return singleDoseEntryCell!
    }
    
    func reloadReviewDateTableCellForDateValue(date : NSDate) {
        
        let dateString = DCDateUtility.dateStringFromDate(date, inFormat: START_DATE_FORMAT)
        manageSuspensionDetails?.specifiedUntilDate = dateString
        manageSuspensionUntilTableView.beginUpdates()
        manageSuspensionUntilTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: eFirstSection.rawValue) ], withRowAnimation: .Fade)
        manageSuspensionUntilTableView.endUpdates()
    }
    
    func actionForCellSelectedAtIndexPath(indexPath : NSIndexPath) {
        
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            selectedIndexPath = indexPath
            manageSuspensionUntilTableView.reloadData()
            if indexPath.row == RowCount.eZerothRow.rawValue {
                manageSuspensionDetails?.manageSuspensionUntilType = MANUALLY_SUSPENDED
                manageSuspensionUntilTableView.beginUpdates()
                if isSpecifiedDoseSelected {
                    isSpecifiedDoseSelected = !isSpecifiedDoseSelected
                    manageSuspensionUntilTableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                }
                if isSpecifiedDateSelected {
                    if isDatePickerActive {
                        isDatePickerActive = !isDatePickerActive
                        manageSuspensionUntilTableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 1)], withRowAnimation: .Fade)
                    }
                    isSpecifiedDateSelected = !isSpecifiedDateSelected
                    manageSuspensionUntilTableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                }
                manageSuspensionUntilTableView.endUpdates()
                self.navigationController?.popViewControllerAnimated(true)
            } else if indexPath.row == RowCount.eFirstRow.rawValue{
                manageSuspensionDetails?.manageSuspensionUntilType = SPECIFIED_DATE
                manageSuspensionUntilTableView.beginUpdates()
                if isSpecifiedDoseSelected {
                    isSpecifiedDoseSelected = !isSpecifiedDoseSelected
                    manageSuspensionUntilTableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                }
                if !isSpecifiedDateSelected {
                    isSpecifiedDateSelected = !isSpecifiedDateSelected
                    manageSuspensionUntilTableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                }
                manageSuspensionUntilTableView.endUpdates()
            } else {
                manageSuspensionDetails?.manageSuspensionUntilType = SPECIFIED_DOSE
                if isSpecifiedDateSelected {
                    manageSuspensionUntilTableView.beginUpdates()
                    if isDatePickerActive {
                        isDatePickerActive = !isDatePickerActive
                        manageSuspensionUntilTableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 1)], withRowAnimation: .Fade)
                    }
                    isSpecifiedDateSelected = !isSpecifiedDateSelected
                    manageSuspensionUntilTableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                    manageSuspensionUntilTableView.endUpdates()
                }
                if !isSpecifiedDoseSelected {
                    isSpecifiedDoseSelected = !isSpecifiedDoseSelected
                    manageSuspensionUntilTableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                }
            }
        case SectionCount.eFirstSection.rawValue:
            if indexPath.row == RowCount.eZerothRow.rawValue {
                if !isDatePickerActive {
                    isDatePickerActive = !isDatePickerActive
                    manageSuspensionUntilTableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 1, inSection: indexPath.section)], withRowAnimation: .Fade)
                }
            }
        default:
            break
        }
    }
    
    //MARK: Single Dose Delegate Methods
    
    func singleDoseValueChanged(dose : String?) {
        
        manageSuspensionDetails?.specifiedDose = dose
    }
}
