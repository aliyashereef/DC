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


@objc class DCDosageSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DataEnteredDelegate {
    
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
    var alertMessageForMismatch :NSString = ""
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
        
        if (section == 2 && timeArray != nil && alertMessageForMismatch != "") {
            return alertMessageForMismatch as String
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel!.textColor = UIColor.redColor()
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 2 && timeArray != nil && alertMessageForMismatch != "") {
            return 61.0
        } else {
            return 0.0
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
            self.checkWhetherRowAlreadySelected(indexPath)
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
                        tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                    } else if (sectionCount >= 3) {
                        //Insert sections of split daily.
                        tableView.deleteSections(sections, withRowAnimation: .Fade)
                        tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                    } else {
                        //reload sections
                        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                    }
                    tableView.endUpdates()
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return YES if you want the specified item to be editable.
        if indexPath.section == 2 && timeArray != nil && selectedTimeArrayItems.count != 0 {
            return true
        } else {
            return false
        }
    }
    // Override to support editing the table view.
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //add code here for when you hit delete
            self.deleteElementFromTimeArrayAtSelectedIndexPath(indexPath.row)
            self.configureTimeArray()
            self.updateAlertMessageForMismatch()
            self.dosageTableView.reloadData()
            dosageTableView.beginUpdates()
            dosageTableView.endUpdates()
        }
    }
    
    // MARK: - Private Methods
    
    func checkWhetherRowAlreadySelected (indexPath : NSIndexPath) {
        
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

    }
    
    func displayDosageDetailViewControllerWithSelectedDetailType(indexPath : NSIndexPath ) {
        
        //Function to configure the detail VC and to transit to the DCDosageDetailViewController
        let dosageDetailViewController : DCDosageDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(DOSAGE_DETAIL_SBID) as? DCDosageDetailViewController
        dosageDetailViewController?.delegate = self
        dosageDetailViewController?.dosageDetailsArray = dosageArray
        if (indexPath.section == 1) {
            switch (indexPath.row) {
                
            case 0:
                 let doseUnitSelectionViewController : DCDosageUnitSelectionViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(DOSAGE_UNIT_SELECTION_SBID) as? DCDosageUnitSelectionViewController
                doseUnitSelectionViewController?.previousSelectedValue = valueForDoseUnit
                doseUnitSelectionViewController!.valueForUnitSelected = { value in
                    self.valueForDoseUnit = value!
                    self.dosageTableView.reloadData()
                }
                self.navigationController?.pushViewController(doseUnitSelectionViewController!, animated: true)
                return
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
                    return
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
                self.transitToAddNewTimeScreen()
            }
        } else {
            self.transitToAddNewTimeScreen()
        }
        self.navigationController?.pushViewController(dosageDetailViewController!, animated: true)
    }
    
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
                    dosageSelectionDetailCell.requiredDailyDoseTextField.delegate = self
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
        if (valueStringForRequiredDailyDose != "" && valueForRequiredDailyDose != 0 && selectedTimeArrayItems.count != 0) {
            
            totalValueForDose = 0
            var valueOfDoseAtIndex : Float = 0
            for index in 0..<valueForDoseForTime.count {
                
                if (valueForDoseForTime[index] != "") {
                    valueOfDoseAtIndex = NSString(string: valueForDoseForTime[index]).floatValue
                    totalValueForDose += valueOfDoseAtIndex
                }
            }
            if (totalValueForDose == valueForRequiredDailyDose) {
                alertMessageForMismatch = ""
            } else if (totalValueForDose < valueForRequiredDailyDose) {
                alertMessageForMismatch = "ADD A FURTHER \(valueForRequiredDailyDose - totalValueForDose) MG TO MEET THE REQUIRED DAILY DOSE"
            } else {
                alertMessageForMismatch = "REMOVE \(totalValueForDose - valueForRequiredDailyDose) MG TO MEET THE REQUIRED DAILY DOSE"
            }
        } else {
            alertMessageForMismatch = ""
        }
        dosageTableView.headerViewForSection(2)?.textLabel?.text = alertMessageForMismatch as String
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
    
    func deleteElementFromTimeArrayAtSelectedIndexPath (index: Int) {
        
        print("Before :")
        print(timeArray)
        if (timeArray != nil) {
            for timeDictionary in timeArray! {
                let time = timeDictionary["time"] as! String
                if (time == selectedTimeArrayItems[index]) {
                    let populatedDict = ["time": time, "selected": 0, "dose":valueForDoseForTime[index]]
                    timeArray?.replaceObjectAtIndex((timeArray?.indexOfObject(timeDictionary))!, withObject: populatedDict)
                }
            }
        }
        print("After :")
        print(timeArray)
    }

    
    func insertNewTimeToTimeArray(time: String) {
        
        var timeAlreadyPresent : Bool = false
        if (timeArray == nil) {
            timeArray = NSMutableArray(array: DCPlistManager.administratingTimeList())
        }
        for timeDictionary in timeArray! {
            let timeInArray = timeDictionary["time"] as! String
            let isTimeSelected = timeDictionary["selected"] as! Int
            if (timeInArray == time && isTimeSelected != 0) {
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
            newDosageAddedDelegate?.newDosageAdded("\(value) \(valueForDoseUnit)")
        } else if (selectedDetailType == eDoseFrom || selectedDetailType == eDoseTo) {
            if (selectedDetailType == eDoseFrom) {
                valueForDoseFromValue = value
            } else {
                valueForDoseToValue = value
            }
            newDosageAddedDelegate?.newDosageAdded("\(valueForDoseFromValue) \(valueForDoseUnit) , \(valueForDoseToValue) \(valueForDoseUnit)")
        } else if (selectedDetailType == eDoseUnit) {
            valueForDoseUnit = value
        } else if (selectedDetailType == eStartingDose) {
            valueForStartingDoseValue = value
        }
        dosageTableView.reloadData()
    }
    
    func userDidSelectValue(value: String) {
        
        switch (selectedDetailType.rawValue) {
            
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

}
