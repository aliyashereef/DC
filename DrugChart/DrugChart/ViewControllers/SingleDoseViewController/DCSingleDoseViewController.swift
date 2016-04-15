//
//  DCSingleDoseViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 2/17/16.
//
//

import UIKit

typealias UpdatedSingleDose = DCSingleDose? -> Void

class DCSingleDoseViewController: DCBaseViewController, UITableViewDelegate, UITableViewDataSource, SingleDoseEntryCellDelegate {
    
    @IBOutlet weak var doseTableView: UITableView!
    
    var inlinePickerIndexPath : NSIndexPath?
    var singleDose : DCSingleDose?
    var doseUnit : NSString?
    var updatedSingleDose : UpdatedSingleDose = { dose in }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = SINGLE_DOSE;
        doseTableView.keyboardDismissMode = .OnDrag
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.updatedSingleDose(self.singleDose)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableView Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rowCount = 2
        if (tableViewHasInlinePickerForSection(section)) {
            rowCount++
        }
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let singleDoseEntryCell = singleDoseEntryCellAtIndexPath(indexPath)
            return singleDoseEntryCell
        } else if (indexPath.row == 2) {
            let pickerCell = datePickerCellAtindexPath(indexPath)
            return pickerCell
        } else {
            let singleDoseCell = tableView.dequeueReusableCellWithIdentifier(SINGLE_DOSE_CELL_ID) as? DCSingleDoseTableCell
                singleDoseCell?.titleLabel.text = NSLocalizedString("DATE", comment: "")
                singleDoseCell?.valueLabel.text = singleDose?.dateAndTime
                singleDoseCell!.accessoryType = .None
                singleDoseCell?.accessoryView = UIView(frame: CGRectMake(0, 0, 0, 24))
                return singleDoseCell!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return (indexPath.row == 2) ? PICKER_CELL_HEIGHT : 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.row == RowCount.eFirstRow.rawValue) {
            //display inline picker
            tableView.endEditing(true)
            displayInlinePickerForRowAtIndexPath(indexPath)
            if (singleDose?.dateAndTime == nil) {
                let dateString = DCDateUtility.dateStringFromDate(NSDate(), inFormat: START_DATE_FORMAT)
                singleDose?.dateAndTime = dateString
                tableView.beginUpdates()
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 0)], withRowAnimation:.Fade)
                tableView.endUpdates()
                self.performSelector(Selector("reloadDatePickerAfterDelay"), withObject: nil, afterDelay: 0.1)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Private Methods
    
    func tableViewHasInlinePickerForSection (section : NSInteger) -> Bool {
        
        return (self.inlinePickerIndexPath != nil && section == self.inlinePickerIndexPath?.section)
    }
    
    func reloadDatePickerAfterDelay() {
        
        doseTableView.beginUpdates()
        doseTableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 2, inSection: 0)], withRowAnimation:UITableViewRowAnimation.None)
        doseTableView.endUpdates()
    }
    
    func indexPathHasPicker(indexPath : NSIndexPath) -> Bool {
        
        return (tableViewHasInlinePickerForSection(indexPath.section) && self.inlinePickerIndexPath!.row == indexPath.row);
    }
    
    func displayInlinePickerForRowAtIndexPath(indexPath : NSIndexPath) {
        
        doseTableView.beginUpdates()
        var pickerBeforeSelectedIndexPath = false
        var sameCellClicked = false
        if (self.inlinePickerIndexPath != nil) {
            pickerBeforeSelectedIndexPath = self.inlinePickerIndexPath!.row < indexPath.row
            if (tableViewHasInlinePickerForSection(indexPath.section)) {
                sameCellClicked = (self.inlinePickerIndexPath!.row - 1 == indexPath.row);
            }
            let pickerIndexPath : NSIndexPath = self.inlinePickerIndexPath!
            self.inlinePickerIndexPath = nil
            doseTableView.deleteRowsAtIndexPaths([pickerIndexPath], withRowAnimation: .Middle)
        }
        // remove any picker cell if it exists
        if (!sameCellClicked) {
            // hide the date picker and display the new one
            let rowToReveal : NSInteger = (pickerBeforeSelectedIndexPath ? indexPath.row - 1 : indexPath.row);
            let indexPathToReveal : NSIndexPath = NSIndexPath(forItem: rowToReveal, inSection: indexPath.section)
            togglePickerForSelectedIndexPath(indexPathToReveal)
            self.inlinePickerIndexPath = NSIndexPath(forItem: indexPathToReveal.row + 1, inSection: indexPath.section)
        }
        doseTableView.deselectRowAtIndexPath(indexPath, animated: true)
        doseTableView.endUpdates()
    }
    
    func togglePickerForSelectedIndexPath(indexPath : NSIndexPath) {
        
        let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
        if (tableViewHasInlinePickerForSection(indexPath.section)) {
            doseTableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Middle)
        } else {
            // didn't find a picker below it, so we should insert it
            doseTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Middle)
        }
    }
    
    func collapseOpenedPickerCell() {
        
        //close inline pickers if any present in table cell
        if let pickerIndexPath = inlinePickerIndexPath {
            let previousPickerIndexPath = NSIndexPath(forItem: pickerIndexPath.row - 1, inSection: pickerIndexPath.section)
            self.displayInlinePickerForRowAtIndexPath(previousPickerIndexPath)
        }
    }
    
    func singleDoseEntryCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        let singleDoseEntryCell = doseTableView.dequeueReusableCellWithIdentifier(SINGLE_DOSE_ENTRY_CELL_ID) as? DCSingleDoseEntryTableCell
        singleDoseEntryCell?.singleDoseDelegate = self
        singleDoseEntryCell?.singleDoseTextfield.delegate = singleDoseEntryCell
        singleDoseEntryCell?.singleDoseTextfield.becomeFirstResponder()
        if indexPath.row == RowCount.eZerothRow.rawValue {
            let singleDoseValue = NSMutableString()
            if let dose = singleDose?.doseValue {
                if dose != EMPTY_STRING {
                    singleDoseValue.appendString(dose)
                }
            }
            singleDoseEntryCell?.singleDoseTextfield.text = singleDoseValue as String
        }
        return singleDoseEntryCell!
    }
    
    func datePickerCellAtindexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        let pickerCell = doseTableView.dequeueReusableCellWithIdentifier(SINGLE_DOSE_PICKER_CELL_ID) as? DCSingleDosePickerCell
        if let singleDoseTime = singleDose?.dateAndTime {
            let date = DCDateUtility.dateFromSourceString(singleDoseTime)
            pickerCell?.datePickerView.date =  date
        }
        pickerCell?.pickerCompletion = { time in
            self.singleDose?.dateAndTime = time as? String
            self.doseTableView.beginUpdates()
            self.doseTableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: indexPath.row - 1, inSection: indexPath.section)], withRowAnimation: .Fade)
            self.doseTableView.endUpdates()
        }
        return pickerCell!
    }
    
    //MARK: Keyboard notification Methods
    
    func keyboardDidShow(notification : NSNotification) {
        
        if let pickerIndexPath = self.inlinePickerIndexPath {
            let previousPickerIndexPath = NSIndexPath(forItem: pickerIndexPath.row - 1, inSection: pickerIndexPath.section)
            self.displayInlinePickerForRowAtIndexPath(previousPickerIndexPath)
        }
    }
    
    //MARK: Single Dose Delegate Methods
    
    func singleDoseValueChanged(dose : String?) {
        
        self.singleDose?.doseValue = dose
    }

}
