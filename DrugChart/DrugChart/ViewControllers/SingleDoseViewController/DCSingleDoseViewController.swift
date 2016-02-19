//
//  DCSingleDoseViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 2/17/16.
//
//

import UIKit

typealias UpdatedSingleDose = DCSingleDose? -> Void

class DCSingleDoseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var doseTableView: UITableView!
    
    var inlinePickerIndexPath : NSIndexPath?
    var singleDose : DCSingleDose?
    var updatedSingleDose : UpdatedSingleDose = { dose in }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = SINGLE_DOSE;
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
        
        if (indexPath.row == 2) {
            let pickerCell = tableView.dequeueReusableCellWithIdentifier(SINGLE_DOSE_PICKER_CELL_ID) as? DCSingleDosePickerCell
            if let singleDoseTime = singleDose?.dateAndTime {
                let date = DCDateUtility.dateFromSourceString(singleDoseTime)
                pickerCell?.datePickerView.date =  date
            } 
            pickerCell?.pickerCompletion = { time in
                self.singleDose?.dateAndTime = time as? String
                tableView.beginUpdates()
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: indexPath.row - 1, inSection: indexPath.section)], withRowAnimation: .Fade)
                tableView.endUpdates()
            }
            return pickerCell!
        } else {
            let singleDoseCell = tableView.dequeueReusableCellWithIdentifier(SINGLE_DOSE_CELL_ID) as? DCSingleDoseTableCell
            if indexPath.row == RowCount.eZerothRow.rawValue {
                singleDoseCell?.titleLabel.text = NSLocalizedString("DOSE", comment: "")
                singleDoseCell?.valueLabel.text = singleDose?.doseValue
            } else if indexPath.row == RowCount.eFirstRow.rawValue {
                singleDoseCell?.titleLabel.text = NSLocalizedString("DATE", comment: "")
                singleDoseCell?.valueLabel.text = singleDose?.dateAndTime
            }
            return singleDoseCell!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return (indexPath.row == 2) ? PICKER_CELL_HEIGHT : 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.row == RowCount.eZerothRow.rawValue) {
            //display new dose view
            collapseOpenedPickerCell()
            displayAddNewDoseView()
        } else if (indexPath.row == RowCount.eFirstRow.rawValue) {
            //display inline picker
            displayInlinePickerForRowAtIndexPath(indexPath)
            if (singleDose?.dateAndTime == nil) {
                let dateString = DCDateUtility.dateStringFromDate(DCDateUtility.dateInCurrentTimeZone(NSDate()), inFormat: START_DATE_FORMAT)
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
    
    func displayAddNewDoseView() {
        
        let addMedicationStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let addNewValueViewController = addMedicationStoryboard.instantiateViewControllerWithIdentifier(ADD_NEW_VALUE_SBID) as? DCAddNewValueViewController
        addNewValueViewController?.titleString = "Dose"
        addNewValueViewController?.placeHolderString = "Dose"
        addNewValueViewController?.backButtonTitle = SINGLE_DOSE
        addNewValueViewController?.detailType = eAddSingleDose
        if let doseValue = self.singleDose?.doseValue {
            addNewValueViewController?.previousValue = doseValue
        }
        addNewValueViewController?.newValueEntered = { value in
            self.singleDose?.doseValue = value!
            self.doseTableView.beginUpdates()
            self.doseTableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation:.Fade)
            self.doseTableView.endUpdates()
        }
        self.navigationController?.pushViewController(addNewValueViewController!, animated: true)
    }

}
