//
//  DCDosageSelectionViewController.swift
//  DrugChart
//
//  Created by Shaheer on 09/12/15.
//
//

import UIKit

// protocol used for sending data back
@objc public protocol NewDosageValueEntered: class {
    
    func newDosageAdded(dosage : String)
}


@objc class DCDosageSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataEnteredDelegate {
    
    let dosageMenuItems = ["Fixed","Variable","Reducing / Increasing","Split Daily"]
    var menuType : DosageSelectionType = eDosageMenu
    var selectedDetailType : DosageDetailType = eDoseValue
    var timeArray : NSMutableArray? = []
    var selectedTimeArrayItems = [String]()
    var valueForDoseForTime = [String]()
    var isRowAlreadySelected : Bool = false
    var valueForDoseUnit : NSString = "mg"
    var valueForDoseValue : NSString = ""
    var valueForDoseFromValue : NSString = ""
    var valueForDoseToValue : NSString = ""
    var valueForStartingDoseValue : NSString = ""
    var valueForChangeOver : NSString = ""
    var valueForCondition : NSString = ""
    var selectedIndexPathInTimeArray : Int = 0
    var previousIndexPath = NSIndexPath(forRow: 5, inSection: 0)
    var dosageArray = [String]()
    var valueStringForRequiredDailyDose : NSString = ""
    var valueForRequiredDailyDose : Float = 0
    var totalValueForDose : Float = 0
    var alertMessageForMismatch :NSString = "Required Daily Dose Mismatch"
    @IBOutlet weak var dosageTableView: UITableView!
    weak var newDosageAddedDelegate: NewDosageValueEntered? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureInitialValues()
        self.configureNavigationBarItems()
        if (timeArray != nil) {
            self.configureTimeArray()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        dosageTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - View Configuration and Value Initializations
    
    func configureInitialValues (){
        
        if (dosageArray.count != 0) {
            valueForDoseValue = dosageArray[0] as String
            valueForDoseFromValue = dosageArray[0] as String
            valueForDoseToValue = dosageArray[0] as String
            valueForStartingDoseValue = dosageArray[0] as String
        } else {
            valueForDoseUnit = ""
            valueForDoseValue = ""
        }
        valueForChangeOver = "Days"
        valueForCondition = "Reduce 50 mg every day"
        
    }
    
    func configureTimeArray () {
        
        selectedTimeArrayItems = []
        valueForDoseForTime = []
        let predicate = NSPredicate(format: "selected == 1")
        let filteredArray = timeArray!.filteredArrayUsingPredicate(predicate)
        if (filteredArray.count != 0) {
            for timeDictionary in filteredArray {
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
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Default)
        self.navigationItem.title = DOSE_VALUE_TITLE
        self.title = DOSE_VALUE_TITLE
    }
    
    // MARK: - TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (menuType == eDosageMenu) {
            return 1
        } else if (menuType == eSplitDaily) {
            if (selectedTimeArrayItems.count != 0) {
                return 4
            } else {
                return 3
            }
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return 4
        } else if (section == 1) {
            switch(menuType.rawValue) {
                
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
            if (selectedTimeArrayItems.count != 0) {
                return selectedTimeArrayItems.count
            } else {
                return 1
            }
        }
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if (section == 2 && timeArray != nil && valueStringForRequiredDailyDose != "") {
            return alertMessageForMismatch as String
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel!.textColor = UIColor.blackColor()
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if ( indexPath.section == 0) {
            let dosageSelectionMenuCell : DCDosageSelectionTableViewCell? = dosageTableView.dequeueReusableCellWithIdentifier(DOSE_MENU_CELL_ID) as? DCDosageSelectionTableViewCell
            // Configure the cell...
            dosageSelectionMenuCell!.dosageMenuLabel.text = dosageMenuItems[indexPath.row]
            if (indexPath.row == previousIndexPath.row && indexPath.section == 0) {
                dosageSelectionMenuCell?.accessoryType = .Checkmark
            } else {
                dosageSelectionMenuCell?.accessoryType = .None
            }
            return dosageSelectionMenuCell!
        } else {
            let cellForDisplay : DCDosageSelectionTableViewCell = self.configureTableCellForDisplay(indexPath)
            return cellForDisplay
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0) {
            previousIndexPath = indexPath
            tableView.reloadData()
            switch (indexPath.row) {
                
            case 0:
                if (menuType == eFixedDosage){
                    isRowAlreadySelected = true
                }else {
                    menuType = eFixedDosage
                }
            case 1:
                if (menuType == eVariableDosage){
                    isRowAlreadySelected = true
                }else {
                    menuType = eVariableDosage
                }
            case 2:
                if (menuType == eReducingIncreasing){
                    isRowAlreadySelected = true
                }else {
                    menuType = eReducingIncreasing
                }
            case 3:
                if (menuType == eSplitDaily){
                    isRowAlreadySelected = true
                }else {
                    menuType = eSplitDaily
                }
            default:
                break
            }
            var range = NSMakeRange(1, 3)
            if (selectedTimeArrayItems.count == 0) {
                range = NSMakeRange(1, 2)
            }
            let sections = NSIndexSet(indexesInRange: range)
            if (isRowAlreadySelected == true){
                menuType = eDosageMenu
                isRowAlreadySelected = false
                tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
                let sectionCount = tableView.numberOfSections
//                //Todo : Comment this for Split Daily.
//                if sectionCount == 2 {
//                tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
//                }
//                Todo : Uncomment this for Split daily.
                if (sectionCount == 2) {
                    tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                } else {
                    tableView.deleteSections(sections, withRowAnimation: .Fade)
                }
            } else {
                let sectionCount = tableView.numberOfSections
                //Todo: for Split Daily.
                if (indexPath.row != 3) {
                    tableView.beginUpdates()
                    if (sectionCount == INITIAL_SECTION_COUNT) {
                        //if section count is zero insert new section with animation
                        // Todo : Comment this for split daily.
//                        if (indexPath.row != 3) {
                        tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
//                        }
                    } else if (sectionCount >= 3) {
                        //Insert sections of split daily.
                        tableView.deleteSections(sections, withRowAnimation: .Fade)
                        tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                    } else {
                        //reload sections
                        // For Split Daily, Uncomment this
                        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                        // For Split Daily, Comment this
//                        if (menuType != eDosageMenu) {
//                        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
//                        } else {
//                            tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
//                        }
                    }
                    tableView.endUpdates()
                //Todo : Uncomment for Split Daily.
                } else {
                    if (sectionCount == INITIAL_SECTION_COUNT) {
                        tableView.insertSections(sections, withRowAnimation: .Fade)
                    } else {
                        tableView.beginUpdates()
                        tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                        tableView.insertSections(sections, withRowAnimation: .Fade)
                        tableView.endUpdates()
                    }
                }
            }
        } else {
            self.displayDosageDetailViewControllerWithSelectedDetailType(indexPath)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Private Methods
    
    func displayDosageDetailViewControllerWithSelectedDetailType(indexPath : NSIndexPath ) {
        
        //Function to configure the detail VC and to transit to the DCDosageDetailViewController
        let dosageDetailViewController : DCDosageDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(DOSAGE_DETAIL_SBID) as? DCDosageDetailViewController
        dosageDetailViewController?.delegate = self
        dosageDetailViewController?.dosageDetailsArray = dosageArray
        if (indexPath.section == 1) {
            switch (indexPath.row) {
                
            case 0:
                selectedDetailType = eDoseUnit
                dosageDetailViewController?.previousSelectedValue = valueForDoseUnit
                dosageDetailViewController?.detailType = eDoseUnit
            case 1:
                if (menuType == eFixedDosage) {
                    selectedDetailType = eDoseValue
                    dosageDetailViewController?.previousSelectedValue = valueForDoseValue
                    dosageDetailViewController?.detailType = eDoseValue
                } else if (menuType == eVariableDosage) {
                    selectedDetailType = eDoseFrom
                    dosageDetailViewController?.previousSelectedValue = valueForDoseFromValue
                    dosageDetailViewController?.detailType = eDoseFrom
                } else if (menuType == eReducingIncreasing) {
                    selectedDetailType = eStartingDose
                    dosageDetailViewController?.previousSelectedValue = valueForStartingDoseValue
                    dosageDetailViewController?.detailType = eStartingDose
                } else {
                    return
                }
            case 2:
                if (menuType == eVariableDosage) {
                    selectedDetailType = eDoseTo
                    dosageDetailViewController?.previousSelectedValue = valueForDoseToValue
                    dosageDetailViewController?.detailType = eDoseTo
                } else if (menuType == eReducingIncreasing) {
                    selectedDetailType = eChangeOver
                    dosageDetailViewController?.previousSelectedValue = valueForChangeOver
                    dosageDetailViewController?.detailType = eChangeOver
                }
            case 3:
                if (menuType == eReducingIncreasing) {
                    let dosageDetailViewController : DCDosageConditionsViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(DOSAGE_CONDITIONS_SBID) as? DCDosageConditionsViewController
                    self.navigationController?.pushViewController(dosageDetailViewController!, animated: true)
                    return ()
                }
            default:
                break
            }
        } else if (indexPath.section == 2) {
            if (selectedTimeArrayItems.count != 0) {
                selectedDetailType = eAddDoseForTime
                selectedIndexPathInTimeArray = indexPath.row
                dosageDetailViewController?.previousSelectedValue = valueForDoseForTime[indexPath.row]
                dosageDetailViewController?.viewTitleForDisplay = selectedTimeArrayItems[indexPath.row]
                dosageDetailViewController?.detailType = eAddDoseForTime
            } else {
                selectedDetailType = eAddNewTime
                dosageDetailViewController?.detailType = eAddNewTime
            }
        } else {
            selectedDetailType = eAddNewTime
            dosageDetailViewController?.detailType = eAddNewTime
        }
        if (selectedDetailType != eAddNewTime) {
            self.navigationController?.pushViewController(dosageDetailViewController!, animated: true)
        } else {
            let navigationController: UINavigationController = UINavigationController(rootViewController: dosageDetailViewController!)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    func configureTableCellForDisplay (indexPath : NSIndexPath) -> DCDosageSelectionTableViewCell {
        
        let dosageSelectionDetailCell : DCDosageSelectionTableViewCell
        if (menuType != eSplitDaily) {
            dosageSelectionDetailCell = (dosageTableView.dequeueReusableCellWithIdentifier(DOSE_DROP_DOWN_CELL_ID) as? DCDosageSelectionTableViewCell)!
        } else {
            if (indexPath.section == 1) {
                if (indexPath.row == 0) {
                    dosageSelectionDetailCell = (dosageTableView.dequeueReusableCellWithIdentifier(DOSE_DROP_DOWN_CELL_ID) as? DCDosageSelectionTableViewCell)!
                } else {
                    dosageSelectionDetailCell = (dosageTableView.dequeueReusableCellWithIdentifier(REQUIRED_DAILY_DOSE_CELL_ID) as? DCDosageSelectionTableViewCell)!
                }
            } else if (indexPath.section == 2) {
                if (selectedTimeArrayItems.count != 0) {
                    dosageSelectionDetailCell = (dosageTableView.dequeueReusableCellWithIdentifier(DOSE_DROP_DOWN_CELL_ID) as? DCDosageSelectionTableViewCell)!
                } else {
                    dosageSelectionDetailCell = (dosageTableView.dequeueReusableCellWithIdentifier(DOSE_MENU_CELL_ID) as? DCDosageSelectionTableViewCell)!
                }
            } else {
                dosageSelectionDetailCell = (dosageTableView.dequeueReusableCellWithIdentifier(DOSE_MENU_CELL_ID) as? DCDosageSelectionTableViewCell)!
            }
        }
        switch (menuType.rawValue) {
            
        case eFixedDosage.rawValue:
            // Configure the cell...
            if(indexPath.row == 0){
                dosageSelectionDetailCell.configureCell(DOSE_UNIT_LABEL_TEXT, selectedValue: valueForDoseUnit as String)
            }else {
                dosageSelectionDetailCell.configureCell(DOSE_VALUE_TITLE, selectedValue: valueForDoseValue as String)
            }
        case eVariableDosage.rawValue:
            // Configure the cell...
            if(indexPath.row == 0) {
                dosageSelectionDetailCell.configureCell(DOSE_UNIT_LABEL_TEXT, selectedValue: valueForDoseUnit as String)
            }else if (indexPath.row == 1) {
                dosageSelectionDetailCell.configureCell(DOSE_FROM_TITLE, selectedValue: valueForDoseFromValue as String)
            } else {
                dosageSelectionDetailCell.configureCell(DOSE_TO_TITLE, selectedValue: valueForDoseToValue as String)
            }
        case eReducingIncreasing.rawValue:
            // Configure the cell...
            if(indexPath.row == 0) {
                dosageSelectionDetailCell.configureCell(DOSE_UNIT_LABEL_TEXT, selectedValue: valueForDoseUnit as String)
            }else if (indexPath.row == 1) {
                dosageSelectionDetailCell.configureCell(STARTING_DOSE_TITLE, selectedValue: valueForStartingDoseValue as String)
            } else if(indexPath.row == 2){
                dosageSelectionDetailCell.configureCell(CHANGE_OVER_TITLE, selectedValue: valueForChangeOver as String)
            } else {
                dosageSelectionDetailCell.configureCell(CONDITIONS_TITLE, selectedValue: valueForCondition as String)
            }
        case eSplitDaily.rawValue:
            // Configure the cell...
            if (indexPath.section == 1) {
                if(indexPath.row == 0){
                    dosageSelectionDetailCell.configureCell(DOSE_UNIT_LABEL_TEXT, selectedValue: valueForDoseUnit as String)
                }
            } else if (indexPath.section == 2) {
                if (selectedTimeArrayItems.count != 0) {
                    dosageSelectionDetailCell.configureCell(selectedTimeArrayItems[indexPath.row], selectedValue: valueForDoseForTime[indexPath.row])
                } else {
                    dosageSelectionDetailCell.dosageMenuLabel.text = ADD_ADMINISTRATION_TIME
                }
            } else {
                dosageSelectionDetailCell.dosageMenuLabel.text = ADD_ADMINISTRATION_TIME
            }
        default:
            break
        }
        return dosageSelectionDetailCell
    }
    
    func updateAlertMessageForMismatch () {
        
        let dosageCell: DCDosageSelectionTableViewCell = dosageTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as! DCDosageSelectionTableViewCell
        valueStringForRequiredDailyDose = dosageCell.requiredDailyDoseTextField.text!
        valueForRequiredDailyDose = NSString(string: valueStringForRequiredDailyDose).floatValue
        if (valueStringForRequiredDailyDose != "" && valueForRequiredDailyDose != 0) {
            
            totalValueForDose = 0
            var valueOfDoseAtIndex : Float = 0
            for index in 0..<valueForDoseForTime.count {
                
                if (valueForDoseForTime[index] != "") {
                    valueOfDoseAtIndex = NSString(string: valueForDoseForTime[index]).floatValue
                    totalValueForDose += valueOfDoseAtIndex
                }
            }
            if (totalValueForDose == valueForRequiredDailyDose) {
                alertMessageForMismatch = "No Mismatch"
            } else if (totalValueForDose < valueForRequiredDailyDose) {
                alertMessageForMismatch = "Need \(valueForRequiredDailyDose - totalValueForDose) more"
            } else {
                alertMessageForMismatch = "Need \(totalValueForDose - valueForRequiredDailyDose) less"
            }
        } else {
            alertMessageForMismatch = "Enter valid required daily dose"
        }
    }
    
    func updateTimeArray (index: Int) {
        
        if (timeArray != nil) {
            for timeDictionary in timeArray! {
                let time = timeDictionary["time"] as! String
                if (time == selectedTimeArrayItems[index]) {
                    let populatedDict = ["time": time, "selected": 1, "dose":valueForDoseForTime[index]]
                    timeArray?.replaceObjectAtIndex((timeArray?.indexOfObject(timeDictionary))!, withObject: populatedDict)
                }
            }
        }
    }
    
    func insertNewTimeToTimeArray(time: String) {
        
        var timeAlreadyPresent : Bool = false
        if (timeArray == nil) {
            timeArray = NSMutableArray(array: DCPlistManager.administratingTimeList())
        }
        for timeDictionary in timeArray! {
            let timeInArray = timeDictionary["time"] as! String
            if (timeInArray == time) {
                timeAlreadyPresent = true
            }
        }
        if (timeAlreadyPresent == false) {
            let populatedDict = ["time": time, "selected": 1]
            timeArray?.addObject(populatedDict)
            timeArray = NSMutableArray(array: DCUtility.sortArray(NSMutableArray(array: timeArray!) as [AnyObject], basedOnKey: TIME_KEY, ascending: true))
        }
    }
    
    // MARK: - Delegate Methods
    
    func newDosageAdded(value : String){
        
        if (selectedDetailType == eDoseValue) {
            valueForDoseValue = value
            newDosageAddedDelegate?.newDosageAdded("\(value)\(valueForDoseUnit)")
        } else if (selectedDetailType == eDoseFrom || selectedDetailType == eDoseTo) {
            if (selectedDetailType == eDoseFrom) {
                valueForDoseFromValue = value
            } else {
                valueForDoseToValue = value
            }
            newDosageAddedDelegate?.newDosageAdded("\(valueForDoseFromValue)\(valueForDoseUnit),\(valueForDoseToValue)\(valueForDoseUnit)")
        } else if (selectedDetailType == eDoseUnit) {
            valueForDoseUnit = value
        } else if (selectedDetailType == eStartingDose) {
            valueForStartingDoseValue = value
        }
        dosageTableView.reloadData()
    }
    
    func userDidSelectValue(value: String) {
        
        switch (selectedDetailType.rawValue) {
            
        case eDoseUnit.rawValue:
            valueForDoseUnit = value
        case eDoseValue.rawValue:
            valueForDoseValue = value
        case eDoseFrom.rawValue:
            valueForDoseFromValue = value
        case eDoseTo.rawValue:
            valueForDoseToValue = value
        case eStartingDose.rawValue:
            valueForStartingDoseValue = value
        case eChangeOver.rawValue:
            valueForChangeOver = value
        case eChangeOver.rawValue:
            valueForCondition = value
        case eAddDoseForTime.rawValue:
            valueForDoseForTime[selectedIndexPathInTimeArray] = value
            self.updateTimeArray(selectedIndexPathInTimeArray)
            self.updateAlertMessageForMismatch()
        case eAddNewTime.rawValue:
            selectedTimeArrayItems.append(value)
            valueForDoseForTime.append("")
            self.insertNewTimeToTimeArray(value)
            self.configureTimeArray()
        default:
            break
        }
        dosageTableView.reloadData()
    }
}
