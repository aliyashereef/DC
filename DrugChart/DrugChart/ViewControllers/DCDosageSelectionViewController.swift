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
    var isRowAlreadySelected : Bool = false
    var valueForDoseUnit : NSString = "mg"
    var valueForDoseValue : NSString = ""
    var valueForDoseFromValue : NSString = ""
    var valueForDoseToValue : NSString = ""
    var valueForStartingDoseValue : NSString = ""
    var valueForChangeOver : NSString = ""
    var valueForCondition : NSString = ""
    var previousIndexPath = NSIndexPath(forRow: 5, inSection: 0)
    var dosageArray = [String]()
    @IBOutlet weak var dosageTableView: UITableView!
    weak var newDosageAddedDelegate: NewDosageValueEntered? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureInitialValues()
        self.configureNavigationBarItems()
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
            
            return 2
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
                // Todo : For next release
//            case eSplitDaily.rawValue:
//                return 2 
            case eVariableDosage.rawValue:
                return 3
            case eReducingIncreasing.rawValue:
                return 4
            default:
                break
            }
            // For next release.
//        } else if (section == 2) {
//            
//            return 4
//        }
        }
        return 1
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
                    
                    //eSplitDaily in next release
                    menuType = eDosageMenu
                }
            default:
                break
            }
            if (isRowAlreadySelected == true){
                
                menuType = eDosageMenu
                isRowAlreadySelected = false
                tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
                tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
            } else if (indexPath.row != 3){
                
                tableView.beginUpdates()
                let sectionCount = tableView.numberOfSections
                if (sectionCount == INITIAL_SECTION_COUNT) {
                    //if section count is zero insert new section with animation
                    tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                } else {
                    //other wise reload the same section
                    tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                }
                tableView.endUpdates()
            }
            let sectionCount = tableView.numberOfSections
            if ( indexPath.row == 3 && sectionCount > 1) {
                
                tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
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
                
                //Todo : for Split daily.
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
                
                selectedDetailType = eConditions
                dosageDetailViewController?.previousSelectedValue = valueForCondition
                dosageDetailViewController?.detailType = eConditions
            }
            //Todo : Cases for Reducing/Increasing, Split daily.
        default:
            break
        }
        self.navigationController?.pushViewController(dosageDetailViewController!, animated: true)
    }
    
    func configureTableCellForDisplay (indexPath : NSIndexPath) -> DCDosageSelectionTableViewCell {
        
        let dosageSelectionDetailCell : DCDosageSelectionTableViewCell? = dosageTableView.dequeueReusableCellWithIdentifier(DOSE_DROP_DOWN_CELL_ID) as? DCDosageSelectionTableViewCell
        switch (menuType.rawValue) {
            
        case eFixedDosage.rawValue:
            // Configure the cell...
            if(indexPath.row == 0){
                
                dosageSelectionDetailCell?.configureCell(DOSE_UNIT_LABEL_TEXT, selectedValue: valueForDoseUnit as String)
            }else {
                
                dosageSelectionDetailCell?.configureCell(DOSE_VALUE_TITLE, selectedValue: valueForDoseValue as String)
            }
        case eVariableDosage.rawValue:
            // Configure the cell...
            if(indexPath.row == 0) {
                
                dosageSelectionDetailCell?.configureCell(DOSE_UNIT_LABEL_TEXT, selectedValue: valueForDoseUnit as String)
            }else if (indexPath.row == 1) {
                
                dosageSelectionDetailCell?.configureCell(DOSE_FROM_TITLE, selectedValue: valueForDoseFromValue as String)
                
            } else {
                
                dosageSelectionDetailCell?.configureCell(DOSE_TO_TITLE, selectedValue: valueForDoseToValue as String)
            }
        case eReducingIncreasing.rawValue:
            // Configure the cell...
            if(indexPath.row == 0) {
                
                dosageSelectionDetailCell?.configureCell(DOSE_UNIT_LABEL_TEXT, selectedValue: valueForDoseUnit as String)
                
            }else if (indexPath.row == 1) {
                
                dosageSelectionDetailCell?.configureCell(STARTING_DOSE_TITLE, selectedValue: valueForStartingDoseValue as String)
                
            } else if(indexPath.row == 2){
                
                dosageSelectionDetailCell?.configureCell(CHANGE_OVER_TITLE, selectedValue: valueForChangeOver as String)
            } else {
                
                dosageSelectionDetailCell?.configureCell(CONDITIONS_TITLE, selectedValue: valueForCondition as String)
            }
        case eSplitDaily.rawValue:
            // Configure the cell...
            if(indexPath.row == 0){
                
                dosageSelectionDetailCell?.configureCell(DOSE_UNIT_LABEL_TEXT, selectedValue: valueForDoseUnit as String)
            }else {
                
                dosageSelectionDetailCell?.configureCell(DOSE_VALUE_TITLE, selectedValue: valueForDoseValue as String)
            }
        default:
            break
        }
        return dosageSelectionDetailCell!
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
        default:
            break
        }
        dosageTableView.reloadData()
    }
}
