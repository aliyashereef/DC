//
//  DCDosageSelectionViewController.swift
//  DrugChart
//
//  Created by Shaheer on 09/12/15.
//
//

import UIKit

var maximumValueOfDose : Float = 10000

// protocol used for sending data back
@objc public protocol NewDosageValueEntered: class {
    
    func newDosageAdded(dosage : DCDosage)
}

typealias SelectedDosage = DCDosage? -> Void

@objc class DCDosageSelectionViewController: DCBaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DataEnteredDelegate {
    
    var dosageMenuItems = [String]()
    var menuType : DosageSelectionType = eDosageMenu
    var dosage : DCDosage?
    var selectedDetailType : DosageDetailType = eDoseValue
    var selectedTimeArrayItems = [String]()
    var valueForDoseForTime = [String]()
    var isRowAlreadySelected : Bool = false
    var selectedIndexPathInTimeArray : Int = 0
    var previousIndexPath = NSIndexPath(forRow: 5, inSection: 0)
    var dosageArray = [String]()
    var doseValueFromAPI : String = ""
    var valueStringForRequiredDailyDose : NSString = ""
    var valueForRequiredDailyDose : Float = 0
    var totalValueForDose : Float = 0
    var alertMessageForMismatch :NSString = ""
    @IBOutlet weak var dosageTableView: UITableView!
    weak var newDosageAddedDelegate: NewDosageValueEntered? = nil
    var selectedDosage : SelectedDosage = {value in }
    var isSplitDailyPresent : Bool = false
    var isReducingIncreasingPresent : Bool = false
    var doseForTimeArray = ["250","100","50","30","20","10"]
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureInitialValues()
        self.configureNavigationBarItems()
        if (dosage?.splitDailyDose.timeArray != nil) {
            self.configureTimeArray()
        }
        if dosageArray.count != 0 {
            doseValueFromAPI = dosageArray[0]
        }
        dosageTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    }
    
    override func viewDidAppear(animated: Bool) {
        
        dosageTableView.reloadData()
        if menuType == eSplitDaily {
            updateAlertMessageForMismatch()
            dosageTableView.reloadData()
            dosageTableView.beginUpdates()
            dosageTableView.endUpdates()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        newDosageAddedDelegate?.newDosageAdded(self.dosage!)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - View Configuration and Value Initializations
    
    func configureInitialValues (){
        
        if dosage?.type == nil {
            //Initialise dosage model object.
            self.dosage?.fixedDose = DCFixedDose.init()
            self.dosage?.variableDose = DCVariableDose.init()
            self.dosage?.reducingIncreasingDose = DCReducingIncreasingDose.init()
            self.dosage?.reducingIncreasingDose.conditions = DCConditions.init()
            if self.dosage?.splitDailyDose == nil {
                self.dosage?.splitDailyDose = DCSplitDailyDose.init()
            }
            if self.dosage?.singleDose == nil {
                self.dosage?.singleDose = DCSingleDose.init()
            }
            if (dosageArray.count != 0) {
                self.dosage?.fixedDose?.doseValue = dosageArray[0]
                self.dosage?.variableDose?.doseFromValue = dosageArray[0]
                self.dosage?.variableDose?.doseToValue = dosageArray[0]
                self.dosage?.reducingIncreasingDose?.startingDose = dosageArray[0]
            } else {
                self.dosage?.fixedDose?.doseValue = EMPTY_STRING
                self.dosage?.variableDose?.doseFromValue = EMPTY_STRING
                self.dosage?.variableDose?.doseToValue = EMPTY_STRING
                self.dosage?.reducingIncreasingDose?.startingDose = EMPTY_STRING
            }
            self.dosage?.doseUnit = "mg"
            self.dosage?.reducingIncreasingDose?.changeOver = "Days"
            self.dosage?.reducingIncreasingDose?.conditions?.conditionDescription = ""
        } else {
            //If already selected, Show the selected values.
            switch (self.dosage?.type)! {
            case DOSE_FIXED:
                menuType = eFixedDosage
                previousIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            case DOSE_VARIABLE:
                menuType = eVariableDosage
                previousIndexPath = NSIndexPath(forRow: 1, inSection: 0)
            case DOSE_REDUCING_INCREASING:
                menuType = eReducingIncreasing
                previousIndexPath = NSIndexPath(forRow: 2, inSection: 0)
            case DOSE_SPLIT_DAILY:
                previousIndexPath = NSIndexPath(forRow: 3, inSection: 0)
                menuType = eSplitDaily
            default:
                menuType = eDosageMenu
            }
        }
        dosageMenuItems = []
        dosageMenuItems.append(DOSE_FIXED)
        dosageMenuItems.append(DOSE_VARIABLE)
        if isReducingIncreasingPresent {
            dosageMenuItems.append(DOSE_REDUCING_INCREASING)
        } else if (menuType == eReducingIncreasing) {
            menuType = eDosageMenu
        }
        if isSplitDailyPresent {
            dosageMenuItems.append(DOSE_SPLIT_DAILY)
        } else if (menuType == eSplitDaily) {
            menuType = eDosageMenu
        }
    }
    
    func configureTimeArray () {
        
        //Clear the time array.
        selectedTimeArrayItems = []
        valueForDoseForTime = []
        //Extract the selected times and update time array and dose array.
        let predicate = NSPredicate(format: "selected == 1")
        let filteredArray = dosage?.splitDailyDose.timeArray.filteredArrayUsingPredicate(predicate)
        if (filteredArray!.count != 0) {
            for timeDictionary in filteredArray! {
                let time = timeDictionary["time"]
                selectedTimeArrayItems.append((time as? String)!)
                if let val = timeDictionary["dose"] {
                    if let x = val {
                        //Value is present for the key "dose".
                        valueForDoseForTime.append(x as! String)
                    } else {
                        //Value is nil for the key "dose".
                        valueForDoseForTime.append("")
                    }
                } else {
                    //key "dose" is not present in dict
                    valueForDoseForTime.append("")
                }
            }
        }
    }
    
    func configureNavigationBarItems() {
        
        self.navigationItem.title = DOSE_VALUE_TITLE
        self.title = DOSE_VALUE_TITLE
    }
    
    func configureNavigationBackButtonTitle () {
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: self.title, style: .Plain, target: nil, action: nil)
    }
    
    // MARK: - TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (menuType == eDosageMenu) {
            return 2
        } else if (menuType == eSplitDaily) {
            if (selectedTimeArrayItems.count > 0) {
                return 5
            } else {
                return 4
            }
        } else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return dosageMenuItems.count
        } else if (section == 1) {
            switch(menuType.rawValue) {
                case eDosageMenu.rawValue:
                    return 1
                case eFixedDosage.rawValue:
                    return 2
                case eSplitDaily.rawValue:
                    return 2
                case eVariableDosage.rawValue:
                    return 3
                case eReducingIncreasing.rawValue:
                    return 4
                default:
                    break
            }
        } else if (section == 2) {
            if (menuType == eSplitDaily) {
                if (selectedTimeArrayItems.count > 0) {
                    return selectedTimeArrayItems.count
                } else {
                    return 1
                }
            } else {
                return 1
            }
        } else if (section == 3) {
            if (menuType == eSplitDaily) {
                if (selectedTimeArrayItems.count > 0) {
                    return 1
                }
            }
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 44
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //Set the alert for mismatch of Required daily dose.
        if (section == 2 && dosage?.splitDailyDose.timeArray != nil && alertMessageForMismatch != "" && menuType == eSplitDaily) {
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 2 && dosage?.splitDailyDose.timeArray != nil && alertMessageForMismatch != "" && menuType == eSplitDaily) {
            return 44.0
        } else {
            return 0.0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let dosageSelectionMenuCell : DCDosageSelectionTableViewCell? = dosageTableView.dequeueReusableCellWithIdentifier(DOSE_MENU_CELL_ID) as? DCDosageSelectionTableViewCell
            // Configure the cell...
            dosageSelectionMenuCell!.dosageMenuLabel.text = dosageMenuItems[indexPath.row]
            dosageSelectionMenuCell?.dosageMenuLabel.textColor = UIColor.blackColor()
            if (indexPath == previousIndexPath) {
                dosageSelectionMenuCell?.accessoryType = .Checkmark
            } else {
                dosageSelectionMenuCell?.accessoryType = .None
            }
            return dosageSelectionMenuCell!
        } else {
            if (indexPath.section == 2 && selectedTimeArrayItems.count != 0 && menuType == eSplitDaily) {
                let timeDisplayCell : DCSelectedTimeTableViewCell
                timeDisplayCell = (dosageTableView.dequeueReusableCellWithIdentifier(SELECTED_TIME_DISPLAY_CELL_ID) as? DCSelectedTimeTableViewCell)!
                timeDisplayCell.timeLabel.text = selectedTimeArrayItems[indexPath.row]
                timeDisplayCell.doseValueLabel.text = valueForDoseForTime[indexPath.row]
                return timeDisplayCell
            } else {
                let cellForDisplay : DCDosageSelectionTableViewCell = self.configureTableCellForDisplay(indexPath)
                return cellForDisplay
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0) {
            configureDosageTableViewOnDosageTypeSelectionAtIndexPath(indexPath)
        } else {
            self.displayDosageDetailViewControllerWithSelectedDetailType(indexPath)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        // Return YES to set the specified time list to be editable.
        if indexPath.section == 2 && dosage?.splitDailyDose.timeArray != nil && selectedTimeArrayItems.count != 0 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
        }
    }
    
    func tableView(tableView: UITableView,
        editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
            let delete = UITableViewRowAction(style: .Destructive, title: "Delete") { action, index in
                //Delete element from array.
                self.deleteElementFromTimeArrayAtSelectedIndexPath(indexPath.row)
                //Update the arrays.
                self.configureTimeArray()
                //Update alert messages.
                self.updateAlertMessageForMismatch()
                self.dosageTableView.beginUpdates()
                //Update the table.
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                if (self.selectedTimeArrayItems.count == 0) {
                    let sections = NSIndexSet(index: 2)
                    tableView.deleteSections(sections, withRowAnimation: .Fade)
                }
                self.dosageTableView.endUpdates()
                
            }
            let attributes = [NSFontAttributeName : UIFont.systemFontOfSize(15.0)]
            let attributedString = NSMutableAttributedString(string:"Delete", attributes:attributes)
            UIButton.dc_appearanceWhenContainedIn(DCSelectedTimeTableViewCell.classForCoder()).setAttributedTitle(attributedString, forState: .Normal)
            return [delete]
    }
    
    // MARK: - Private Methods
    
    func configureDosageTableViewOnDosageTypeSelectionAtIndexPath(indexPath : NSIndexPath) {
        
        //dosage type selection
        previousIndexPath = indexPath
        dosageTableView.reloadData()
        self.checkWhetherRowAlreadySelected(indexPath)
        var range = NSMakeRange(3, 2)
        if (selectedTimeArrayItems.count == 0) {
            range = NSMakeRange(3, 1)
        }
        if (isRowAlreadySelected == true){
            //if row already selected, deselect the row and delete the dropdown.
            menuType = eDosageMenu
            isRowAlreadySelected = false
            dosageTableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
            //if selected type is splitdaily, delete 3 sections. else delete only one section.
            let sectionCount = dosageTableView.numberOfSections
            dosageTableView.beginUpdates()
            dosageTableView.deleteSections(NSIndexSet(indexesInRange: NSMakeRange(1, sectionCount - 1)), withRowAnimation: .Fade)
            dosageTableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
            dosageTableView.endUpdates()
        } else {
            let sectionCount = dosageTableView.numberOfSections
            if (indexPath.row != 3) {
                dosageTableView.beginUpdates()
                if (sectionCount == 2) {
                    //if section count is initial count, insert new section with animation
                    dosageTableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                    dosageTableView.insertSections(NSIndexSet(indexesInRange: NSMakeRange(1, 2)), withRowAnimation: .Fade)
                } else if (sectionCount >= 4) {
                    //Delete 3 sections od splitdaily and insert the new section.
                    dosageTableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(1, 2)), withRowAnimation: .Fade)
                    dosageTableView.deleteSections(NSIndexSet(index: 3), withRowAnimation: .Fade)
                    if (selectedTimeArrayItems.count > 0) {
                        dosageTableView.deleteSections(NSIndexSet(index: 4), withRowAnimation: .Fade)
                    }
                } else {
                    //reload sections
                    dosageTableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(1, 2)), withRowAnimation: .Fade)
                }
                dosageTableView.endUpdates()
            } else {
                //Splitdaily selected. insert 3 sections if a new selection, else delete the existing one section and insert the new sections.
                dosageTableView.beginUpdates()
                if (sectionCount == 2) {
                    if (selectedTimeArrayItems.count == 0) {
                        range = NSMakeRange(1, 3)
                    } else {
                        range = NSMakeRange(1, 4)
                    }
                    dosageTableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                    dosageTableView.insertSections(NSIndexSet(indexesInRange: range), withRowAnimation: .Fade)
                } else {
                    if (selectedTimeArrayItems.count == 0) {
                        range = NSMakeRange(1, 3)
                    } else {
                        range = NSMakeRange(1, 4)
                    }
                    dosageTableView.deleteSections(NSIndexSet(indexesInRange: NSMakeRange(1, sectionCount - 1)), withRowAnimation: .Fade)
                    dosageTableView.insertSections(NSIndexSet(indexesInRange: range), withRowAnimation: .Fade)
                }
                dosageTableView.endUpdates()
            }
        }
    }
    
    func checkWhetherRowAlreadySelected (indexPath : NSIndexPath) {
        
        switch (indexPath.row) {
            
        case 0:
            if (menuType == eFixedDosage){
                isRowAlreadySelected = true
            }else {
                self.dosage?.type = DOSE_FIXED
                menuType = eFixedDosage
            }
        case 1:
            if (menuType == eVariableDosage){
                isRowAlreadySelected = true
            }else {
                self.dosage?.type = DOSE_VARIABLE
                menuType = eVariableDosage
            }
        case 2:
            if (menuType == eReducingIncreasing){
                isRowAlreadySelected = true
            }else {
                self.dosage?.type = DOSE_REDUCING_INCREASING
                menuType = eReducingIncreasing
            }
        case 3:
            if (menuType == eSplitDaily){
                isRowAlreadySelected = true
            }else {
                self.dosage?.type = DOSE_SPLIT_DAILY
                menuType = eSplitDaily
            }
        default:
            break
        }
    }
    
    func configureTableCellForDisplay (indexPath : NSIndexPath) -> DCDosageSelectionTableViewCell {
        
        //Deque the cell to dosageSelectionDetailCell.
        var dosageSelectionDetailCell : DCDosageSelectionTableViewCell
        if (menuType != eSplitDaily) {
            dosageSelectionDetailCell = (dosageTableView.dequeueReusableCellWithIdentifier(DOSE_DROP_DOWN_CELL_ID) as? DCDosageSelectionTableViewCell)!
        } else {
            if (indexPath.section == 1) {
                if (indexPath.row == 0) {
                    dosageSelectionDetailCell = (dosageTableView.dequeueReusableCellWithIdentifier(DOSE_DROP_DOWN_CELL_ID) as? DCDosageSelectionTableViewCell)!
                } else {
                    dosageSelectionDetailCell = (dosageTableView.dequeueReusableCellWithIdentifier(REQUIRED_DAILY_DOSE_CELL_ID) as? DCDosageSelectionTableViewCell)!
                    dosageSelectionDetailCell.requiredDailyDoseTextField.text = self.dosage?.splitDailyDose.dailyDose
                    dosageSelectionDetailCell.requiredDailyDoseTextField.delegate = self
                }
            } else if (indexPath.section == 2) {
                if (selectedTimeArrayItems.count != 0) {
                    dosageSelectionDetailCell = (dosageTableView.dequeueReusableCellWithIdentifier(DOSE_DROP_DOWN_CELL_ID) as? DCDosageSelectionTableViewCell)!
                } else {
                    dosageSelectionDetailCell = (dosageTableView.dequeueReusableCellWithIdentifier(DOSE_MENU_CELL_ID) as? DCDosageSelectionTableViewCell)!
                }
            } else {
                dosageSelectionDetailCell = (dosageTableView.dequeueReusableCellWithIdentifier(DOSE_DROP_DOWN_CELL_ID) as? DCDosageSelectionTableViewCell)!
            }
        }
        dosageSelectionDetailCell = populatedDosageTableCell(dosageSelectionDetailCell, atIndexPath: indexPath) as! DCDosageSelectionTableViewCell
        return dosageSelectionDetailCell
    }
    
    func populatedDosageTableCell(var dosageSelectionDetailCell : DCDosageSelectionTableViewCell, atIndexPath indexPath : NSIndexPath) -> UITableViewCell {
        
        //Configure the cell.
        switch (menuType.rawValue) {
        case eDosageMenu.rawValue:
            if (indexPath.row == 0) {
                dosageSelectionDetailCell = populatedSingleDoseCell(dosageSelectionDetailCell, atIndexPath: indexPath)
            }
        case eFixedDosage.rawValue:
            if (indexPath.section == 1) {
                if(indexPath.row == 0) {
                    dosageSelectionDetailCell.configureCell(DOSE_UNIT_LABEL_TEXT, selectedValue: (dosage?.doseUnit)!)
                } else {
                    dosageSelectionDetailCell.configureCell(DOSE_VALUE_TITLE, selectedValue: (self.dosage?.fixedDose.doseValue)!)
                }
            } else {
                if (indexPath.row == 0) {
                    dosageSelectionDetailCell = populatedSingleDoseCell(dosageSelectionDetailCell, atIndexPath: indexPath)
                }
            }
        case eVariableDosage.rawValue:
            if (indexPath.section == 1) {
                if(indexPath.row == 0) {
                    dosageSelectionDetailCell.configureCell(DOSE_UNIT_LABEL_TEXT, selectedValue: (dosage?.doseUnit)!)
                } else if (indexPath.row == 1) {
                    dosageSelectionDetailCell.configureCell(DOSE_FROM_TITLE, selectedValue: (self.dosage?.variableDose.doseFromValue)!)
                } else {
                    dosageSelectionDetailCell.configureCell(DOSE_TO_TITLE, selectedValue: (self.dosage?.variableDose.doseToValue)!)
                }
            } else {
                if (indexPath.row == 0) {
                    dosageSelectionDetailCell = populatedSingleDoseCell(dosageSelectionDetailCell, atIndexPath: indexPath)
                }
            }
        case eReducingIncreasing.rawValue:
            if (indexPath.section == 1) {
                if(indexPath.row == 0) {
                    dosageSelectionDetailCell.configureCell(DOSE_UNIT_LABEL_TEXT, selectedValue: (dosage?.doseUnit)! as String)
                } else if (indexPath.row == 1) {
                    dosageSelectionDetailCell.configureCell(STARTING_DOSE_TITLE, selectedValue: (self.dosage?.reducingIncreasingDose.startingDose)!)
                } else if(indexPath.row == 2){
                    dosageSelectionDetailCell.configureCell(CHANGE_OVER_TITLE, selectedValue: (self.dosage?.reducingIncreasingDose.changeOver)!)
                } else {
                    if (self.dosage?.reducingIncreasingDose?.conditionsArray != nil) {
                        if self.dosage?.reducingIncreasingDose?.conditionsArray.count > 0 {
                            if self.dosage?.isConditionsValid == false {
                                dosageSelectionDetailCell.configureCellForErrorCondition(CONDITIONS_TITLE, selectedValue: DCDosageHelper.createDescriptionStringForDosageCondition((self.dosage?.reducingIncreasingDose.conditionsArray[0])! as! DCConditions, dosageUnit: (self.dosage?.doseUnit)!))
                            } else {
                                dosageSelectionDetailCell.configureCell(CONDITIONS_TITLE, selectedValue: DCDosageHelper.createDescriptionStringForDosageCondition((self.dosage?.reducingIncreasingDose.conditionsArray[0])! as! DCConditions, dosageUnit: (self.dosage?.doseUnit)!))
                            }
                        } else {
                            dosageSelectionDetailCell.configureCell(CONDITIONS_TITLE, selectedValue: "")
                        }
                    } else {
                        dosageSelectionDetailCell.configureCell(CONDITIONS_TITLE, selectedValue: "")
                    }
                }
            } else {
                if (indexPath.row == 0) {
                    dosageSelectionDetailCell = populatedSingleDoseCell(dosageSelectionDetailCell, atIndexPath: indexPath)
                }
            }
        case eSplitDaily.rawValue:
            if (indexPath.section == 1) {
                if(indexPath.row == 0){
                    dosageSelectionDetailCell.configureCell(DOSE_UNIT_LABEL_TEXT, selectedValue: (dosage?.doseUnit)! as String)
                }
            } else if (indexPath.section == 2) {
                if (selectedTimeArrayItems.count > 0) {
                    dosageSelectionDetailCell.configureCell(selectedTimeArrayItems[indexPath.row], selectedValue: valueForDoseForTime[indexPath.row])
                } else {
                    dosageSelectionDetailCell.dosageMenuLabel.text = ADD_ADMINISTRATION_TIME
                    dosageSelectionDetailCell.accessoryType = .None
                    dosageSelectionDetailCell.dosageMenuLabel.textColor = dosageTableView.tintColor
                }
            } else if (indexPath.section == 3) {
                if (selectedTimeArrayItems.count > 0) {
                    dosageSelectionDetailCell.dosageMenuLabel.text = ADD_ADMINISTRATION_TIME
                    dosageSelectionDetailCell.dosageDetailValueLabel.text = EMPTY_STRING
                    dosageSelectionDetailCell.accessoryType = .None
                    dosageSelectionDetailCell.dosageMenuLabel.textColor = dosageTableView.tintColor
                } else {
                    if (indexPath.row == 0) {
                        dosageSelectionDetailCell = populatedSingleDoseCell(dosageSelectionDetailCell, atIndexPath: indexPath)
                    }
                }
            }
            else {
                if (indexPath.row == 0) {
                    dosageSelectionDetailCell = populatedSingleDoseCell(dosageSelectionDetailCell, atIndexPath: indexPath)
                }
            }
        default:
            break
        }
        return dosageSelectionDetailCell
    }
    
    func displayDosageDetailViewControllerWithSelectedDetailType(indexPath : NSIndexPath ) {
        
        if (indexPath.section == 1) {
            switch (indexPath.row) {
                case 0:
                    if (menuType == eDosageMenu) {
                        self.transitToSingleDoseViewController()
                    } else {
                        self.transitToDosageUnitSelectionViewController()
                    }
                case 1:
                    if (menuType == eFixedDosage) {
                        self.transitToFixedDoseValueScreen()
                    } else if (menuType == eVariableDosage) {
                        self.transitToVariableDoseFromValueScreen()
                    } else if (menuType == eReducingIncreasing) {
                        self.transitToReducingIncreasingStartingDoseValueScreen()
                    } else {
                        return
                    }
                case 2:
                    if (menuType == eVariableDosage) {
                        self.transitToVariableDoseToValueScreen()
                    } else if (menuType == eReducingIncreasing) {
                        self.transitToConditionsChangeOverScreen()
                    }
                case 3:
                    if (menuType == eReducingIncreasing) {
                        if (self.dosage?.reducingIncreasingDose.startingDose == EMPTY_STRING) {
                            let dosageCell: DCDosageSelectionTableViewCell = dosageTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as! DCDosageSelectionTableViewCell
                            dosageCell.dosageDetailLabel!.textColor = UIColor.redColor()
                        } else {
                            let dosageConditionsViewController : DCDosageConditionsViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(DOSAGE_CONDITIONS_SBID) as? DCDosageConditionsViewController
                            dosageConditionsViewController?.reducingIncreasingDoseEntered = { value in
                                self.dosage?.reducingIncreasingDose = value 
                            }
                            dosageConditionsViewController?.dosage = self.dosage
                            self.configureNavigationBackButtonTitle()
                            self.navigationController?.pushViewController(dosageConditionsViewController!, animated: true)
                        }
                        return
                    }
                default:
                    break
                }
        } else if (indexPath.section == 2) {
            if (menuType == eSplitDaily) {
                if (selectedTimeArrayItems.count != 0) {
                    self.transitToAddDoseForTimeScreen(indexPath)
                } else {
                    self.transitToAddNewTimeScreen()
                }
            } else {
                self.transitToSingleDoseViewController()
            }
     } else if (indexPath.section == 3) {
            if (menuType == eSplitDaily) {
                if (selectedTimeArrayItems.count == 0) {
                    self.transitToSingleDoseViewController()
                } else {
                    self.transitToAddNewTimeScreen()
                }
            } else {
                self.transitToSingleDoseViewController()
            }
        } else {
            self.transitToSingleDoseViewController()
        }
 }
    
    func updateAlertMessageForMismatch () {
        
        if let dosageCell: DCDosageSelectionTableViewCell = dosageTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as? DCDosageSelectionTableViewCell {
            valueStringForRequiredDailyDose = dosageCell.requiredDailyDoseTextField.text!
            self.dosage?.splitDailyDose.dailyDose = valueStringForRequiredDailyDose as String
            valueForRequiredDailyDose = NSString(string: valueStringForRequiredDailyDose).floatValue
            if (valueStringForRequiredDailyDose != "" && valueForRequiredDailyDose != 0 && selectedTimeArrayItems.count != 0) {
                
                totalValueForDose = 0
                var valueOfDoseAtIndex : Float = 0
                var countOfItemsWithDoseValueSelected : Int = 0
                for index in 0..<valueForDoseForTime.count {
                    
                    if (valueForDoseForTime[index] != "") {
                        valueOfDoseAtIndex = NSString(string: valueForDoseForTime[index]).floatValue
                        totalValueForDose += valueOfDoseAtIndex
                        countOfItemsWithDoseValueSelected += 1
                    }
                }
                if (totalValueForDose == valueForRequiredDailyDose && countOfItemsWithDoseValueSelected == selectedTimeArrayItems.count) {
                    alertMessageForMismatch = ""
                } else if (totalValueForDose == valueForRequiredDailyDose && countOfItemsWithDoseValueSelected < selectedTimeArrayItems.count) {
                    alertMessageForMismatch = "Some administration times does not have dose value. Either delete it or adjust the distribution."
                } else if (totalValueForDose < valueForRequiredDailyDose) {
                    alertMessageForMismatch = "Add a further \(valueForRequiredDailyDose - totalValueForDose) \(self.dosage!.doseUnit) to meet the required daily dose"
                } else {
                    alertMessageForMismatch = "Remove \(totalValueForDose - valueForRequiredDailyDose) \(self.dosage!.doseUnit) to meet the required daily dose"
                }
            } else {
                alertMessageForMismatch = ""
            }
            dosageTableView.headerViewForSection(2)?.textLabel?.text = alertMessageForMismatch as String
        }
    }
    
    func updateTimeArray (index: Int) {
        
        if (dosage?.splitDailyDose.timeArray != nil) {
            for timeDictionary in (dosage?.splitDailyDose.timeArray)! {
                let time = timeDictionary["time"] as! String
                if (time == selectedTimeArrayItems[index]) {
                    let populatedDict = ["time": time, "selected": 1, "dose":valueForDoseForTime[index]]
                    dosage?.splitDailyDose.timeArray.replaceObjectAtIndex((dosage?.splitDailyDose.timeArray.indexOfObject(timeDictionary))!, withObject: populatedDict)
                }
            }
        }
    }
    
    func deleteElementFromTimeArrayAtSelectedIndexPath (index: Int) {
        
        if (dosage?.splitDailyDose.timeArray != nil) {
            for timeDictionary in (dosage?.splitDailyDose.timeArray)! {
                let time = timeDictionary["time"] as! String
                if (time == selectedTimeArrayItems[index]) {
                    let populatedDict = ["time": time, "selected": 0]
                    dosage?.splitDailyDose.timeArray.replaceObjectAtIndex((dosage?.splitDailyDose.timeArray.indexOfObject(timeDictionary))!, withObject: populatedDict)
                }
            }
        }
    }
    
    
    func insertNewTimeToTimeArray(time: String) {
        
        var timeAlreadyPresent : Bool = false
        if (dosage?.splitDailyDose.timeArray == nil) {
            dosage?.splitDailyDose.timeArray = NSMutableArray(array: DCPlistManager.administratingTimeList())
        }
        for timeDictionary in (dosage?.splitDailyDose.timeArray)! {
            let timeInArray = timeDictionary["time"] as! String
//            let isTimeSelected = timeDictionary["selected"] as! Int
            if (timeInArray == time) {
                timeAlreadyPresent = true
                let populatedDict = ["time": time, "selected": 1]
                dosage?.splitDailyDose.timeArray.replaceObjectAtIndex((dosage?.splitDailyDose.timeArray.indexOfObject(timeDictionary))!, withObject: populatedDict)
            }
        }
        if (timeAlreadyPresent == false) {
            let populatedDict = ["time": time, "selected": 1]
            dosage?.splitDailyDose.timeArray.addObject(populatedDict)
            dosage?.splitDailyDose.timeArray = NSMutableArray(array: DCUtility.sortArray(NSMutableArray(array: (dosage?.splitDailyDose.timeArray)!) as [AnyObject], basedOnKey: TIME_KEY, ascending: true))
        }
    }
    
    func populatedSingleDoseCell(singleDoseCell : DCDosageSelectionTableViewCell, atIndexPath indexPath : NSIndexPath) -> DCDosageSelectionTableViewCell {
        
        var singleDoseValue = NSMutableString(string: EMPTY_STRING)
        if let doseValue = dosage?.singleDose?.doseValue {
            if doseValue != EMPTY_STRING {
                singleDoseValue = NSMutableString(format: "%@", doseValue)
                if let doseUnit = self.dosage?.doseUnit {
                    singleDoseValue.appendFormat(" %@", doseUnit)
                } else {
                    singleDoseValue.appendString(" mg")
                }
                if let startTime = dosage?.singleDose?.dateAndTime {
                    singleDoseValue.appendFormat(" on %@", startTime)
                }
            }
        }
        singleDoseCell.accessoryType = .DisclosureIndicator
        singleDoseCell.configureCell(SINGLE_DOSE, selectedValue: singleDoseValue as String)
        return singleDoseCell
    }
    
    // MARK: - Navigation Methods
    
    func transitToAddNewTimeScreen() {
        
        let addNewDosageViewController : DCAddNewDoseAndTimeViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_NEW_DOSE_TIME_SBID) as? DCAddNewDoseAndTimeViewController
        addNewDosageViewController?.detailType = eAddNewTimes
        addNewDosageViewController!.newDosageEntered = { value in
            self.selectedTimeArrayItems.append(value!)
            self.valueForDoseForTime.append("")
            self.insertNewTimeToTimeArray(value!)
            self.configureTimeArray()
            self.updateAlertMessageForMismatch()
            self.dosageTableView.reloadData()
            self.dosageTableView.beginUpdates()
            self.dosageTableView.endUpdates()
        }
        let navigationController: UINavigationController = UINavigationController(rootViewController: addNewDosageViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func transitToDosageUnitSelectionViewController () {
        
        let doseUnitSelectionViewController : DCDosageUnitSelectionViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(DOSAGE_UNIT_SELECTION_SBID) as? DCDosageUnitSelectionViewController
        doseUnitSelectionViewController?.previousSelectedValue = (dosage?.doseUnit)!
        doseUnitSelectionViewController!.valueForUnitSelected = { value in
            self.dosage?.doseUnit = value!
            self.dosageTableView.reloadData()
        }
        self.configureNavigationBackButtonTitle();
        self.navigationController?.pushViewController(doseUnitSelectionViewController!, animated: true)
    }
    
    func transitToSingleDoseViewController () {
        
        //move to single dose view controller
        let singleDoseViewController = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(SINGLE_DOSE_VIEW_STORYBOARD_ID) as? DCSingleDoseViewController
        singleDoseViewController?.singleDose = self.dosage?.singleDose
        singleDoseViewController?.doseUnit = self.dosage?.doseUnit
        let viewControllers = self.navigationController!.viewControllers
        let rootViewController =  viewControllers[0] as? DCAddMedicationInitialViewController
        singleDoseViewController?.startDate = DCDateUtility.dateFromSourceString(rootViewController?.selectedMedication.startDate)
        self.configureNavigationBackButtonTitle();
        self.navigationController?.pushViewController(singleDoseViewController!, animated: true)
    }
    
    func transitToFixedDoseValueScreen () {
        
        let dosageDetailViewController : DCDosageDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(DOSAGE_DETAIL_SBID) as? DCDosageDetailViewController
        dosageDetailViewController?.delegate = self
        dosageDetailViewController?.dosageDetailsArray = dosageArray
        selectedDetailType = eDoseValue
        dosageDetailViewController?.previousSelectedValue = (self.dosage?.fixedDose.doseValue)!
        dosageDetailViewController?.detailType = eDoseValue
        self.configureNavigationBackButtonTitle();
        self.navigationController?.pushViewController(dosageDetailViewController!, animated: true)
    }
    
    func transitToVariableDoseFromValueScreen () {
        
        let dosageDetailViewController : DCDosageDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(DOSAGE_DETAIL_SBID) as? DCDosageDetailViewController
        dosageDetailViewController?.delegate = self
        dosageDetailViewController?.dosageDetailsArray = dosageArray
        selectedDetailType = eDoseFrom
        dosageDetailViewController?.previousSelectedValue = (self.dosage?.variableDose.doseFromValue)!
        dosageDetailViewController?.detailType = eDoseFrom
        self.configureNavigationBackButtonTitle();
        self.navigationController?.pushViewController(dosageDetailViewController!, animated: true)
    }
    
    func transitToVariableDoseToValueScreen () {
        
        let dosageDetailViewController : DCDosageDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(DOSAGE_DETAIL_SBID) as? DCDosageDetailViewController
        dosageDetailViewController?.delegate = self
        dosageDetailViewController?.dosageDetailsArray = dosageArray
        selectedDetailType = eDoseTo
        dosageDetailViewController?.previousSelectedValue = (self.dosage?.variableDose.doseToValue)!
        dosageDetailViewController?.detailType = eDoseTo
        self.configureNavigationBackButtonTitle();
        self.navigationController?.pushViewController(dosageDetailViewController!, animated: true)
    }
    
    func transitToReducingIncreasingStartingDoseValueScreen() {
        
        let dosageDetailViewController : DCDosageDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(DOSAGE_DETAIL_SBID) as? DCDosageDetailViewController
        dosageDetailViewController?.delegate = self
        dosageDetailViewController?.dosageDetailsArray = dosageArray
        selectedDetailType = eStartingDose
        dosageDetailViewController?.previousSelectedValue = (self.dosage?.reducingIncreasingDose.startingDose)!
        dosageDetailViewController?.detailType = eStartingDose
        self.configureNavigationBackButtonTitle();
        self.navigationController?.pushViewController(dosageDetailViewController!, animated: true)
    }
    
    func transitToConditionsChangeOverScreen () {
        
        let dosageDetailViewController : DCDosageDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(DOSAGE_DETAIL_SBID) as? DCDosageDetailViewController
        dosageDetailViewController?.delegate = self
        dosageDetailViewController?.dosageDetailsArray = dosageArray
        selectedDetailType = eChangeOver
        dosageDetailViewController?.previousSelectedValue = (self.dosage?.reducingIncreasingDose.changeOver)!
        dosageDetailViewController?.detailType = eChangeOver
        self.configureNavigationBackButtonTitle();
        self.navigationController?.pushViewController(dosageDetailViewController!, animated: true)
    }
    
    func transitToAddDoseForTimeScreen (indexPath : NSIndexPath) {
        
        let dosageDetailViewController : DCDosageDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(DOSAGE_DETAIL_SBID) as? DCDosageDetailViewController
        dosageDetailViewController?.delegate = self
        dosageDetailViewController?.doseForTimeArray = doseForTimeArray
        if (selectedTimeArrayItems.count != 0) {
            selectedDetailType = eAddDoseForTime
            selectedIndexPathInTimeArray = indexPath.row
            dosageDetailViewController?.previousSelectedValue = valueForDoseForTime[indexPath.row]
            dosageDetailViewController?.viewTitleForDisplay = selectedTimeArrayItems[indexPath.row]
            dosageDetailViewController?.detailType = eAddDoseForTime
            dosageDetailViewController?.doseLeftOfTotal = alertMessageForMismatch as String
        }
        self.configureNavigationBackButtonTitle();
        self.navigationController?.pushViewController(dosageDetailViewController!, animated: true)
    }
    
    
    // MARK: - Delegate Methods
    
    func newDosageAdded(value : String){
        
        //Enter the selected value to the particular type.
        if (selectedDetailType == eDoseValue) {
            self.dosage?.fixedDose?.doseValue = value
        } else if (selectedDetailType == eDoseFrom || selectedDetailType == eDoseTo) {
            if (selectedDetailType == eDoseFrom) {
                self.dosage?.variableDose?.doseFromValue = value
            } else {
                self.dosage?.variableDose.doseToValue = value
            }
        } else if (selectedDetailType == eDoseUnit) {
            dosage?.doseUnit = value
        } else if (selectedDetailType == eStartingDose) {
            self.dosage?.reducingIncreasingDose.startingDose = value
        } else if (selectedDetailType == eAddDoseForTime) {
            valueForDoseForTime[selectedIndexPathInTimeArray] = value
            self.updateTimeArray(selectedIndexPathInTimeArray)
            self.updateAlertMessageForMismatch()
        }
        //Update the dosage array.
        if selectedDetailType == eAddDoseForTime {
            doseForTimeArray.append(value)
            self.doseForTimeArray =  self.doseForTimeArray.sort { NSString(string: $0).floatValue > NSString(string: $1).floatValue }
        } else {
            dosageArray.append(value)
            self.dosageArray =  self.dosageArray.sort { NSString(string: $0).floatValue > NSString(string: $1).floatValue }
        }
        dosageTableView.reloadData()
    }
    
    func userDidSelectValue(value: String) {
        
        switch (selectedDetailType.rawValue) {
            
        case eDoseValue.rawValue:
            self.dosage?.fixedDose?.doseValue = value
        case eDoseFrom.rawValue:
            self.dosage?.variableDose.doseFromValue = value
            if dosageArray.count != 0 {
                if self.dosage!.variableDose.doseFromValue != doseValueFromAPI && self.dosage!.variableDose.doseToValue != doseValueFromAPI {
//                    newDosageAddedDelegate?.newDosageAdded("\((self.dosage?.variableDose.doseFromValue)!) \((dosage?.doseUnit)!) , \((self.dosage?.variableDose.doseToValue)!) \((dosage?.doseUnit)!)")
                }
            } else {
                if self.dosage?.variableDose.doseFromValue != "" && self.dosage?.variableDose.doseToValue != "" {
//                    newDosageAddedDelegate?.newDosageAdded("\((self.dosage?.variableDose.doseFromValue)!) \((dosage?.doseUnit)!) , \((self.dosage?.variableDose.doseToValue)!) \((dosage?.doseUnit)!)")
                }
            }
        case eDoseTo.rawValue:
            self.dosage?.variableDose.doseToValue = value
            if dosageArray.count != 0 {
                if self.dosage!.variableDose.doseFromValue != doseValueFromAPI && self.dosage!.variableDose.doseToValue != doseValueFromAPI {
//                    newDosageAddedDelegate?.newDosageAdded("\((self.dosage?.variableDose.doseFromValue)!) \((dosage?.doseUnit)!) , \((self.dosage?.variableDose.doseToValue)!) \((dosage?.doseUnit)!)")
                }
            } else {
                if self.dosage?.variableDose?.doseFromValue != "" && self.dosage?.variableDose.doseToValue != "" {
//                    newDosageAddedDelegate?.newDosageAdded("\((self.dosage?.variableDose.doseFromValue)!) \((dosage?.doseUnit)!) , \((self.dosage?.variableDose.doseToValue)!) \((dosage?.doseUnit)!)")
                }
            }
        case eStartingDose.rawValue:
            self.dosage?.reducingIncreasingDose.startingDose = value
        case eChangeOver.rawValue:
            self.dosage?.reducingIncreasingDose.changeOver = value
        case eAddDoseForTime.rawValue:
            valueForDoseForTime[selectedIndexPathInTimeArray] = value
            self.updateTimeArray(selectedIndexPathInTimeArray)
            self.updateAlertMessageForMismatch()
        default:
            break
        }
        dosageTableView.reloadData()
    }
    
    // MARK: - TextField Delegate Methods
    
    // UITextField Delegates
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        self.updateAlertMessageForMismatch()
        dosageTableView.reloadData()
        dosageTableView.beginUpdates()
        dosageTableView.endUpdates()
        return true;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Create an `NSCharacterSet` set which includes everything *but* the digits
        let inverseSet = NSCharacterSet(charactersInString:INTEGER_SET_STRING).invertedSet
        
        // At every character in this "inverseSet" contained in the string,
        // split the string up into components which exclude the characters
        // in this inverse set
        let components = string.componentsSeparatedByCharactersInSet(inverseSet)
        
        // Rejoin these components
        let filtered = components.joinWithSeparator(EMPTY_STRING)
        
        // If the original string is equal to the filtered string, i.e. if no
        // inverse characters were present to be eliminated, the input is valid
        // and the statement returns true; else it returns false
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
        if (NSString(string: newString).floatValue > maximumValueOfDose) {
            return false
        }
        let arrayOfString: [AnyObject] = newString.componentsSeparatedByString(".")
        if arrayOfString.count > 2 {
            return false
        }
        return string == filtered
    }
    
    // MARK: - keyboard Delegate Methods
    
    func keyboardDidShow(notification: NSNotification) {
        //notification methods
        if appDelegate.windowState == DCWindowState.halfWindow || appDelegate.windowState == DCWindowState.oneThirdWindow {
            let delayInSeconds: Double = 0.25
            let deleteTime : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
            dispatch_after(deleteTime, dispatch_get_main_queue(), {() -> Void in
                self.dosageTableView.setContentOffset(CGPointMake(0, 10), animated: true)
            })
        }
    }
}
