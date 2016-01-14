//
//  DCAddConditionViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 05/01/16.
//
//

import UIKit

typealias NewConditionEntered = String? -> Void

class DCAddConditionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var addConditionMenuItems = ["Change","Dose","Every","Until"]
    var inlinePickerForChangeActive : Bool = false
    var inlinePickerForEveryActive : Bool = false
    var valueForChange : NSString = ""
    var valueForDose : NSString = ""
    var valueForEvery : NSString = ""
    var valueForUntil : NSString = ""
    var selectedPickerType : PickerType?
    var newConditionEntered: NewConditionEntered = { value in }

    @IBOutlet weak var addConditionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBarItems()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBarItems() {
        
            // Configure bar buttons for Add new.
            let cancelButton: UIBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target: self, action: "cancelButtonPressed")
            self.navigationItem.leftBarButtonItem = cancelButton
            let doneButton: UIBarButtonItem = UIBarButtonItem(title: DONE_BUTTON_TITLE, style: .Plain, target: self, action: "doneButtonPressed")
            self.navigationItem.rightBarButtonItem = doneButton
                self.navigationItem.title = ADD_CONDITION_TITLE
                self.title = ADD_CONDITION_TITLE
        }
    
    // MARK: - Table View Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (indexPath.row == 1){
            if (!inlinePickerForChangeActive) {
                return 0
            }else {
                
                return 216
            }
        } else if (indexPath.row == 4) {
            
            if (!inlinePickerForEveryActive) {
                return 0
            }else {
                
                return 216
            }
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let dosageConditionCell : DCAddConditionTableViewCell? = tableView.dequeueReusableCellWithIdentifier(ADD_CONDITION_MENU_CELL_ID) as? DCAddConditionTableViewCell
        dosageConditionCell?.addConditionMenuLabel.textColor = UIColor.blackColor()
        switch indexPath.row {
        case 0:
            dosageConditionCell!.addConditionMenuLabel.text = addConditionMenuItems[0]
            dosageConditionCell?.addConditionValueLabel.text = valueForChange as String
        case 2:
            dosageConditionCell!.addConditionMenuLabel.text = addConditionMenuItems[1]
            dosageConditionCell?.addConditionValueLabel.text = valueForDose as String
        case 3:
            dosageConditionCell!.addConditionMenuLabel.text = addConditionMenuItems[2]
            dosageConditionCell?.addConditionValueLabel.text = valueForEvery as String
        case 5:
            dosageConditionCell!.addConditionMenuLabel.text = addConditionMenuItems[3]
            dosageConditionCell?.addConditionValueLabel.text = valueForUntil as String
        case 1,4:
            let dosageDetailCell : DCDosageDetailPickerCell = self.configureInlinePicker(indexPath)
            return dosageDetailCell
        default:
            break
        }
        return dosageConditionCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row != 0 {
            inlinePickerForChangeActive = false
        } else if indexPath.row != 3 {
            inlinePickerForEveryActive = false
        }
        self.updateTableViewForAddCondition(indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Private Methods
    
    func updateTableViewForAddCondition(indexPath: NSIndexPath) {
        
        if (indexPath.row == 0) {
            
            if (inlinePickerForChangeActive) {
                
                //Same Clicked
                inlinePickerForChangeActive = false
                let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
                addConditionTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Middle)
            } else {
                inlinePickerForChangeActive = true
                let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
                addConditionTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Middle)
            }
        } else if (indexPath.row == 3) {
            
            if (inlinePickerForEveryActive) {
                
                //Same Clicked
                inlinePickerForEveryActive = false
                let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
                addConditionTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Middle)
            } else {
                inlinePickerForEveryActive = true
                let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
                addConditionTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Middle)
            }
        } else if (indexPath.row == 2) {
            let addConditionDetailViewController : DCAddConditionDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_CONDITION_DETAIL_SBID) as? DCAddConditionDetailViewController
            addConditionDetailViewController!.previousSelectedValue = valueForDose
            addConditionDetailViewController?.detailType = eDoseChange
            addConditionDetailViewController?.valueForDoseSelected = { value in
                self.valueForDose = value!
                self.addConditionTableView.reloadData()
            }
            self.navigationController?.pushViewController(addConditionDetailViewController!, animated: true)
        } else if (indexPath.row == 5) {
            let addConditionDetailViewController : DCAddConditionDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_CONDITION_DETAIL_SBID) as? DCAddConditionDetailViewController
            addConditionDetailViewController!.previousSelectedValue = valueForUntil
            addConditionDetailViewController?.detailType = eUntilDose
            addConditionDetailViewController?.valueForDoseSelected = { value in
                self.valueForUntil = value!
                self.addConditionTableView.reloadData()
            }
            self.navigationController?.pushViewController(addConditionDetailViewController!, animated: true)
        }
    }
    
    func configureInlinePicker(indexPath: NSIndexPath) -> DCDosageDetailPickerCell {
        
        if (indexPath.row == 1) {
            
            let dosageDetailCell : DCDosageDetailPickerCell? = addConditionTableView.dequeueReusableCellWithIdentifier(DOSE_PICKER_DISPLAY_CELL_ID) as? DCDosageDetailPickerCell
            selectedPickerType = eReducingIncreasingType
            dosageDetailCell?.configurePickerCellForPickerType(eReducingIncreasingType)
            dosageDetailCell?.pickerCompletion = { value in
                
                self.valueForChange = value!
                self.addConditionTableView.reloadData()
            }
            
            return dosageDetailCell!
        } else {
            
            let dosageDetailCell : DCDosageDetailPickerCell? = addConditionTableView.dequeueReusableCellWithIdentifier(DOSE_PICKER_DISPLAY_CELL_ID) as? DCDosageDetailPickerCell
            selectedPickerType = eDailyCount
            dosageDetailCell?.configurePickerCellForPickerType(eDailyCount)
            dosageDetailCell?.pickerCompletion = { value in
                
                self.valueForEvery = "\(value!) days"
                self.addConditionTableView.reloadData()
            }
            return dosageDetailCell!
        }
    }

    // MARK: - Action Methods
    
    func cancelButtonPressed() {
        
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed() {
        
            var displayString : String = ""
            var change : String = ""
            if (valueForChange == "Reducing") {
                change = "Reduce"
            } else {
                change = "Increase"
            }
            if (valueForDose != "" && valueForEvery != "" && valueForUntil != "") {
                displayString = "\(change) \(valueForDose) every \(valueForEvery) until \(valueForUntil)"
            } else {
                displayString = ""
            }
        if (displayString != "") {
            self.newConditionEntered(displayString)
        }
            self.navigationController!.dismissViewControllerAnimated(true, completion:nil)
    }

}
