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
    
    var medicationDetails : DCMedicationScheduleDetails?
    var isAddMedicationReview : Bool = true
    var inlinePickerIndexPath : NSIndexPath?
    var review : DCMedicationReview?
    var updatedReviewObject : UpdatedReviewObject?
    var saveButton: UIBarButtonItem?
    var isValid : Bool = true
    
    //MARK: View Management Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        reviewTableView.keyboardDismissMode = .OnDrag
        reviewTableView.rowHeight = UITableViewAutomaticDimension
        reviewTableView.estimatedRowHeight = 44.0
        reviewTableView.tableFooterView = UIView(frame: CGRectZero)
        self.configureNavigationBarItems()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if (self.review?.reviewType == REVIEW_DUE_IN) {
            self.updateReviewIntervalCountValue()
        }
        if (self.review?.warningPeriod != nil) {
            self.updateWarningPeriodIntervalCountValue()
        }
        self.updatedReviewObject!(self.review)
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        setSaveButtonDisability()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    func configureNavigationBarItems() {
        
        if !isAddMedicationReview {
            // Configure bar buttons for Add new.
            let cancelButton: UIBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target: self, action: #selector(self.cancelButtonPressed))
            self.navigationItem.leftBarButtonItem = cancelButton
            saveButton = UIBarButtonItem(title: SAVE_BUTTON_TITLE, style: .Plain, target: self, action: #selector(self.saveButtonPressed))
            self.navigationItem.rightBarButtonItem = saveButton
        }
    }
        
    // MARK: TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        var sectionCount = (review?.reviewType == nil) ? SectionCount.eSecondSection.rawValue : SectionCount.eThirdSection.rawValue
        if !isAddMedicationReview {
            sectionCount += 1
        }
        return sectionCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isAddMedicationReview {
            switch section {
            case eZerothSection.rawValue :
                return RowCount.eSecondRow.rawValue
            case eFirstSection.rawValue :
                if (self.review?.reviewType == nil ) {
                    return warningPeriodRowCountInSection(section)
                } else {
                    return reviewPeriodRowCountInSection(section)
                }
            case eSecondSection.rawValue :
                return warningPeriodRowCountInSection(section)
            default :
                break
            }
        } else {
            switch section {
            case eZerothSection.rawValue :
                return RowCount.eFirstRow.rawValue
            case eFirstSection.rawValue :
                return RowCount.eSecondRow.rawValue
            case eSecondSection.rawValue :
                if (self.review?.reviewType == nil ) {
                    return warningPeriodRowCountInSection(section)
                } else {
                    return reviewPeriodRowCountInSection(section)
                }
            case eThirdSection.rawValue :
                return warningPeriodRowCountInSection(section)
            default :
                break
            }
        }
        return RowCount.eZerothRow.rawValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if isAddMedicationReview {
            switch indexPath.section {
            case eZerothSection.rawValue :
                return self.reviewTypeSelectionCellAtIndexPath(indexPath)
            case eFirstSection.rawValue :
                return reviewTypeCellsAtIndexPath(indexPath)
            case eSecondSection.rawValue :
                return warningPeriodSectionAtIndexPath(indexPath)
                default :
                break
            }
        } else {
            switch indexPath.section {
            case eZerothSection.rawValue :
                return self.medicationDetailsCellAtIndexPath(indexPath)
            case eFirstSection.rawValue :
                return self.reviewTypeSelectionCellAtIndexPath(indexPath)
            case eSecondSection.rawValue :
                return reviewTypeCellsAtIndexPath(indexPath)
            case eThirdSection.rawValue :
                return warningPeriodSectionAtIndexPath(indexPath)
            default :
                break
            }
        }
        let reviewCell = self.reviewTypeSelectionCellAtIndexPath(indexPath)
        return reviewCell
      }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.view.endEditing(true)
        isValid = true
        if isAddMedicationReview {
            switch indexPath.section {
            case eZerothSection.rawValue :
                self.updateViewOnReviewTypeCellSelectionAtIndexPath(indexPath)
            case eFirstSection.rawValue :
                if review?.reviewType == nil {
                    // for warning unit
                    if (indexPath.row == RowCount.eSecondRow.rawValue) {
                        displayInlinePickerForRowAtIndexPath (indexPath)
                    }
                } else if (review?.reviewType == REVIEW_DUE_IN) {
                    if (indexPath.row == RowCount.eFirstRow.rawValue) {
                        displayInlinePickerForRowAtIndexPath (indexPath)
                    }
                } else {
                    displayInlinePickerForRowAtIndexPath (indexPath)
                }
            case eSecondSection.rawValue :
                // for warning unit
                if (indexPath.row == RowCount.eSecondRow.rawValue) {
                    displayInlinePickerForRowAtIndexPath (indexPath)
                }
                break
            default:
                break
            }
        } else {
            switch indexPath.section {
            case eFirstSection.rawValue :
                self.updateViewOnReviewTypeCellSelectionAtIndexPath(indexPath)
            case eSecondSection.rawValue :
                if review?.reviewType == nil {
                    // for warning unit
                    if (indexPath.row == RowCount.eSecondRow.rawValue) {
                        displayInlinePickerForRowAtIndexPath (indexPath)
                    }
                } else if (review?.reviewType == REVIEW_DUE_IN) {
                    if (indexPath.row == RowCount.eFirstRow.rawValue) {
                        displayInlinePickerForRowAtIndexPath (indexPath)
                    }
                } else {
                    displayInlinePickerForRowAtIndexPath (indexPath)
                }
            case eThirdSection.rawValue :
                // for warning unit
                if (indexPath.row == RowCount.eSecondRow.rawValue) {
                    displayInlinePickerForRowAtIndexPath (indexPath)
                }
                break
            default:
                break
            }
        }
        setSaveButtonDisability()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == eZerothSection.rawValue && !isAddMedicationReview {
            return UITableViewAutomaticDimension
        } else {
            return (indexPathHasPicker(indexPath)) ? PICKER_CELL_HEIGHT : TABLE_VIEW_ROW_HEIGHT

        }
    }
    
    //MARK: Row Count Helper Methods
    
    func reviewPeriodRowCountInSection (section : Int) -> Int {
        
        var rowCount = RowCount.eFirstRow.rawValue
        if (review?.reviewType == REVIEW_DUE_IN) {
            rowCount = RowCount.eSecondRow.rawValue
        }
        if (tableViewHasInlinePickerForSection(section)) {
            // increment row count if there is picker view displayed
            rowCount += 1
        }
        return rowCount
    }
    
    func warningPeriodRowCountInSection (section : Int) -> Int {
        
        var rowCount = RowCount.eFirstRow.rawValue
        if let warningPeriod = self.review?.warningPeriod?.hasWarningPeriod {
            if  warningPeriod {
                rowCount = RowCount.eThirdRow.rawValue
                if (tableViewHasInlinePickerForSection(section)) {
                    // increment row count if there is picker view displayed
                    rowCount += 1
                }
            } else {
                rowCount = RowCount.eFirstRow.rawValue
            }
        }
        return rowCount
    }
    
    // MARK: Warning Period Cells
    
    func warningsPeriodCellAtIndexPath(indexPath : NSIndexPath) -> DCSwitchCell {
        
        //configure slow bolus cell
        let warningPeriodCell = reviewTableView.dequeueReusableCellWithIdentifier(SLOW_BOLUS_CELL_ID) as? DCSwitchCell
        
        if let switchState = self.review?.warningPeriod?.hasWarningPeriod {
            warningPeriodCell?.cellSwitch.on = switchState
        }
        warningPeriodCell?.switchState = { state in
            let switchValue : Bool = state!
            self.isValid = true
            if self.review?.warningPeriod?.hasWarningPeriod == nil || switchValue == false {
                self.review?.warningPeriod = DCWarningPeriod.init()
                self.review?.warningPeriod?.warningPeriodUnit = EMPTY_STRING
                self.review?.warningPeriod?.warningPeriodInterval = EMPTY_STRING
            }
            self.review?.warningPeriod?.hasWarningPeriod = switchValue
            let sectionCount = self.reviewTableView.numberOfSections
            self.reviewTableView.beginUpdates()
            let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection:sectionCount-1),NSIndexPath(forItem: indexPath.row + 2, inSection: sectionCount-1)]
            if switchValue {
                self.reviewTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
            } else {
                self.reviewTableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
            }
            self.reviewTableView.endUpdates()
        }
        return warningPeriodCell!
    }
    
    func warningPeriodIntervalCellAtIndexPath (indexPath : NSIndexPath) -> DCAddNewValueTableViewCell {
        
        let newValueTableCell = reviewTableView.dequeueReusableCellWithIdentifier(VALUE_TEXTFIELD_CELL, forIndexPath: indexPath) as? DCAddNewValueTableViewCell
        if let warningPeriodInterval = review?.warningPeriod?.warningPeriodInterval {
            if warningPeriodInterval != EMPTY_STRING {
                newValueTableCell!.newValueTextField.text = warningPeriodInterval
            } else {
                newValueTableCell!.newValueTextField.text = warningPeriodInterval
                newValueTableCell!.newValueTextField.placeholder =  NSLocalizedString("PERIOD_BEFORE_REVIEW_DATE", comment: "placeholder text")
            }
        } else {
            newValueTableCell!.newValueTextField.placeholder =  NSLocalizedString("PERIOD_BEFORE_REVIEW_DATE", comment: "placeholder text")
        }
        if !isValid && (self.review?.warningPeriod.warningPeriodInterval == EMPTY_STRING || self.review?.warningPeriod.warningPeriodInterval == nil) {
            newValueTableCell!.newValueTextField.text =  NSLocalizedString("PERIOD_BEFORE_REVIEW_DATE", comment: "placeholder text")
            newValueTableCell?.newValueTextField.textColor = UIColor.redColor()
        }
        return newValueTableCell!
    }
    
    func warningPeriodUnitCellAtIndexPath (indexPath : NSIndexPath) -> DCAddNewValueTableViewCell {
        // interval unit
        let intervalTableCell = reviewTableView.dequeueReusableCellWithIdentifier(PICKER_DROP_DOWN_CELL, forIndexPath:indexPath) as? DCAddNewValueTableViewCell
        intervalTableCell!.unitLabel.text = DOSE_UNIT_TITLE
        intervalTableCell!.unitLabel.textColor = UIColor.blackColor()
        if var interval = review?.warningPeriod?.warningPeriodUnit {
            if (interval == EMPTY_STRING) {
                interval = HOURS_TITLE
                review?.warningPeriod?.warningPeriodUnit = interval
            }
            intervalTableCell!.unitValueLabel.text = interval
        }
        return intervalTableCell!
    }
    
    func warningPeriodUnitDatePickerCellAtIndexPath (indexPath : NSIndexPath) -> DCAddNewValuePickerCell {
        // interval unit types picker
        let pickerCell : DCAddNewValuePickerCell = (reviewTableView.dequeueReusableCellWithIdentifier(PICKER_CELL) as? DCAddNewValuePickerCell)!
        pickerCell.configurePickerCellWithValues([HOURS_TITLE, DAYS_TITLE])
        if let unit = self.review?.warningPeriod?.warningPeriodUnit {
            pickerCell.selectPickerViewForValue(unit)
        }
        pickerCell.pickerCompletion = { value in
            self.review?.warningPeriod?.warningPeriodUnit = value
            self.reviewTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row-1, inSection: indexPath.section)], withRowAnimation: .None)
        }
        return pickerCell
        
    }
    
    func reviewTypeCellsAtIndexPath (indexPath : NSIndexPath) -> UITableViewCell {
        
        if (review?.reviewType == nil) {
            return warningPeriodSectionAtIndexPath(indexPath)
        } else if (review?.reviewType == REVIEW_DUE_IN) {
            return self.reviewIntervalCellAtIndexPath(indexPath)!
        } else {
            //review date
            return self.reviewDateCellAtIndexPath(indexPath)!
        }
    }

    // MARK: Private Methods
    
    func warningPeriodSectionAtIndexPath (indexPath : NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case RowCount.eZerothRow.rawValue:
            return self.warningsPeriodCellAtIndexPath(indexPath)
        case RowCount.eFirstRow.rawValue:
            return warningPeriodIntervalCellAtIndexPath(indexPath)
        case RowCount.eSecondRow.rawValue:
            return warningPeriodUnitCellAtIndexPath(indexPath)
        default:
            return warningPeriodUnitDatePickerCellAtIndexPath(indexPath)
        }

    }
    func reviewTypeSelectionCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        //select review type
        let reviewCell = reviewTableView.dequeueReusableCellWithIdentifier(REVIEW_SELECTION_CELL_ID, forIndexPath: indexPath)
        reviewCell.textLabel?.font = UIFont.systemFontOfSize(15.0)
        if (indexPath.section == eZerothSection.rawValue || indexPath.section == eFirstSection.rawValue) {
            if indexPath.row == RowCount.eZerothRow.rawValue {
                reviewCell.textLabel?.text = REVIEW_DUE_IN
                reviewCell.accessoryType = (review?.reviewType == REVIEW_DUE_IN) ? .Checkmark : .None
            } else {
                reviewCell.textLabel?.text = REVIEW_DUE_AT
                reviewCell.accessoryType = (review?.reviewType == REVIEW_DUE_AT) ? .Checkmark : .None
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
        review?.reviewType = (indexPath.row == RowCount.eZerothRow.rawValue) ? REVIEW_DUE_IN : REVIEW_DUE_AT
        if (indexPath.row == RowCount.eZerothRow.rawValue) {
            let reviewIntervalCell = reviewTableView.cellForRowAtIndexPath(indexPath)
            reviewIntervalCell?.accessoryType = .Checkmark
            let reviewDateCell = reviewTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: indexPath.section))
            reviewDateCell?.accessoryType = .None
        } else {
            let reviewIntervalCell = reviewTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: indexPath.section))
            reviewIntervalCell?.accessoryType = .None
            let reviewDateCell = reviewTableView.cellForRowAtIndexPath(indexPath)
            reviewDateCell?.accessoryType = .Checkmark
        }
        let sectionCount = reviewTableView.numberOfSections
        reviewTableView.beginUpdates()
        let expectedSectionCount = (isAddMedicationReview == true) ? 2 : 3
        if (sectionCount == expectedSectionCount) {
            reviewTableView.insertSections(NSIndexSet(index: expectedSectionCount-1), withRowAnimation: .Middle)
        } else {
            reviewTableView.reloadSections(NSIndexSet(index: expectedSectionCount-1), withRowAnimation: .Middle)
        }
        reviewTableView.endUpdates()
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
                if !isValid && (self.review?.reviewInterval.intervalCount == EMPTY_STRING || self.review?.reviewInterval.intervalCount == nil) {
                    newValueTableCell!.newValueTextField.text =  NSLocalizedString("IN", comment: "in placeholder text")
                    newValueTableCell?.newValueTextField.textColor = UIColor.redColor()
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
                    self.reviewTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: RowCount.eFirstRow.rawValue, inSection: indexPath.section)], withRowAnimation: .None)
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
            if !isValid && (self.review?.reviewDate.dateAndTime == EMPTY_STRING || self.review?.reviewDate.dateAndTime == nil) {
                newValueTableCell!.unitLabel.textColor = UIColor.redColor()
            } else {
                newValueTableCell!.unitLabel.textColor = UIColor.blackColor()
            }
            return newValueTableCell!
        } else {
            // date pickercell
            let datePickerCell : DCDatePickerCell? = reviewTableView.dequeueReusableCellWithIdentifier(DATE_PICKER_CELL_IDENTIFIER) as?DCDatePickerCell
            datePickerCell?.datePicker?.minimumDate = NSDate()
            if let reviewDate = review?.reviewDate?.dateAndTime {
                datePickerCell?.datePicker?.date = DCDateUtility.dateFromSourceString(reviewDate)
            } else {
                self.performSelector(#selector(DCReviewViewController.reloadReviewDateTableCellForDateValue(_:)), withObject: NSDate(), afterDelay: 0.02)
            }
            datePickerCell?.selectedDate = { date in
                self.reloadReviewDateTableCellForDateValue(date)
            }
            return datePickerCell!
        }
    }
    
    func updateReviewIntervalCountValue() {
        
        //update the interval count value
        let sectionCount = isAddMedicationReview ? 1:2
        let intervalCell = reviewTableView.cellForRowAtIndexPath(NSIndexPath(forItem: RowCount.eZerothRow.rawValue, inSection: sectionCount)) as? DCAddNewValueTableViewCell
        if (intervalCell?.newValueTextField?.text) != nil {
            review?.reviewInterval?.intervalCount = intervalCell?.newValueTextField?.text
        }
    }
    
    func updateWarningPeriodIntervalCountValue() {
        
        //update the interval count value
        let sectionCount = reviewTableView.numberOfSections - 1
        let intervalCell = reviewTableView.cellForRowAtIndexPath(NSIndexPath(forItem: RowCount.eFirstRow.rawValue, inSection: sectionCount)) as? DCAddNewValueTableViewCell
        if (intervalCell?.newValueTextField?.text) != nil {
            review?.warningPeriod?.warningPeriodInterval = intervalCell?.newValueTextField?.text
        }
    }
    
    //Medication Details Cell
    func medicationDetailsCellAtIndexPath (indexPath :NSIndexPath) -> UITableViewCell {
        
        if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationDetails!){
            let cell = self.reviewTableView.dequeueReusableCellWithIdentifier(StopMedicationConstants.DURATION_BASED_INFUSION_CELL) as? DCDurationBasedMedicationDetailsCell
            cell!.configureMedicationDetails(medicationDetails!)
            return cell!
        } else {
            let cell = self.reviewTableView.dequeueReusableCellWithIdentifier(StopMedicationConstants.MEDICATION_DETAILS_CELL) as? DCMedicationDetailsTableViewCell
            cell!.configureMedicationDetails(medicationDetails!)
            return cell!
        }
    }
    
    func reloadReviewDateTableCellForDateValue(date : NSDate) {
        
        let sectionCount = isAddMedicationReview ? 1:2
        let dateString = DCDateUtility.dateStringFromDate(date, inFormat: START_DATE_FORMAT)
        self.review?.reviewDate?.dateAndTime = dateString
        reviewTableView.beginUpdates()
        reviewTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: sectionCount) ], withRowAnimation: .Fade)
        reviewTableView.endUpdates()
    }
    
    //MARK: Date Picker Methods
    
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
            scrollToDatePickerAtIndexPath(indexPath)
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
    
    func scrollToDatePickerAtIndexPath(indexPath :NSIndexPath) {
        //scroll to date picker indexpath when when any of the date field is selected
        //        if (indexPath.row != (datePickerIndexPath?.row)!-1) {
        let scrollToIndexPath : NSIndexPath = NSIndexPath(forRow:indexPath.row + 1 , inSection:indexPath.section)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.reviewTableView.scrollToRowAtIndexPath(scrollToIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        })
        //        }
    }
    
    func closeInlinePickers () {
        
        if let pickerIndexPath = inlinePickerIndexPath {
            let previousPickerIndexPath = NSIndexPath(forItem: pickerIndexPath.row - 1, inSection: pickerIndexPath.section)
            self.displayInlinePickerForRowAtIndexPath(previousPickerIndexPath)
        }
    }
    
    func isReviewValid () {
        isValid = true
        if (self.review?.reviewType) != nil {
            if self.review?.reviewType == REVIEW_DUE_IN {
                if self.review?.reviewInterval.intervalCount == EMPTY_STRING || self.review?.reviewInterval.intervalCount == nil {
                    isValid = false
                }
            } else {
                if self.review?.reviewDate.dateAndTime == EMPTY_STRING || self.review?.reviewDate.dateAndTime == nil {
                    isValid = false
                }
            }
        } else {
            isValid = false
        }
        if self.review?.warningPeriod?.hasWarningPeriod == true {
            if self.review?.warningPeriod.warningPeriodInterval == EMPTY_STRING || self.review?.warningPeriod.warningPeriodInterval == nil {
                isValid = false
            }
        }
    }
    
    func setSaveButtonDisability () {
        
        if self.review?.reviewType == nil  {
            saveButton?.enabled = false
        } else {
            saveButton?.enabled = true
        }
    }
    
    //MARK: Bar Button Item Action Methods 
    func cancelButtonPressed () {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveButtonPressed () {
        
        self.updateReviewIntervalCountValue()
        self.updateWarningPeriodIntervalCountValue()
        self.isReviewValid()
        if isValid {
            //TODO: To implement the API
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.reviewTableView.reloadData()
        }
    }
    
    // MARK: Notification Methods
    func keyboardDidShow(notification : NSNotification) {
        
        closeInlinePickers()
        if !isAddMedicationReview {
            if let userInfo = notification.userInfo {
                if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                    let contentInsets: UIEdgeInsets
                    contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0)
                    self.reviewTableView.contentInset = contentInsets;
                    self.reviewTableView.scrollIndicatorInsets = contentInsets;
                    let lastIndexPath = NSIndexPath(forRow: 0, inSection: reviewTableView.numberOfSections-1 )
                    self.reviewTableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .Bottom, animated: true)
                }
            }
        }
    }
    
    func keyboardDidHide(notification :NSNotification){
        
        if !isAddMedicationReview {
            let contentInsets:UIEdgeInsets  = UIEdgeInsetsMake(40, 0, 0, 0);
            reviewTableView.contentInset = contentInsets;
            reviewTableView.scrollIndicatorInsets = contentInsets;
            reviewTableView.beginUpdates()
            reviewTableView.endUpdates()
        }
    }
}
