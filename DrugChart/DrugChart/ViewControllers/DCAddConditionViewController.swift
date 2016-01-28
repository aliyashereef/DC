//
//  DCAddConditionViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 05/01/16.
//
//

import UIKit

typealias NewConditionEntered = DCConditions? -> Void

class DCAddConditionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var addConditionMenuItems = ["Change","Dose","Every","Until"]
    var inlinePickerForChangeActive : Bool = false
    var inlinePickerForEveryActive : Bool = false
    var valueForChange : NSString = ""
    var valueForDose : NSString = ""
    var valueForEvery : NSString = ""
    var valueForUntil : NSString = ""
    var newStartingDose : Float?
    var selectedPickerType : PickerType?
    var newConditionEntered: NewConditionEntered = { value in }
    var conditionItem : DCConditions?
    var dosage : DCDosage?
    var previewDetails = [String]()
    
    @IBOutlet weak var addConditionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conditionItem = DCConditions.init()
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
        if self.validateTheAddConditionValues() && previewDetails.count != 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 6
        } else {
            return previewDetails.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath .section == 0 {
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
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //Set the header as PREVIEW
        if (section == 1 && self.previewDetails.count != 0) {
            return "preview"
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        //Set the header as PREVIEW
        if (section == 0 && self.previewDetails.count != 0 && self.validateTheAddConditionValues()) {
            return DCDosageHelper.createDescriptionStringForDosageCondition(conditionItem!, dosageUnit: (self.dosage?.doseUnit)!)
        } else {
            return nil
        }
    }

    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        //Change text color to red and change text from full upper case to desired sentence.
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel!.textColor = UIColor.blackColor()
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
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
        } else {
            let conditionPreviewCell : DCAddConditionTableViewCell? = tableView.dequeueReusableCellWithIdentifier(DOSE_CONDITION_CELL_ID) as? DCAddConditionTableViewCell
            conditionPreviewCell?.conditionPreviewLabel.textColor = UIColor.blackColor()
            conditionPreviewCell?.conditionPreviewLabel.text = previewDetails[indexPath.row]
            return conditionPreviewCell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0) {
            if indexPath.row != 0 {
                inlinePickerForChangeActive = false
            } else if indexPath.row != 3 {
                inlinePickerForEveryActive = false
            }
            self.updateTableViewForAddCondition(indexPath)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Private Methods
    
    func updateTableViewForAddCondition(indexPath: NSIndexPath) {
        
        if (indexPath.row == 0) {
            
            if (inlinePickerForChangeActive) {
                
                //Same Clicked
                inlinePickerForChangeActive = false
                let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
                addConditionTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            } else {
                if inlinePickerForEveryActive {
                    inlinePickerForEveryActive = false
                    let indexPaths = [NSIndexPath(forItem: 4 , inSection: indexPath.section)]
                    addConditionTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                }
                let indexPathOfChange = NSIndexPath(forItem: indexPath.row + 1, inSection: 0)
                let pickerCell : DCDosageDetailPickerCell = addConditionTableView.cellForRowAtIndexPath(indexPathOfChange) as! DCDosageDetailPickerCell
                pickerCell.currentValueForPickerCell(eReducingIncreasingType)
                inlinePickerForChangeActive = true
                let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
                addConditionTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            }
        } else if (indexPath.row == 3) {
            
            if (inlinePickerForEveryActive) {
                
                //Same Clicked
                inlinePickerForEveryActive = false
                let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
                addConditionTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            } else {
                if inlinePickerForChangeActive {
                    inlinePickerForChangeActive = false
                    let indexPaths = [NSIndexPath(forItem: 1, inSection: indexPath.section)]
                    addConditionTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                }
                let indexPathOfChange = NSIndexPath(forItem: indexPath.row + 1, inSection: 0)
                let pickerCell : DCDosageDetailPickerCell = addConditionTableView.cellForRowAtIndexPath(indexPathOfChange) as! DCDosageDetailPickerCell
                pickerCell.currentValueForPickerCell(eDayCount)
                inlinePickerForEveryActive = true
                let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
                addConditionTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            }
        } else if (indexPath.row == 2) {
            let addConditionDetailViewController : DCAddConditionDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_CONDITION_DETAIL_SBID) as? DCAddConditionDetailViewController
            addConditionDetailViewController!.previousSelectedValue = valueForDose
            addConditionDetailViewController?.detailType = eDoseChange
            addConditionDetailViewController?.valueForDoseSelected = { value in
                self.valueForDose = value!
                if self.validateTheAddConditionValues() && self.valueForVariablesIsNotNull() {
                    self.conditionItem?.change = self.valueForChange as String
                    self.conditionItem?.dose = self.valueForDose as String
                    self.conditionItem?.every = self.valueForEvery as String
                    self.conditionItem?.until = self.valueForUntil as String
                    self.previewDetails = DCDosageHelper.updatePreviewDetailsArray(self.conditionItem!, currentStartingDose: self.newStartingDose!, doseUnit:(self.dosage?.doseUnit)!)
                    if (NSString(string: self.valueForUntil).floatValue > 0) {
                        self.previewDetails.append("\(self.valueForUntil) thereafter")
                    } else {
                        self.previewDetails.append("Stop")
                    }
                }
                self.addConditionTableView.reloadData()
            }
            self.navigationController?.pushViewController(addConditionDetailViewController!, animated: true)
        } else if (indexPath.row == 5) {
            let addConditionDetailViewController : DCAddConditionDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_CONDITION_DETAIL_SBID) as? DCAddConditionDetailViewController
            addConditionDetailViewController!.previousSelectedValue = valueForUntil
            addConditionDetailViewController?.detailType = eUntilDose
            addConditionDetailViewController?.valueForDoseSelected = { value in
                self.valueForUntil = value!
                if self.validateTheAddConditionValues() && self.valueForVariablesIsNotNull(){
                    self.conditionItem?.change = self.valueForChange as String
                    self.conditionItem?.dose = self.valueForDose as String
                    self.conditionItem?.every = self.valueForEvery as String
                    self.conditionItem?.until = self.valueForUntil as String
                    self.previewDetails = DCDosageHelper.updatePreviewDetailsArray(self.conditionItem!, currentStartingDose: self.newStartingDose!, doseUnit:(self.dosage?.doseUnit)!)
                    if (NSString(string: self.valueForUntil).floatValue > 0) {
                        self.previewDetails.append("\(self.valueForUntil) thereafter")
                    } else {
                        self.previewDetails.append("Stop")
                    }
                }
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
                if self.validateTheAddConditionValues() && self.valueForVariablesIsNotNull() {
                    self.conditionItem?.change = self.valueForChange as String
                    self.conditionItem?.dose = self.valueForDose as String
                    self.conditionItem?.every = self.valueForEvery as String
                    self.conditionItem?.until = self.valueForUntil as String
                    self.previewDetails = DCDosageHelper.updatePreviewDetailsArray(self.conditionItem!, currentStartingDose: self.newStartingDose!, doseUnit:(self.dosage?.doseUnit)!)
                    if (NSString(string: self.valueForUntil).floatValue > 0) {
                        self.previewDetails.append("\(self.valueForUntil) thereafter")
                    } else {
                        self.previewDetails.append("Stop")
                    }
                }
                self.addConditionTableView.reloadData()
            }
            return dosageDetailCell!
        } else {
            
            let dosageDetailCell : DCDosageDetailPickerCell? = addConditionTableView.dequeueReusableCellWithIdentifier(DOSE_PICKER_DISPLAY_CELL_ID) as? DCDosageDetailPickerCell
            selectedPickerType = eDailyCount
            dosageDetailCell?.configurePickerCellForPickerType(eDailyCount)
            dosageDetailCell?.pickerCompletion = { value in
                
                if Int(value as! String) == 1 {
                    self.valueForEvery = "\(value!) \(String((self.dosage?.reducingIncreasingDose.changeOver)!.characters.dropLast()).lowercaseString)"
                } else {
                    self.valueForEvery = "\(value!) \(String(UTF8String: (self.dosage?.reducingIncreasingDose.changeOver)!.lowercaseString)!)"
                }
                if self.validateTheAddConditionValues() && self.valueForVariablesIsNotNull() {
                    self.conditionItem?.change = self.valueForChange as String
                    self.conditionItem?.dose = self.valueForDose as String
                    self.conditionItem?.every = self.valueForEvery as String
                    self.conditionItem?.until = self.valueForUntil as String
                    self.previewDetails = DCDosageHelper.updatePreviewDetailsArray(self.conditionItem!, currentStartingDose: self.newStartingDose!, doseUnit:(self.dosage?.doseUnit)!)
                    if (NSString(string: self.valueForUntil).floatValue > 0) {
                        self.previewDetails.append("\(self.valueForUntil) thereafter")
                    } else {
                        self.previewDetails.append("Stop")
                    }
                }
                self.addConditionTableView.reloadData()
            }
            dosageDetailCell?.changeOver = (self.dosage?.reducingIncreasingDose.changeOver)!
            return dosageDetailCell!
        }
    }
    
    func validateTheAddConditionValues() -> Bool {
        if (valueForChange == REDUCING) {
            if (newStartingDose <= NSString(string: valueForUntil).floatValue || NSString(string: valueForDose).floatValue <= 0) {
                return false
            }
        } else {
            if newStartingDose >= NSString(string: valueForUntil).floatValue || NSString(string: valueForDose).floatValue <= 0 || String(valueForUntil).characters.count >= 8 {
                return false
            }
        }
        return true
    }
    
    func valueForVariablesIsNotNull() -> Bool {
    
        if(valueForChange == "" || valueForDose == "" || valueForEvery == "" || valueForUntil == "") {
            return false
        } else {
            return true
        }
    }
    
    // MARK: - Action Methods
    
    func cancelButtonPressed() {
        
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed() {
        
//        var displayString : String = ""
//        var change : String = ""
//        self.conditionItem?.change = valueForChange as String
//        if (valueForChange == "Reducing") {
//            change = "Reduce"
//        } else {
//            change = "Increase"
//        }
//        if (valueForDose != "" && valueForEvery != "" && valueForUntil != "") {
//            displayString = "\(change) \(valueForDose) every \(valueForEvery) until \(valueForUntil)"
//            self.conditionItem?.dose = valueForDose as String
//            self.conditionItem?.every = valueForEvery as String
//            self.conditionItem?.until = valueForUntil as String
//        } else {
//            displayString = ""
//        }
        if self.validateTheAddConditionValues() {
            DCDosageHelper.createDescriptionStringForDosageCondition(conditionItem!, dosageUnit: (self.dosage?.doseUnit)!)
            self.newConditionEntered(self.conditionItem)
        }
        self.navigationController!.dismissViewControllerAnimated(true, completion:nil)
    }
    
}
