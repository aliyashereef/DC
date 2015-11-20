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
let WEEK_DAYS_COUNT : NSInteger = 7
let HEADER_VIEW_MIN_HEIGHT : CGFloat = 40
let HEADER_VIEW_LABEL_MAX_WIDTH : CGFloat = 270


typealias RepeatCompletion = DCRepeat? -> Void

class DCSchedulingDetailViewController: DCAddMedicationDetailViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var detailTableView: UITableView!
    
    var displayArray : NSMutableArray = []
    var weekDaysArray = NSMutableArray()
    var inlinePickerIndexPath : NSIndexPath?
    var repeatValue : DCRepeat?
    var repeatCompletion: RepeatCompletion = { value in }
    var headerHeight : CGFloat = 0.0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        prepareViewElements()
        populateDisplayArray()
        populateWeekDaysArray()
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
    
    func populateWeekDaysArray() {
        
        // week days array
        weekDaysArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    }
    
    func tableViewHasInlinePickerForSection (section : NSInteger) -> Bool {
        
        return (self.inlinePickerIndexPath != nil && section == self.inlinePickerIndexPath?.section)
    }

    func indexPathHasPicker(indexPath : NSIndexPath) -> Bool {
        
        return (tableViewHasInlinePickerForSection(indexPath.section) && self.inlinePickerIndexPath!.row == indexPath.row);
    }
    
    func inlinePickerCellAtIndexPath(indexPath : NSIndexPath, forPickerType pickerType : PickerType) -> DCSchedulingPickerCell {
        
        //display inline picker
        let pickerCell : DCSchedulingPickerCell? = detailTableView.dequeueReusableCellWithIdentifier(SCHEDULING_PICKER_CELL_ID) as? DCSchedulingPickerCell
        pickerCell?.layoutMargins = UIEdgeInsetsZero
        pickerCell?.weekDaysArray = weekDaysArray
        pickerCell?.repeatValue = repeatValue
        pickerCell?.configurePickerCellForPickerType(pickerType)
        pickerCell?.pickerCompletion = { value in
            
            if (pickerType == eSchedulingFrequency) {
                self.repeatValue?.repeatType = value as! String
                if (value == DAILY) {
                    self.displayArray = [FREQUENCY, EVERY]
                    self.repeatValue?.frequency = DAY
                } else if (value == WEEKLY) {
                    self.repeatValue?.frequency = "week"
                    self.displayArray = [FREQUENCY, EVERY]
                } else if (value == MONTHLY) {
                    self.repeatValue?.frequency = "month"
                    self.repeatValue?.isEachValue = true
                    self.repeatValue?.onTheValue = ""
                    self.displayArray = [FREQUENCY, EVERY, EACH, ON_THE]
                } else if (value == YEARLY) {
                    self.repeatValue?.frequency = "year"
                    self.displayArray = [FREQUENCY, EVERY, EACH, ON_THE]
                }
            } else {
                if (pickerType == eDailyCount) {
                    if (value == "1") {
                        self.repeatValue?.frequency = DAY
                    } else {
                        
                    }
                    let days = (value == "1") ? DAY : "days"
                    self.repeatValue?.frequency = NSString(format: "%@ %@", value!, days) as String
                } else if (pickerType == eWeeklyCount) {
                    let week = (value == "1") ? "week" : "weeks"
                    self.repeatValue?.frequency = NSString(format: "%@ %@", value!, week) as String
                } else if (pickerType == eMonthlyCount) {
                    let week = (value == "1") ? "month" : "months"
                    self.repeatValue?.frequency = NSString(format: "%@ %@", value!, week) as String
                } else if (pickerType == eMonthEachCount) {
                    self.repeatValue?.isEachValue = true
                    self.repeatValue?.eachValue = value! as String
                } else if (pickerType == eMonthOnTheCount) {
                    self.repeatValue?.isEachValue = false
                    self.repeatValue?.onTheValue = value! as String
                }
            }
            self.repeatCompletion(self.repeatValue)
            self.detailTableView.reloadData()
        }
        return pickerCell!
    }
    
    func schedulingTypeCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingCell {
        
        let schedulingCell : DCSchedulingCell? = detailTableView.dequeueReusableCellWithIdentifier(SCHEDULING_CELL_ID) as? DCSchedulingCell
        schedulingCell?.layoutMargins = UIEdgeInsetsZero
        var displayString = EMPTY_STRING
        if (indexPath.section == 1 && self.repeatValue?.repeatType == WEEKLY) {
            displayString = weekDaysArray.objectAtIndex(indexPath.item) as! String
            if (repeatValue?.weekDays == nil) {
                let currentDayIndex : NSInteger = DCDateUtility.currentWeekDayIndex()
                if (currentDayIndex-1 == indexPath.row) { // There was a mismatch in the week days displayed. have to correct that one
                    repeatValue?.weekDays = NSMutableArray()
                    repeatValue?.weekDays.addObject(displayString)
                    schedulingCell?.accessoryType = UITableViewCellAccessoryType.Checkmark
                } else {
                    schedulingCell?.accessoryType = UITableViewCellAccessoryType.None
                }
            } else {
                let valueExists : Bool = (repeatValue?.weekDays.containsObject(displayString))!
                if (valueExists && weekDaysArray.indexOfObject(displayString) == indexPath.row) {
                    schedulingCell?.accessoryType = UITableViewCellAccessoryType.Checkmark
                } else {
                    
                        schedulingCell?.accessoryType = UITableViewCellAccessoryType.None
                }
            }
        } else {
            displayString = (displayArray.objectAtIndex(indexPath.item) as? String)!
            schedulingCell!.accessoryType = (displayString == previousFilledValue) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        }
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
        repeatCell!.descriptionLabel.hidden = false
        return repeatCell!
    }
    
    func displayInlinePickerForRowAtIndexPath(indexPath : NSIndexPath) {
        
        detailTableView.beginUpdates()
        var pickerBeforeSelectedIndexPath = false
        var sameCellClicked = false
        if (/*tableViewHasInlinePickerForSection(indexPath.section)*/self.inlinePickerIndexPath != nil) {
            pickerBeforeSelectedIndexPath = self.inlinePickerIndexPath!.row < indexPath.row
            if (tableViewHasInlinePickerForSection(indexPath.section)) {
                sameCellClicked = (self.inlinePickerIndexPath!.row - 1 == indexPath.row);
            }
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
        if (tableViewHasInlinePickerForSection(indexPath.section)) {
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
            //var rowCount : NSInteger = displayArray.count;
            var rowCount = 2;
            if (tableViewHasInlinePickerForSection(section)) {
                rowCount++
            }
            return rowCount
        } else {
            var rowCount : NSInteger = 0
            if (repeatValue?.repeatType == WEEKLY) {
                rowCount = WEEK_DAYS_COUNT
            } else if (repeatValue?.repeatType == MONTHLY || repeatValue?.repeatType == YEARLY) {
                rowCount = 2
            }
            if (tableViewHasInlinePickerForSection(section)) {
                rowCount++
            }
            return rowCount
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            if (self.detailType == eDetailSchedulingType) {
                let schedulingCell : DCSchedulingCell = schedulingTypeCellAtIndexPath(indexPath)
                return schedulingCell
            } else {
                if (indexPath.row == 0) {
                    let repeatCell : DCSchedulingCell = repeatCellAtIndexPath(indexPath)
                    repeatCell.titleLabel.text = FREQUENCY
                    repeatCell.descriptionLabel.text = repeatValue?.repeatType
                    return repeatCell
                } else if (indexPath.row == 1) {
                    if (tableViewHasInlinePickerForSection(indexPath.section) && self.inlinePickerIndexPath?.row == 1) {
                        let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: eSchedulingFrequency)
                        return pickerCell
                    } else {
                        let repeatCell : DCSchedulingCell =  repeatCellAtIndexPath(indexPath)
                        repeatCell.titleLabel.text = EVERY
                        if (repeatValue?.frequency == "1 day") {
                            repeatCell.descriptionLabel.text = DAY
                        } else if (repeatValue?.frequency == "1 week") {
                            repeatCell.descriptionLabel.text = "week"
                        } else if (repeatValue?.frequency == "1 month") {
                            repeatCell.descriptionLabel.text = "month"
                        } else {
                            repeatCell.descriptionLabel.text = repeatValue?.frequency
                        }
                        return repeatCell
                    }
                } else {
                    if (tableViewHasInlinePickerForSection(indexPath.section) && self.inlinePickerIndexPath == indexPath) {
                        if (repeatValue?.repeatType == DAILY) {
                            let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: eDailyCount)
                            return pickerCell
                        } else if (repeatValue?.repeatType == WEEKLY) {
                            let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: eWeeklyCount)
                            return pickerCell
                        } else /*if (repeatValue?.repeatType == MONTHLY)*/ {
                            let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: eMonthlyCount)
                            return pickerCell
                        }
                    } else {
                        let repeatCell : DCSchedulingCell =  repeatCellAtIndexPath(indexPath)
                        repeatCell.titleLabel.text = EVERY
                        repeatCell.descriptionLabel.text = repeatValue?.frequency
                        return repeatCell
                    }
                }
            }
        } else {
            //weekly cell
            if (repeatValue?.repeatType == WEEKLY) {
                let weekDaysCell : DCSchedulingCell = schedulingTypeCellAtIndexPath(indexPath)
                return weekDaysCell
            } else {
                let repeatCell : DCSchedulingCell =  repeatCellAtIndexPath(indexPath)
                if (indexPath.row == 0) {
                    repeatCell.titleLabel.text = EACH
                    repeatCell.descriptionLabel.hidden = true
                   // repeatCell.descriptionLabel.text = repeatValue?.eachValue
                    repeatCell.accessoryType = (repeatValue?.isEachValue == true) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
                } else if (indexPath.row == 1) {
                    if (tableViewHasInlinePickerForSection(indexPath.section) && self.inlinePickerIndexPath == indexPath) {
                        let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: eMonthEachCount)
                        return pickerCell
                    } else {
                        repeatCell.titleLabel.text = ON_THE
                        //repeatCell.descriptionLabel.text = repeatValue?.onTheValue
                        repeatCell.descriptionLabel.hidden = true
                        repeatCell.accessoryType = (repeatValue?.isEachValue == false) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
                    }
                } else /*if (indexPath.row == 2)*/ {
                    if (tableViewHasInlinePickerForSection(indexPath.section) && self.inlinePickerIndexPath == indexPath) {
                        let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: eMonthOnTheCount)
                        return pickerCell
                    } else {
                        repeatCell.titleLabel.text = ON_THE
                       // repeatCell.descriptionLabel.text = repeatValue?.onTheValue
                        repeatCell.descriptionLabel.hidden = true
                        repeatCell.accessoryType = (repeatValue?.isEachValue == false) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
                    }
                }
                return repeatCell
            }
         }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0) {
            if (self.detailType == eDetailSchedulingType) {
                self.selectedEntry(displayArray.objectAtIndex(indexPath.item) as! String)
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else if (self.detailType == eDetailRepeatType) {
                // display picker here
                displayInlinePickerForRowAtIndexPath(indexPath)
            }
        } else {
            //weekly schedule
            if (repeatValue?.repeatType == WEEKLY) {
                let weekDay = weekDaysArray.objectAtIndex(indexPath.item)
                let index : NSInteger = (self.repeatValue?.weekDays.indexOfObject(weekDay))!
                let valueExists : Bool = (repeatValue?.weekDays.containsObject(weekDay))!
                if (valueExists == false) {
                    self.repeatValue?.weekDays.addObject(weekDay)
                } else {
                    //remove the already existing object from array
                    self.repeatValue?.weekDays.removeObjectAtIndex(index)
                 }
                self.repeatCompletion(self.repeatValue)
                tableView.beginUpdates()
                self.detailTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
                tableView.endUpdates()
            } else {
                if (indexPath.row == 0) {
                    repeatValue?.isEachValue = true
                } else if (indexPath.row == 1 || indexPath.row == 2) {
                    repeatValue?.isEachValue = false
                }
                self.detailTableView.beginUpdates()
                self.detailTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
                self.detailTableView.endUpdates()
                let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.14 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    // your function here
                    self.displayInlinePickerForRowAtIndexPath(indexPath)

                })
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (self.detailType == eDetailSchedulingType) {
            return 0
        } else {
            if (section == 0) {
                return 0
            } else {
                return (headerHeight > HEADER_VIEW_MIN_HEIGHT) ? headerHeight : HEADER_VIEW_MIN_HEIGHT
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (self.detailType != eDetailSchedulingType) {
            if (section == 1) {
                let headerView = NSBundle.mainBundle().loadNibNamed(SCHEDULING_HEADER_VIEW_NIB, owner: self, options: nil)[0] as? DCSchedulingHeaderView
                headerView?.populateMessageLabelWithRepeatValue(repeatValue!)
                headerHeight = DCUtility.textViewSizeWithText(headerView?.messageLabel.text, maxWidth: HEADER_VIEW_LABEL_MAX_WIDTH, font: UIFont.systemFontOfSize(13.0)).height + 10
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
