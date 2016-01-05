//
//  DCDosageDetailViewController.swift
//  DrugChart
//
//  Created by Shaheer on 11/12/15.
//
//

import UIKit

// protocol used for sending data back to Dosage Selection
protocol DataEnteredDelegate: class {
    
    func userDidSelectValue(value: String)
    func newDosageAdded(value : String)
}

// protocol used for sending data back to Dosage Detail
protocol newDosageEntered: class {
    
    func prepareForTransitionBackToSelection(value: String)
}


class DCDosageDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, newDosageEntered {
    
    @IBOutlet weak var dosageDetailTableView: UITableView!
    let dosageUnitItems = ["mg","ml","%"]
    let changeOverItemsArray = ["Days","Doses"]
    var conditionsItemsArray = ["Reduce 50 mg every day"]
    var doseForTimeArray = ["250","100","50","30","20","10"]
    var detailType : DosageDetailType = eDoseUnit
    var viewTitleForDisplay : NSString = ""
    var previousSelectedValue : NSString = ""
    var selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var dosageDetailsArray = [String]()
    weak var delegate: DataEnteredDelegate? = nil
    weak var newDosageDelegate: newDosageEntered? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        dosageDetailTableView.reloadData()
        self.configureNavigationBarItems()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBarItems() {
        
        if (detailType == eAddNewDosage || detailType == eAddNewTime) {
            // Configure bar buttons for Add new.
            let cancelButton: UIBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target: self, action: "cancelButtonPressed")
            self.navigationItem.leftBarButtonItem = cancelButton
            let doneButton: UIBarButtonItem = UIBarButtonItem(title: DONE_BUTTON_TITLE, style: .Plain, target: self, action: "doneButtonPressed")
            self.navigationItem.rightBarButtonItem = doneButton
            if (detailType == eAddNewDosage) {
                self.navigationItem.title = ADD_NEW_TITLE
                self.title = ADD_NEW_TITLE
            } else {
                self.navigationItem.title = ADD_NEW_TIME
                self.title = ADD_NEW_TIME
            }
        } else {
            // Configure navigation title.
            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Default)
            switch (detailType.rawValue) {
                
            case eDoseUnit.rawValue:
                viewTitleForDisplay = DOSE_UNIT_TITLE
            case eDoseValue.rawValue:
                viewTitleForDisplay = DOSE_VALUE_TITLE
            case eDoseFrom.rawValue:
                viewTitleForDisplay = DOSE_FROM_TITLE
            case eDoseTo.rawValue:
                viewTitleForDisplay = DOSE_TO_TITLE
            case eStartingDose.rawValue:
                viewTitleForDisplay = STARTING_DOSE_TITLE
            case eChangeOver.rawValue:
                viewTitleForDisplay = CHANGE_OVER_TITLE
            default:
                break
            }
            self.navigationItem.title = viewTitleForDisplay as String
            self.title = viewTitleForDisplay as String
        }
    }
    
    // MARK: - TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (detailType == eDoseUnit || detailType == eAddNewDosage || detailType == eChangeOver || detailType == eAddNewTime) {
            return 1
        } else if (detailType == eAddDoseForTime) {
            return 2
        } else if (dosageDetailsArray.count == 0){
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            if (detailType == eDoseUnit) {
                return dosageUnitItems.count
            } else if (detailType == eDoseValue || detailType == eDoseFrom || detailType == eDoseTo || detailType == eStartingDose) {
                if (dosageDetailsArray.count != 0) {
                    return dosageDetailsArray.count
                } else {
                    return 1
                }
            } else if (detailType == eChangeOver) {
                return changeOverItemsArray.count
            } else if (detailType == eAddNewDosage || detailType == eAddNewTime) {
                return 1
            } else if(detailType == eAddDoseForTime){
                return doseForTimeArray.count
            } else {
                return 2
            }
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (detailType == eAddNewDosage) {
            let dosageDetailCell : DCDosageDetailTableViewCell? = dosageDetailTableView.dequeueReusableCellWithIdentifier(ADD_NEW_VALUE_CELL_ID) as? DCDosageDetailTableViewCell
            return dosageDetailCell!
        } else if (detailType == eAddNewTime) {
            let dosageDetailCell : DCDosageDetailTableViewCell? = dosageDetailTableView.dequeueReusableCellWithIdentifier(ADD_NEW_TIME_CELL_ID) as? DCDosageDetailTableViewCell
            return dosageDetailCell!
        } else {
            if (indexPath.section == 0) {
                let cellForDisplay : DCDosageDetailTableViewCell = self.configureCellForDisplay(indexPath)
                return cellForDisplay
            } else {
                let cellForDisplay : DCDosageDetailTableViewCell = self.configureCellForAddNew()
                return cellForDisplay
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0 ) {
            if (dosageDetailsArray.count != 0 || detailType == eChangeOver || detailType == eDoseUnit || detailType == eAddDoseForTime ) {
                switch (detailType.rawValue) {
                    
                case eDoseUnit.rawValue:
                    delegate?.userDidSelectValue(dosageUnitItems[indexPath.row])
                case eDoseValue.rawValue,eDoseFrom.rawValue,eDoseTo.rawValue,eStartingDose.rawValue:
                    delegate?.userDidSelectValue(dosageDetailsArray[indexPath.row])
                case eChangeOver.rawValue:
                    delegate?.userDidSelectValue(changeOverItemsArray[indexPath.row])
                case eAddDoseForTime.rawValue:
                    delegate?.userDidSelectValue(doseForTimeArray[indexPath.row])
                default:
                    break
                }
                self.navigationController?.popViewControllerAnimated(true)
            }else {
                    self.transitToAddNewScreen()
            }
        } else {
            self.transitToAddNewScreen()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (detailType == eAddNewTime) {
            return 216
        }
        return 44 //Choose your custom row height
    }
    
    // MARK: - Private Methods
    
    func configureCellForAddNew() -> DCDosageDetailTableViewCell{
        
        let dosageDetailCell : DCDosageDetailTableViewCell? = dosageDetailTableView.dequeueReusableCellWithIdentifier(DOSE_DETAIL_DISPLAY_CELL_ID) as? DCDosageDetailTableViewCell
            dosageDetailCell?.dosageDetailCellLabel.text = ADD_NEW_TITLE
        return dosageDetailCell!
    }
    
    func configureCellForDisplay(indexPath: NSIndexPath) -> DCDosageDetailTableViewCell {
        
        let dosageDetailCell : DCDosageDetailTableViewCell? = dosageDetailTableView.dequeueReusableCellWithIdentifier(DOSE_DETAIL_CELL_ID) as? DCDosageDetailTableViewCell
        // Configure the cell...
        if (detailType == eChangeOver) {
            dosageDetailCell?.accessoryType = (previousSelectedValue == changeOverItemsArray[indexPath.row]) ? .Checkmark : .None
            dosageDetailCell!.dosageDetailDisplayCell.text = changeOverItemsArray[indexPath.row]
            return dosageDetailCell!
        } else if (detailType == eAddDoseForTime) {
            dosageDetailCell?.accessoryType = (previousSelectedValue == doseForTimeArray[indexPath.row]) ? .Checkmark : .None
            dosageDetailCell!.dosageDetailDisplayCell.text = doseForTimeArray[indexPath.row]
            return dosageDetailCell!
        } else if (detailType == eDoseUnit) {
            dosageDetailCell?.accessoryType = (previousSelectedValue == dosageUnitItems[indexPath.row]) ? .Checkmark : .None
            dosageDetailCell!.dosageDetailDisplayCell.text = dosageUnitItems[indexPath.row]
            return dosageDetailCell!
        }
        if (dosageDetailsArray.count != 0) {
            switch (detailType.rawValue) {
                
            case eDoseValue.rawValue:
                dosageDetailCell?.accessoryType = (previousSelectedValue == dosageDetailsArray[indexPath.row]) ? .Checkmark : .None
                dosageDetailCell!.dosageDetailDisplayCell.text = dosageDetailsArray[indexPath.row]
            case eDoseFrom.rawValue:
                dosageDetailCell?.accessoryType = (previousSelectedValue == dosageDetailsArray[indexPath.row]) ? .Checkmark : .None
                dosageDetailCell!.dosageDetailDisplayCell.text = dosageDetailsArray[indexPath.row]
            case eDoseTo.rawValue:
                dosageDetailCell?.accessoryType = (previousSelectedValue == dosageDetailsArray[indexPath.row]) ? .Checkmark : .None
                dosageDetailCell!.dosageDetailDisplayCell.text = dosageDetailsArray[indexPath.row]
            case eStartingDose.rawValue:
                dosageDetailCell?.accessoryType = (previousSelectedValue == dosageDetailsArray[indexPath.row]) ? .Checkmark : .None
                dosageDetailCell!.dosageDetailDisplayCell.text = dosageDetailsArray[indexPath.row]
            default:
                break
            }
            return dosageDetailCell!
        } else {
            let cellForDisplay : DCDosageDetailTableViewCell = self.configureCellForAddNew()
            return cellForDisplay
        }
    }
    
    func transitToAddNewScreen (){
        
        let addNewDosageViewController : DCAddNewDoseAndTimeViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_NEW_DOSE_TIME_SBID) as? DCAddNewDoseAndTimeViewController
        addNewDosageViewController!.newDosageEntered = { value in
            self.delegate?.newDosageAdded(value as! String)
            self.navigationController?.popViewControllerAnimated(true)
        }
//            dosageDetailViewController?.detailType = eAddNewDosage
        let navigationController: UINavigationController = UINavigationController(rootViewController: addNewDosageViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func validateNewDosageValue (value: String) -> Bool {
        
        let scanner: NSScanner = NSScanner(string:value)
        let isNumeric = scanner.scanDecimal(nil) && scanner.atEnd
        return isNumeric
    }
    // MARK: - Action Methods
    
    func cancelButtonPressed() {
        
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed() {
        
        if (detailType == eAddNewDosage) {
            let dosageCell: DCDosageDetailTableViewCell = dosageDetailTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DCDosageDetailTableViewCell
            if (dosageCell.addNewDosageTextField.text! != "" && validateNewDosageValue(dosageCell.addNewDosageTextField.text!)) {
                newDosageDelegate?.prepareForTransitionBackToSelection(dosageCell.addNewDosageTextField.text!)
                self.navigationController!.dismissViewControllerAnimated(true, completion:nil)
            }
        } else {
            let dosageCell: DCDosageDetailTableViewCell = dosageDetailTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DCDosageDetailTableViewCell
            let newTime = DCDateUtility.dateInCurrentTimeZone(dosageCell.timePickerView.date)
            delegate?.userDidSelectValue(DCDateUtility.timeStringInTwentyFourHourFormat(newTime))
            self.navigationController!.dismissViewControllerAnimated(true, completion:nil)
        }
    }
    
    // MARK: - Delegate Methods
    
    func prepareForTransitionBackToSelection (value: String) {
        
            delegate?.newDosageAdded(value)
            self.navigationController?.popViewControllerAnimated(true)
    }

}
