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

typealias RepeatCompletion = DCRepeat? -> Void

class DCSchedulingDetailViewController: DCAddMedicationDetailViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var detailTableView: UITableView!
    
    var displayArray : NSMutableArray = []
    var inlinePickerIndexPath : NSIndexPath?
    var repeatValue : DCRepeat?
    var repeatCompletion: RepeatCompletion = { value in }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        prepareViewElements()
        populateDisplayArray()
    }
    
    func configureNavigationTitleView() {

        self.title = DCSchedulingHelper.screenTitleForScreenType(self.detailType)
    }
    
    func prepareViewElements() {
        
        //set view properties and values
        detailTableView.layoutMargins = UIEdgeInsetsZero;
        detailTableView.separatorInset = UIEdgeInsetsZero;
    }
    
    func populateDisplayArray() {
        
        //populate display array
        displayArray = DCSchedulingHelper.scheduleDisplayArrayForScreenType(self.detailType)
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
        NSLog("pickerType is %d", pickerType.rawValue)
        pickerCell?.completion = { value in
            
            NSLog("*** Value is %@", value!);
            self.detailTableView.beginUpdates()
            var indexPathArray : NSArray
            if (pickerType == eSchedulingFrequency) {
                self.repeatValue?.repeatType = value as! String
                if (value == WEEKLY) {
                    self.repeatValue?.frequency = "1 week"
                }
                indexPathArray = [NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)]
            } else {
                if (pickerType == eDailyCount) {
                    let days = (value == "1") ? "day" : "days"
                    self.repeatValue?.frequency = NSString(format: "%@ %@", value!, days) as String
                } else if (pickerType == eWeeklyCount) {
                    let week = (value == "1") ? "week" : "weeks"
                    self.repeatValue?.frequency = NSString(format: "%@ %@", value!, week) as String
                }
                indexPathArray = [NSIndexPath(forRow: 1, inSection: 0)]
            }
            self.repeatCompletion(self.repeatValue)
            self.detailTableView.reloadRowsAtIndexPaths(indexPathArray as! [NSIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            self.detailTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
            self.detailTableView.endUpdates()
        }
        return pickerCell!
    }
    
    func schedulingTypeCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingCell {
        
        let schedulingCell : DCSchedulingCell? = detailTableView.dequeueReusableCellWithIdentifier(SCHEDULING_CELL_ID) as? DCSchedulingCell
        schedulingCell?.layoutMargins = UIEdgeInsetsZero
        let displayString = displayArray.objectAtIndex(indexPath.item) as? String
        schedulingCell!.accessoryType = (displayString == previousFilledValue) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        if (indexPath.row == 1) {
            schedulingCell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        schedulingCell!.descriptionLabel.hidden = true
        schedulingCell!.titleLabel?.text = displayString
        return schedulingCell!
    }
    
    func repeatCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingCell {
        
        let repeatCell : DCSchedulingCell? = detailTableView.dequeueReusableCellWithIdentifier(SCHEDULING_CELL_ID) as? DCSchedulingCell
        repeatCell!.layoutMargins = UIEdgeInsetsZero
        repeatCell!.accessoryType = UITableViewCellAccessoryType.None
        NSLog("***** Display Array is %@", displayArray)
        var displayString = EMPTY_STRING
        if (indexPath.row > displayArray.count) {
            displayString = (displayArray.objectAtIndex(indexPath.item) as? String)!
        } else {
            displayString = (displayArray.lastObject as? String)!
        }
        NSLog("displayString is %@", displayString)
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
        
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            var rowCount : NSInteger = displayArray.count;
            if (tableViewHasInlinePicker()) {
                rowCount++
            }
            return rowCount;
        } else {
            return 0;
        }
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
                if (tableViewHasInlinePicker() && self.inlinePickerIndexPath?.row == 1) {
                    let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: eSchedulingFrequency)
                    return pickerCell
                } else {
                    let repeatCell : DCSchedulingCell =  repeatCellAtIndexPath(indexPath)
                    return repeatCell
                }
            } else {
                if (tableViewHasInlinePicker() && self.inlinePickerIndexPath?.row == 1) {
                    let repeatCell : DCSchedulingCell =  repeatCellAtIndexPath(indexPath)
                    return repeatCell
                } else {
                    if (repeatValue?.repeatType == DAILY) {
                        let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: eDailyCount)
                        return pickerCell
                    } else /*if (repeatValue?.repeatType == WEEKLY)*/ {
                        let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: eWeeklyCount)
                        return pickerCell
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (self.detailType == eDetailSchedulingType) {
            //if (indexPath.row == 0) {
                self.selectedEntry(displayArray.objectAtIndex(indexPath.item) as! String)
                self.navigationController?.popToRootViewControllerAnimated(true)
           // }
        } else if (self.detailType == eDetailRepeatType) {
           // if (indexPath.row == 0) {
                // display picker here
                displayInlinePickerForRowAtIndexPath(indexPath)
          //  }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (self.detailType == eDetailSchedulingType) {
            return 0
        } else {
            return (section == 0) ? 0 : 40.0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (self.detailType != eDetailSchedulingType) {
            if (section == 1) {
                let headerView = NSBundle.mainBundle().loadNibNamed(SCHEDULING_HEADER_VIEW_NIB, owner: self, options: nil)[0] as? DCSchedulingHeaderView
                headerView!.backgroundColor = UIColor.clearColor()
                headerView?.populateMessageLabelWithRepeatValue(repeatValue!)
                return headerView!
            } else {
                return nil
            }
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return (indexPathHasPicker(indexPath)) ? PICKER_CELL_HEIGHT : TABLE_VIEW_ROW_HEIGHT
    }
    
}
