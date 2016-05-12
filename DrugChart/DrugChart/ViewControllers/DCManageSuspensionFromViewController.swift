//
//  DCManageSuspensionFromViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 10/05/16.
//
//

import UIKit

typealias ManageSuspensionUpdated = DCManageSuspensionDetails? -> Void

class DCManageSuspensionFromViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var isDatePickerActive : Bool = false
    var isSuspendedFromOptionSelected : Bool = false
    var manageSuspensionDetails : DCManageSuspensionDetails?
    var selectedIndexPath : NSIndexPath?
    var manageSuspensionUpdated: ManageSuspensionUpdated = { value in }

    @IBOutlet weak var manageSuspensionFromTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = DOSE_FROM_TITLE
        self.configureInitialView()
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
        
        if manageSuspensionDetails?.manageSuspensionFromType == SUSPEND_IMMEDIATELY {
            selectedIndexPath = NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eZerothSection.rawValue)
        } else if manageSuspensionDetails?.manageSuspensionFromType == SUSPEND_FROM{
            isSuspendedFromOptionSelected = true
            selectedIndexPath = NSIndexPath(forRow: RowCount.eFirstRow.rawValue, inSection: SectionCount.eZerothSection.rawValue)
            if manageSuspensionDetails?.fromDate != nil {
                isDatePickerActive = true
            }
        }
        manageSuspensionFromTableView.reloadData()
    }
    
    // MARK: - TableView Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if isSuspendedFromOptionSelected {
            return SectionCount.eSecondSection.rawValue
        } else {
            return SectionCount.eFirstSection.rawValue
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case SectionCount.eZerothSection.rawValue:
            return RowCount.eSecondRow.rawValue
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
        
        let cell : DCManageSuspensionFromTableViewCell = manageSuspensionFromTableView.dequeueReusableCellWithIdentifier(MANAGE_SUSPENSION_CELL) as! DCManageSuspensionFromTableViewCell
        if selectedIndexPath == indexPath {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            if indexPath.row == RowCount.eZerothRow.rawValue {
                cell.titleLabel.text = SUSPEND_IMMEDIATELY
                cell.detailLabel.text = EMPTY_STRING
            } else {
                cell.titleLabel.text = SUSPEND_FROM
                cell.detailLabel.text = EMPTY_STRING
            }
        case SectionCount.eFirstSection.rawValue:
            if indexPath.row == RowCount.eZerothRow.rawValue {
                cell.titleLabel.text = DATE
                cell.detailLabel.text = manageSuspensionDetails?.fromDate
            } else {
                // date pickercell
                let datePickerCell : DCDatePickerCell? = manageSuspensionFromTableView.dequeueReusableCellWithIdentifier(DATE_PICKER_CELL_IDENTIFIER) as?DCDatePickerCell
                datePickerCell?.datePicker?.minimumDate = NSDate()
                if let fromDate = manageSuspensionDetails?.fromDate {
                    datePickerCell?.datePicker?.date = DCDateUtility.dateFromSourceString(fromDate)
                } else {
                    self.performSelector(#selector(DCReviewViewController.reloadReviewDateTableCellForDateValue(_:)), withObject: NSDate(), afterDelay: 0.02)
                }
                datePickerCell?.selectedDate = { date in
                    self.reloadReviewDateTableCellForDateValue(date)
                }
                return datePickerCell!
            }
        default:
            break
        }
        return cell
    }
    
    func reloadReviewDateTableCellForDateValue(date : NSDate) {
        
        let dateString = DCDateUtility.dateStringFromDate(date, inFormat: START_DATE_FORMAT)
        manageSuspensionDetails?.fromDate = dateString
        manageSuspensionFromTableView.beginUpdates()
        manageSuspensionFromTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: eFirstSection.rawValue) ], withRowAnimation: .Fade)
        manageSuspensionFromTableView.endUpdates()
    }
    
    func actionForCellSelectedAtIndexPath(indexPath : NSIndexPath) {
        
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            if indexPath.row == RowCount.eZerothRow.rawValue {
                selectedIndexPath = indexPath
                manageSuspensionFromTableView.reloadData()
                manageSuspensionDetails?.manageSuspensionFromType = SUSPEND_IMMEDIATELY
                if isSuspendedFromOptionSelected {
                    manageSuspensionFromTableView.beginUpdates()
                    if isDatePickerActive {
                        isDatePickerActive = !isDatePickerActive
                        manageSuspensionFromTableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 1)], withRowAnimation: .Fade)
                    }
                    isSuspendedFromOptionSelected = !isSuspendedFromOptionSelected
                    manageSuspensionFromTableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                    manageSuspensionFromTableView.endUpdates()
                }
            } else {
                selectedIndexPath = indexPath
                manageSuspensionFromTableView.reloadData()
                manageSuspensionDetails?.manageSuspensionFromType = SUSPEND_FROM
                if !isSuspendedFromOptionSelected {
                    isSuspendedFromOptionSelected = !isSuspendedFromOptionSelected
                    manageSuspensionFromTableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                }
            }
        case SectionCount.eFirstSection.rawValue:
            if indexPath.row == RowCount.eZerothRow.rawValue {
                if !isDatePickerActive {
                    isDatePickerActive = !isDatePickerActive
                    manageSuspensionFromTableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 1, inSection: indexPath.section)], withRowAnimation: .Fade)
                }
            }
        default:
            break
        }
    }
}
