//
//  DCReviewViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/21/16.
//
//

import UIKit

class DCReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var reviewTableView: UITableView!
    
    var review : DCMedicationReview?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (review?.reviewType == nil) {
            return SectionCount.eSecondSection.rawValue
        } else {
            return SectionCount.eThirdSection.rawValue
        }
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
                return rowCount
            case eSecondSection.rawValue :
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
                    switch indexPath.row {
                        case RowCount.eZerothRow.rawValue :
                            let newValueTableCell = tableView.dequeueReusableCellWithIdentifier(VALUE_TEXTFIELD_CELL, forIndexPath: indexPath) as? DCAddNewValueTableViewCell
                             if let reviewInterval = review?.reviewInterval {
                                if let intervalCount = reviewInterval.intervalCount {
                                    newValueTableCell!.newValueTextField.placeholder = intervalCount
                                } else {
                                    newValueTableCell!.newValueTextField.placeholder =  "In"
                                }
                            }
                            return newValueTableCell!
                        case RowCount.eFirstRow.rawValue :
                            let newValueTableCell = tableView.dequeueReusableCellWithIdentifier(PICKER_DROP_DOWN_CELL, forIndexPath: indexPath) as? DCAddNewValueTableViewCell
                            newValueTableCell!.unitLabel.text = "Unit"
                            if let reviewInterval = review?.reviewInterval {
                                newValueTableCell!.unitValueLabel.text = (reviewInterval.unit == nil) ? EMPTY_STRING : reviewInterval.unit
                            }
                            return newValueTableCell!
                        case RowCount.eSecondRow.rawValue :
                            let newValueTableCell : DCAddNewValuePickerCell = (tableView.dequeueReusableCellWithIdentifier(PICKER_CELL) as? DCAddNewValuePickerCell)!
                            newValueTableCell.configurePickerCellWithValues(["Day","Week","Month"])
                            newValueTableCell.pickerCompletion = { value in
                                // self.valueForUnit = value!
                                //self.mainTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
                            }
                        default:
                            break
                        }
                } else {
                    //review date
                    if (indexPath.row == RowCount.eZerothRow.rawValue) {
                        let newValueTableCell = tableView.dequeueReusableCellWithIdentifier(PICKER_DROP_DOWN_CELL, forIndexPath: indexPath) as? DCAddNewValueTableViewCell
                        newValueTableCell!.unitLabel.text = DATE
                        if let reviewDate = review?.reviewDate {
                            newValueTableCell!.unitValueLabel.text = (reviewDate.dateAndTime == nil) ? EMPTY_STRING : reviewDate.dateAndTime
                        }
                        return newValueTableCell!
                    } else {
                        let datePickerCell : DCAddNewDoseAndTimeTableViewCell? = tableView.dequeueReusableCellWithIdentifier(ADD_NEW_TIME_CELL_ID) as?DCAddNewDoseAndTimeTableViewCell
                        return datePickerCell!
                    }
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
        
        switch indexPath.section {
            case eZerothSection.rawValue :
                review?.reviewType = (indexPath.row == RowCount.eZerothRow.rawValue) ? REVIEW_INTERVAL : REVIEW_DATE
                if review?.reviewType == nil {
                    review?.reviewInterval = DCReviewInterval.init()
                    review?.reviewDate = DCReviewDate.init()
                }
                if (indexPath.row == RowCount.eZerothRow.rawValue) {
                    let reviewIntervalCell = tableView.cellForRowAtIndexPath(indexPath)
                    reviewIntervalCell?.accessoryType = .Checkmark
                    let reviewDateCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
                    reviewDateCell?.accessoryType = .None
                } else {
                    let reviewIntervalCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                    reviewIntervalCell?.accessoryType = .None
                    let reviewDateCell = tableView.cellForRowAtIndexPath(indexPath)
                    reviewDateCell?.accessoryType = .Checkmark
                }
                let sectionCount = tableView.numberOfSections
                tableView.beginUpdates()
                tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
                if (sectionCount == 2) {
                    tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
                } else {
                    tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
                }
                tableView.endUpdates()
            case eFirstSection.rawValue :
                if review?.reviewType == nil {
                    self.displayWarningPeriodView()
                }
            case eSecondSection.rawValue :
                self.displayWarningPeriodView()
            default:
                break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Private Methods
    
    func reviewTypeSelectionCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
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
    
    func displayWarningPeriodView () {
        
        //show warnings period view
        
        let addMedicationStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let addNewValueViewController = addMedicationStoryboard.instantiateViewControllerWithIdentifier(ADD_NEW_VALUE_SBID) as? DCAddNewValueViewController
        addNewValueViewController!.titleString = NSLocalizedString("WARNING_PERIOD", comment: "warning period cell text")
        addNewValueViewController!.placeHolderString = NSLocalizedString("BEGINS", comment: "warning period begins placeholder")
        addNewValueViewController!.backButtonTitle = self.title!
        addNewValueViewController!.detailType = eAddValueWithUnit
        addNewValueViewController!.unitArray = [DAY, HOUR]
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
            warningCell!.unitValueLabel.text = warningPeriod
        } else {
            warningCell!.unitValueLabel.text = EMPTY_STRING
        }
        warningCell!.accessoryType = .DisclosureIndicator
        return warningCell!
    }

}
