//
//  DCReviewViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/21/16.
//
//

import UIKit

let WEEKS_TEXT = "Weeks"
let MONTHS_TEXT = "Months"

typealias UpdatedReviewObject = DCMedicationReview? -> Void

class DCReviewViewController: DCBaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var reviewTableView: UITableView!
    
    var inlinePickerIndexPath : NSIndexPath?
    var review : DCMedicationReview?
    var updatedReviewObject : UpdatedReviewObject?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        reviewTableView.keyboardDismissMode = .OnDrag
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if (self.review?.reviewType == REVIEW_INTERVAL) {
            self.updateReviewIntervalCountValue()
        }
        self.updatedReviewObject!(self.review)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
        
    // MARK: TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return (review?.reviewType == nil) ? SectionCount.eSecondSection.rawValue : SectionCount.eThirdSection.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case eZerothSection.rawValue :
                return RowCount.eSecondRow.rawValue
            case eFirstSection.rawValue :
                var rowCount = RowCount.eFirstRow.rawValue
                if (review?.reviewType == REVIEW_INTERVAL) {
                    rowCount = RowCount.eSecondRow.rawValue
                }
                if (tableViewHasInlinePickerForSection(section)) {
                    // increment row count if there is picker view displayed
                    rowCount++
                }
                return rowCount
            case eSecondSection.rawValue :
                //warning period section
                return RowCount.eFirstRow.rawValue
            default :
                break
        }
        return RowCount.eZerothRow.rawValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            case eZerothSection.rawValue :
                let reviewCell = self.reviewTypeSelectionCellAtIndexPath(indexPath)
                return reviewCell
            case eFirstSection.rawValue :
                if (review?.reviewType == nil) {
                    let warningCell = warningsPeriodCellAtIndexPath(indexPath)
                    return warningCell
                } else if (review?.reviewType == REVIEW_INTERVAL) {
                    let reviewIntervalCell = self.reviewIntervalCellAtIndexPath(indexPath)
                    return reviewIntervalCell!
                } else {
                    //review date
                    let reviewDateCell = self.reviewDateCellAtIndexPath(indexPath)
                    return reviewDateCell!
             }
            case eSecondSection.rawValue :
                let warningCell = self.warningsPeriodCellAtIndexPath(indexPath)
                return warningCell
            default :
                break;
            
        }
        let reviewCell = self.reviewTypeSelectionCellAtIndexPath(indexPath)
        return reviewCell
      }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.view.endEditing(true)
        switch indexPath.section {
            case eZerothSection.rawValue :
                self.updateViewOnReviewTypeCellSelectionAtIndexPath(indexPath)
            case eFirstSection.rawValue :
                if review?.reviewType == nil {
                    self.displayWarningPeriodView()
                } else if (review?.reviewType == REVIEW_INTERVAL) {
                    if (indexPath.row == RowCount.eFirstRow.rawValue) {
                        displayInlinePickerForRowAtIndexPath (indexPath)
                    }
                } else {
                    displayInlinePickerForRowAtIndexPath (indexPath)
                }
            case eSecondSection.rawValue :
                self.displayWarningPeriodView()
            default:
                break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return (indexPathHasPicker(indexPath)) ? PICKER_CELL_HEIGHT : TABLE_VIEW_ROW_HEIGHT
    }
    
    // MARK: Private Methods
    
    func reviewTypeSelectionCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        //select review type
        let reviewCell = reviewTableView.dequeueReusableCellWithIdentifier(REVIEW_SELECTION_CELL_ID, forIndexPath: indexPath)
        reviewCell.textLabel?.font = UIFont.systemFontOfSize(15.0)
        if (indexPath.section == eZerothSection.rawValue) {
            if indexPath.row == RowCount.eZerothRow.rawValue {
                reviewCell.textLabel?.text = REVIEW_INTERVAL
                reviewCell.accessoryType = (review?.reviewType == REVIEW_INTERVAL) ? .Checkmark : .None
            } else {
                reviewCell.textLabel?.text = REVIEW_DATE
                reviewCell.accessoryType = (review?.reviewType == REVIEW_DATE) ? .Checkmark : .None
            }
        }
        return reviewCell
    }
    
    func updateViewOnReviewTypeCellSelectionAtIndexPath(indexPath : NSIndexPath) {
        
        // review type cell selection
        self.closeInlinePickers()
        if review?.reviewType == nil {
            // initialise reviewtypes
            review?.reviewInterval = DCReviewInterval.init()
            review?.reviewDate = DCReviewDate.init()
        }
        review?.reviewType = (indexPath.row == RowCount.eZerothRow.rawValue) ? REVIEW_INTERVAL : REVIEW_DATE
        if (indexPath.row == RowCount.eZerothRow.rawValue) {
            let reviewIntervalCell = reviewTableView.cellForRowAtIndexPath(indexPath)
            reviewIntervalCell?.accessoryType = .Checkmark
            let reviewDateCell = reviewTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
            reviewDateCell?.accessoryType = .None
        } else {
            let reviewIntervalCell = reviewTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
            reviewIntervalCell?.accessoryType = .None
            let reviewDateCell = reviewTableView.cellForRowAtIndexPath(indexPath)
            reviewDateCell?.accessoryType = .Checkmark
        }
        let sectionCount = reviewTableView.numberOfSections
        reviewTableView.beginUpdates()
        if (sectionCount == 2) {
            reviewTableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
        } else {
            reviewTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
        }
        reviewTableView.endUpdates()
    }
    
    func displayWarningPeriodView () {
        
        self.closeInlinePickers()
        //show warnings period view
        let addMedicationStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let addNewValueViewController = addMedicationStoryboard.instantiateViewControllerWithIdentifier(ADD_NEW_VALUE_SBID) as? DCAddNewValueViewController
        addNewValueViewController!.titleString = NSLocalizedString("WARNING_PERIOD", comment: "warning period cell text")
        addNewValueViewController!.placeHolderString = NSLocalizedString("BEGINS", comment: "warning period begins placeholder")
        addNewValueViewController!.backButtonTitle = self.title!
        addNewValueViewController!.detailType = eAddValueWithUnit
        addNewValueViewController!.unitArray = [HOURS_TITLE, DAYS_TITLE]
        if let warningPeriod = review?.warningPeriod {
            addNewValueViewController!.previousValue = warningPeriod
        }
        addNewValueViewController!.newValueEntered = { value in
            self.review?.warningPeriod = value
            self.reviewTableView.reloadData()
        }
        self.navigationController?.pushViewController(addNewValueViewController!, animated: true)
    }
    
    func warningsPeriodCellAtIndexPath(indexPath : NSIndexPath) -> DCAddNewValueTableViewCell {
        
        let warningCell = reviewTableView.dequeueReusableCellWithIdentifier(PICKER_DROP_DOWN_CELL, forIndexPath: indexPath) as? DCAddNewValueTableViewCell
        warningCell!.unitLabel.text = NSLocalizedString("WARNING_PERIOD", comment: "warning period cell text")
        if let warningPeriod = review?.warningPeriod {
            warningCell!.unitValueLabel.text = String(format: "Before %@", warningPeriod)
        } else {
            warningCell!.unitValueLabel.text = EMPTY_STRING
        }
        warningCell!.accessoryType = .DisclosureIndicator
        return warningCell!
    }
    
    func reviewIntervalCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell? {
        
        //tablecell at first section of review type interval
        switch indexPath.row {
            case RowCount.eZerothRow.rawValue :
                // review interval count
                let newValueTableCell = reviewTableView.dequeueReusableCellWithIdentifier(VALUE_TEXTFIELD_CELL, forIndexPath: indexPath) as? DCAddNewValueTableViewCell
                if let reviewInterval = review?.reviewInterval {
                    if let intervalCount = reviewInterval.intervalCount {
                        newValueTableCell!.newValueTextField.text = intervalCount
                    } else {
                        newValueTableCell!.newValueTextField.placeholder =  NSLocalizedString("IN", comment: "in placeholder text")
                    }
                }
                return newValueTableCell!
            case RowCount.eFirstRow.rawValue :
                // interval unit
                let reviewIntervalTableCell = reviewTableView.dequeueReusableCellWithIdentifier(PICKER_DROP_DOWN_CELL, forIndexPath: indexPath) as? DCAddNewValueTableViewCell
                reviewIntervalTableCell!.unitLabel.text = DOSE_UNIT_TITLE
                if let reviewInterval = review?.reviewInterval {
                    if (reviewInterval.unit == nil) {
                        reviewInterval.unit = HOURS_TITLE
                    }
                    reviewIntervalTableCell!.unitValueLabel.text = reviewInterval.unit
                }
                return reviewIntervalTableCell!
            case RowCount.eSecondRow.rawValue :
                // interval unit types picker
                let pickerCell : DCAddNewValuePickerCell = (reviewTableView.dequeueReusableCellWithIdentifier(PICKER_CELL) as? DCAddNewValuePickerCell)!
                pickerCell.configurePickerCellWithValues([HOURS_TITLE, DAYS_TITLE, WEEKS_TEXT, MONTHS_TEXT])
                if let unit = self.review?.reviewInterval?.unit {
                    pickerCell.selectPickerViewForValue(unit)
                }
                pickerCell.pickerCompletion = { value in
                    self.review?.reviewInterval?.unit = value
                    self.reviewTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: RowCount.eFirstRow.rawValue, inSection: eFirstSection.rawValue)], withRowAnimation: .None)
                }
                return pickerCell
            default:
                break
            }
        return nil
    }
    
    func reviewDateCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell? {
        
        //review date cells for firat section
        if (indexPath.row == RowCount.eZerothRow.rawValue) {
            // review date cell
            let newValueTableCell = reviewTableView.dequeueReusableCellWithIdentifier(PICKER_DROP_DOWN_CELL, forIndexPath: indexPath) as? DCAddNewValueTableViewCell
            newValueTableCell!.unitLabel.text = DATE
            if let reviewDate = review?.reviewDate {
                newValueTableCell!.unitValueLabel.text = (reviewDate.dateAndTime == nil) ? EMPTY_STRING : reviewDate.dateAndTime
            }
            return newValueTableCell!
        } else {
            // date pickercell
            let datePickerCell : DCDatePickerCell? = reviewTableView.dequeueReusableCellWithIdentifier(DATE_PICKER_CELL_IDENTIFIER) as?DCDatePickerCell
            datePickerCell?.datePicker?.minimumDate = NSDate()
            if let reviewDate = review?.reviewDate?.dateAndTime {
                datePickerCell?.datePicker?.date = DCDateUtility.dateFromSourceString(reviewDate)
            } else {
                self.performSelector(Selector("reloadReviewDateTableCellForDateValue:"), withObject: NSDate(), afterDelay: 0.02)
            }
            datePickerCell?.selectedDate = { date in
                self.reloadReviewDateTableCellForDateValue(date)
            }
            return datePickerCell!
        }
    }
    
    func tableViewHasInlinePickerForSection (section : NSInteger) -> Bool {
        
        return (self.inlinePickerIndexPath != nil && section == self.inlinePickerIndexPath?.section)
    }
    
    func indexPathHasPicker(indexPath : NSIndexPath) -> Bool {
        
        return (tableViewHasInlinePickerForSection(indexPath.section) && self.inlinePickerIndexPath!.row == indexPath.row);
    }
    
    func displayInlinePickerForRowAtIndexPath(indexPath : NSIndexPath) {
        
        reviewTableView.beginUpdates()
        var pickerBeforeSelectedIndexPath = false
        var sameCellClicked = false
        if (self.inlinePickerIndexPath != nil) {
            pickerBeforeSelectedIndexPath = self.inlinePickerIndexPath!.row < indexPath.row
            if (tableViewHasInlinePickerForSection(indexPath.section)) {
                sameCellClicked = (self.inlinePickerIndexPath!.row - 1 == indexPath.row);
            }
            let pickerIndexPath : NSIndexPath = self.inlinePickerIndexPath!
            self.inlinePickerIndexPath = nil
            reviewTableView.deleteRowsAtIndexPaths([pickerIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        // remove any picker cell if it exists
        if (!sameCellClicked) {
            // hide the date picker and display the new one
            let rowToReveal : NSInteger = (pickerBeforeSelectedIndexPath ? indexPath.row - 1 : indexPath.row);
            let indexPathToReveal : NSIndexPath = NSIndexPath(forItem: rowToReveal, inSection: indexPath.section)
            togglePickerForSelectedIndexPath(indexPathToReveal)
            self.inlinePickerIndexPath = NSIndexPath(forItem: indexPathToReveal.row + 1, inSection: indexPath.section)
        }
        reviewTableView.deselectRowAtIndexPath(indexPath, animated: true)
        reviewTableView.endUpdates()
    }
    
    func togglePickerForSelectedIndexPath(indexPath : NSIndexPath) {
        
        let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
        if (tableViewHasInlinePickerForSection(indexPath.section)) {
            reviewTableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            // didn't find a picker below it, so we should insert it
            reviewTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func closeInlinePickers () {
        
        if let pickerIndexPath = inlinePickerIndexPath {
            let previousPickerIndexPath = NSIndexPath(forItem: pickerIndexPath.row - 1, inSection: pickerIndexPath.section)
            self.displayInlinePickerForRowAtIndexPath(previousPickerIndexPath)
        }
    }
    
    func updateReviewIntervalCountValue() {
        
        //update the interval count value
        let intervalCell = reviewTableView.cellForRowAtIndexPath(NSIndexPath(forItem: RowCount.eZerothRow.rawValue, inSection: eFirstSection.rawValue)) as? DCAddNewValueTableViewCell
        review?.reviewInterval?.intervalCount = intervalCell!.newValueTextField.text
    }
    
    func reloadReviewDateTableCellForDateValue(date : NSDate) {
        
        let dateString = DCDateUtility.dateStringFromDate(date, inFormat: START_DATE_FORMAT)
        self.review?.reviewDate?.dateAndTime = dateString
        reviewTableView.beginUpdates()
        reviewTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: eFirstSection.rawValue) ], withRowAnimation: .Fade)
        reviewTableView.endUpdates()
    }
    
    // MARK: Notification Methods
    
    func keyboardDidShow(notification : NSNotification) {
        
        closeInlinePickers()
    }
    
}
