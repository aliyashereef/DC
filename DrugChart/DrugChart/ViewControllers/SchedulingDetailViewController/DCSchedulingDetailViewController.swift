//
//  DCSchedulingDetailViewController.swift
//  DrugChart
//
//  Created by qbuser on 11/11/15.
//
//

import UIKit

let TABLE_VIEW_ROW_HEIGHT : CGFloat = 44.0
let PICKER_CELL_HEIGHT : CGFloat = 216.0

class DCSchedulingDetailViewController: DCAddMedicationDetailViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var detailTableView: UITableView!
    
    var displayArray : NSMutableArray = []
    var inlinePickerIndexPath : NSIndexPath?
    var repeatValue : DCRepeat?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        prepareViewElements()
        populateDisplayArray()
    }
    
    func configureNavigationTitleView() {
        
        if (self.detailType == eDetailSchedulingType) {
            self.title = NSLocalizedString("SCHEDULING", comment:"")
        } else if (self.detailType == eDetailRepeatType) {
            self.title = NSLocalizedString("REPEAT", comment: "")
        }
    }
    
    func prepareViewElements() {
        
        //set view properties and values
        detailTableView.layoutMargins = UIEdgeInsetsZero;
        detailTableView.separatorInset = UIEdgeInsetsZero;
    }
    
    func populateDisplayArray() {
        
        //populate display array
        if (self.detailType == eDetailSchedulingType) {
            displayArray = [SPECIFIC_TIMES, INTERVAL]
        } else if (self.detailType == eDetailRepeatType) {
            displayArray = ["Frequency", "Every"]
        }
    }
    
    func tableViewHasInlinePicker () -> Bool {
        
        return (self.inlinePickerIndexPath != nil)
    }

    func indexPathHasPicker(indexPath : NSIndexPath) -> Bool {
        
        return (tableViewHasInlinePicker() && self.inlinePickerIndexPath!.row == indexPath.row);
    }
    
    func inlinePickerCellAtIndexPath(indexPath : NSIndexPath, forPickerType pickerType : PickerType) -> DCSchedulingPickerCell {
        
        //display inline picker
        let pickerCell : DCSchedulingPickerCell? = detailTableView.dequeueReusableCellWithIdentifier(SCHEDULING_PICKER_CELL_ID) as? DCSchedulingPickerCell
        pickerCell?.layoutMargins = UIEdgeInsetsZero
        pickerCell?.configurePickerCellForPickerType(pickerType)
        pickerCell?.completion = { value in
            NSLog("*** Value is %@", value!);
            self.selectedEntry(value! as String)
            self.detailTableView.beginUpdates()
            self.detailTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            self.detailTableView.endUpdates()
        }
        return pickerCell!
    }
    
    func schedulingTypeCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingCell {
        
        let schedulingCell : DCSchedulingCell? = detailTableView.dequeueReusableCellWithIdentifier(SCHEDULING_CELL_ID) as? DCSchedulingCell
        schedulingCell?.layoutMargins = UIEdgeInsetsZero
        let displayString = displayArray.objectAtIndex(indexPath.item) as? String
        schedulingCell!.accessoryType = (displayString == previousFilledValue) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        schedulingCell!.descriptionLabel.hidden = true
        schedulingCell!.titleLabel?.text = displayString
        return schedulingCell!
    }
    
    func repeatCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingCell {
        
        let repeatCell : DCSchedulingCell? = detailTableView.dequeueReusableCellWithIdentifier(SCHEDULING_CELL_ID) as? DCSchedulingCell
        repeatCell!.layoutMargins = UIEdgeInsetsZero
        repeatCell!.accessoryType = UITableViewCellAccessoryType.None
        let displayString = displayArray.objectAtIndex(indexPath.item) as? String
        repeatCell!.titleLabel.text = displayString
        repeatCell!.descriptionLabel.hidden = false
        if (indexPath.row == 0) {
            repeatCell!.descriptionLabel.text = repeatValue?.repeatType
        } else {
            repeatCell!.descriptionLabel.text = repeatValue?.frequency
        }
        return repeatCell!
    }
    
    func displayInlinePickerForRowAtIndexPath(indexPath : NSIndexPath) {
        
        detailTableView.beginUpdates()
        var pickerBeforeSelectedIndexPath = false
        var sameCellClicked = false
        if (tableViewHasInlinePicker()) {
            pickerBeforeSelectedIndexPath = self.inlinePickerIndexPath!.row < indexPath.row
            sameCellClicked = (self.inlinePickerIndexPath!.row - 1 == indexPath.row);
            NSLog("INline picker indexpath is %@", self.inlinePickerIndexPath!)
            let pickerIndexPath : NSIndexPath = self.inlinePickerIndexPath!
            self.inlinePickerIndexPath = nil
            detailTableView.deleteRowsAtIndexPaths([pickerIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        // remove any picker cell if it exists
        if (!sameCellClicked) {
            // hide the date picker and display the new one
            let rowToReveal : NSInteger = (pickerBeforeSelectedIndexPath ? indexPath.row - 1 : indexPath.row);
            let indexPathToReveal : NSIndexPath = NSIndexPath(forItem: rowToReveal, inSection: indexPath.section)
            togglePickerForSelectedIndexPath(indexPathToReveal)
            self.inlinePickerIndexPath = NSIndexPath(forItem: indexPathToReveal.row + 1, inSection: indexPath.section)
        }
        detailTableView.deselectRowAtIndexPath(indexPath, animated: true)
        detailTableView.endUpdates()
    }
    
    func togglePickerForSelectedIndexPath(indexPath : NSIndexPath) {
        
       // detailTableView.beginUpdates()
        let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
        if (tableViewHasInlinePicker()) {
            detailTableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            // didn't find a picker below it, so we should insert it
            detailTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    // MARK: TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rowCount : NSInteger = displayArray.count;
        if (tableViewHasInlinePicker()) {
            rowCount++
        }
        return rowCount;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (self.detailType == eDetailSchedulingType) {
            let schedulingCell : DCSchedulingCell = schedulingTypeCellAtIndexPath(indexPath)
            return schedulingCell
        } else {
            if (indexPath.row == 0) {
                let repeatCell : DCSchedulingCell = repeatCellAtIndexPath(indexPath)
                return repeatCell
            } else if (indexPath.row == 1) {
                if (tableViewHasInlinePicker()) {
                    let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: eSchedulingFrequency)
                    return pickerCell
                } else {
                    let schedulingCell : DCSchedulingCell = schedulingTypeCellAtIndexPath(indexPath)
                    return schedulingCell
                }
            } else {
                let schedulingCell : DCSchedulingCell = schedulingTypeCellAtIndexPath(indexPath)
                return schedulingCell
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (self.detailType == eDetailSchedulingType) {
            self.selectedEntry(displayArray.objectAtIndex(indexPath.item) as! String)
            self.navigationController?.popToRootViewControllerAnimated(true)
        } else if (self.detailType == eDetailRepeatType) {
            if (indexPath.row == 0) {
                // display picker here
                displayInlinePickerForRowAtIndexPath(indexPath)
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return (indexPathHasPicker(indexPath)) ? PICKER_CELL_HEIGHT : TABLE_VIEW_ROW_HEIGHT
    }
    
}
