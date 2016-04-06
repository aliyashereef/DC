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
    
    var newStartingDose : Float?
    var selectedPickerType : PickerType?
    var newConditionEntered: NewConditionEntered = { value in }
    var conditionItem : DCConditions?
    var dosage : DCDosage?
    var previewDetails = [String]()
    var doseArrayForChange = ["500 mg","250 mg","100 mg","50 mg","10 mg","5 mg"]
    var alertMessagForMismatch : String = EMPTY_STRING
    var isEditCondition : Bool = false
    var doneClicked : Bool = false
    
    @IBOutlet weak var addConditionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isEditCondition {
            conditionItem = DCConditions.init()
        }
        self.configureNavigationBarItems()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        self.navigationController?.navigationBar.frame = DCUtility.navigationBarFrameForNavigationController(self.navigationController)
        self.preferredContentSize = DCUtility.popOverPreferredContentSize()
        self.navigationController!.preferredContentSize = DCUtility.popOverPreferredContentSize()
    }

    func configureNavigationBarItems() {
        
        // Configure bar buttons for Add new.
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target: self, action: "cancelButtonPressed")
        self.navigationItem.leftBarButtonItem = cancelButton
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: SAVE_BUTTON_TITLE, style: .Plain, target: self, action: "doneButtonPressed")
        self.navigationItem.rightBarButtonItem = doneButton
        if !isEditCondition {
            self.navigationItem.title = ADD_CONDITION_TITLE
            self.title = ADD_CONDITION_TITLE
        } else {
            self.navigationItem.title = EDIT_CONDITION_TITLE
            self.title = EDIT_CONDITION_TITLE
        }
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
            return 5
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
            } else {
                return 44
            }
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //Set the header as PREVIEW
        if section == 0 && alertMessagForMismatch != EMPTY_STRING {
            return alertMessagForMismatch
        } else if (section == 1 && self.previewDetails.count != 0) {
            return "preview"
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        //Change text color to red and change text from full upper case to desired sentence.
        if let view = view as? UITableViewHeaderFooterView {
            
            if (section == 0 && self.alertMessagForMismatch != EMPTY_STRING) {
                view.textLabel!.font = UIFont.systemFontOfSize(14.0)
                view.textLabel?.text = alertMessagForMismatch
                view.textLabel?.textColor = UIColor.redColor()
            } else {
                view.textLabel?.textColor = UIColor.grayColor()
            }
        }
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            if alertMessagForMismatch != EMPTY_STRING {
                return 44
            } else {
                return 0
            }
        }
        return 44
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        //Set the header as PREVIEW
        if section == 0 {
            if (self.previewDetails.count != 0 && self.validateTheAddConditionValues()) {
                return DCDosageHelper.createDescriptionStringForDosageCondition(conditionItem!, dosageUnit: (self.dosage?.doseUnit)!)
            }
        }
        return nil
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        //Change text color to red and change text from full upper case to desired sentence.
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel!.font = UIFont.systemFontOfSize(14.0)
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 {
            if (self.previewDetails.count != 0 && self.validateTheAddConditionValues()) {
                    let height: CGFloat = DCUtility.heightValueForText(DCDosageHelper.createDescriptionStringForDosageCondition(conditionItem!, dosageUnit: (self.dosage?.doseUnit)!), withFont: UIFont.systemFontOfSize(14.0), maxWidth: self.view.bounds.width - 30) + 25
                    return height
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let dosageConditionCell : DCAddConditionTableViewCell? = tableView.dequeueReusableCellWithIdentifier(ADD_CONDITION_MENU_CELL_ID) as? DCAddConditionTableViewCell
            dosageConditionCell?.addConditionMenuLabel.textColor = UIColor.blackColor()
            switch indexPath.row {
            case 0:
                dosageConditionCell!.addConditionMenuLabel.text = addConditionMenuItems[0]
                dosageConditionCell?.addConditionValueLabel.text = (conditionItem?.change)! as String
                if doneClicked {
                    if (conditionItem?.change)! == EMPTY_STRING {
                        dosageConditionCell?.addConditionMenuLabel.textColor = UIColor.redColor()
                    } else {
                        dosageConditionCell?.addConditionMenuLabel.textColor = UIColor.blackColor()
                    }
                } else {
                    dosageConditionCell?.addConditionMenuLabel.textColor = UIColor.blackColor()
                }
            case 2:
                dosageConditionCell!.addConditionMenuLabel.text = addConditionMenuItems[1]
                dosageConditionCell?.addConditionValueLabel.text = (conditionItem?.dose)! as String
                if doneClicked {
                    if (conditionItem?.dose)! == EMPTY_STRING {
                        dosageConditionCell?.addConditionMenuLabel.textColor = UIColor.redColor()
                    } else {
                        dosageConditionCell?.addConditionMenuLabel.textColor = UIColor.blackColor()
                    }
                } else {
                    dosageConditionCell?.addConditionMenuLabel.textColor = UIColor.blackColor()
                }
            case 3:
                dosageConditionCell!.addConditionMenuLabel.text = addConditionMenuItems[2]
                dosageConditionCell?.addConditionValueLabel.text = (conditionItem?.every)! as String
                if doneClicked {
                    if (conditionItem?.every)! == EMPTY_STRING {
                        dosageConditionCell?.addConditionMenuLabel.textColor = UIColor.redColor()
                    } else {
                        dosageConditionCell?.addConditionMenuLabel.textColor = UIColor.blackColor()
                    }
                } else {
                    dosageConditionCell?.addConditionMenuLabel.textColor = UIColor.blackColor()
                }
            case 4:
                dosageConditionCell!.addConditionMenuLabel.text = addConditionMenuItems[3]
                dosageConditionCell?.addConditionValueLabel.text = (conditionItem?.until)! as String
                if doneClicked {
                    if (conditionItem?.until)! == EMPTY_STRING {
                        dosageConditionCell?.addConditionMenuLabel.textColor = UIColor.redColor()
                    } else {
                        dosageConditionCell?.addConditionMenuLabel.textColor = UIColor.blackColor()
                    }
                } else {
                    dosageConditionCell?.addConditionMenuLabel.textColor = UIColor.blackColor()
                }
            case 1:
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
                //Same Clicked
                inlinePickerForChangeActive = false
                let indexPaths = [NSIndexPath(forItem: 1, inSection: indexPath.section)]
                addConditionTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
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
                let indexPathOfChange = NSIndexPath(forItem: indexPath.row + 1, inSection: 0)
                let pickerCell : DCDosageDetailPickerCell = addConditionTableView.cellForRowAtIndexPath(indexPathOfChange) as! DCDosageDetailPickerCell
                pickerCell.currentValueForPickerCell(eReducingIncreasingType)
                inlinePickerForChangeActive = true
                let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
                addConditionTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            }
        } else if (indexPath.row == 2) {
            let addConditionDetailViewController : DCAddConditionDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_CONDITION_DETAIL_SBID) as? DCAddConditionDetailViewController
            addConditionDetailViewController!.previousSelectedValue = (conditionItem?.dose)!
            addConditionDetailViewController?.detailType = eDoseChange
            addConditionDetailViewController?.doseArrayForChange = doseArrayForChange
            addConditionDetailViewController?.valueForDoseSelected = { value in
                self.conditionItem?.dose! = value!
                if !self.doseArrayForChange.contains(value!) && NSString(string: value!).floatValue != 0 {
                    self.doseArrayForChange.append(value!)
                    self.doseArrayForChange =  self.doseArrayForChange.sort { NSString(string: $0).floatValue > NSString(string: $1).floatValue }
                }
                self.updatePreviewDetails()
                self.addConditionTableView.reloadData()
            }
            self.navigationController?.pushViewController(addConditionDetailViewController!, animated: true)
        } else if (indexPath.row == 3) {
            let addMedicationStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
            let addNewValueViewController = addMedicationStoryboard.instantiateViewControllerWithIdentifier(ADD_NEW_VALUE_SBID) as? DCAddNewValueViewController
            addNewValueViewController?.backButtonTitle = ADD_CONDITION_TITLE
            addNewValueViewController?.titleString = "Every"
            addNewValueViewController?.placeHolderString = (self.dosage?.reducingIncreasingDose.changeOver)!
            if (conditionItem?.every)! != EMPTY_STRING {
                addNewValueViewController?.previousValue = (conditionItem?.every)! as String
            }
            addNewValueViewController!.newValueEntered = { value in
                if Int(value!) == 1 {
                    self.conditionItem?.every = "\(value!) \(String((self.dosage?.reducingIncreasingDose.changeOver)!.characters.dropLast()).lowercaseString)"
                } else {
                    self.conditionItem?.every = "\(value!) \(String(UTF8String: (self.dosage?.reducingIncreasingDose.changeOver)!.lowercaseString)!)"
                }
                self.updatePreviewDetails()
                self.addConditionTableView.reloadData()
            }
            self.navigationController?.pushViewController(addNewValueViewController!, animated: true)
        } else if (indexPath.row == 4) {
            let addConditionDetailViewController : DCAddConditionDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_CONDITION_DETAIL_SBID) as? DCAddConditionDetailViewController
            addConditionDetailViewController!.previousSelectedValue = (conditionItem?.until!)!
            addConditionDetailViewController?.detailType = eUntilDose
            addConditionDetailViewController?.doseArrayForChange = doseArrayForChange
            addConditionDetailViewController?.valueForDoseSelected = { value in
                self.conditionItem?.until! = value!
                if !self.doseArrayForChange.contains(value!) && NSString(string: value!).floatValue != 0 {
                    self.doseArrayForChange.append(value!)
                    self.doseArrayForChange =  self.doseArrayForChange.sort { NSString(string: $0).floatValue > NSString(string: $1).floatValue }
                }
                self.updatePreviewDetails()
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
                
                self.conditionItem?.change = value! as String
                self.updatePreviewDetails()
                self.addConditionTableView.reloadData()
            }
            return dosageDetailCell!
        } else {
            
            let dosageDetailCell : DCDosageDetailPickerCell? = addConditionTableView.dequeueReusableCellWithIdentifier(DOSE_PICKER_DISPLAY_CELL_ID) as? DCDosageDetailPickerCell
            selectedPickerType = eDailyCount
            dosageDetailCell?.configurePickerCellForPickerType(eDailyCount)
            dosageDetailCell?.pickerCompletion = { value in
                
                if Int(value as! String) == 1 {
                    self.conditionItem?.every = "\(value!) \(String((self.dosage?.reducingIncreasingDose.changeOver)!.characters.dropLast()).lowercaseString)"
                } else {
                    self.conditionItem?.every = "\(value!) \(String(UTF8String: (self.dosage?.reducingIncreasingDose.changeOver)!.lowercaseString)!)"
                }
                self.updatePreviewDetails()
                self.addConditionTableView.reloadData()
            }
            dosageDetailCell?.changeOver = (self.dosage?.reducingIncreasingDose.changeOver)!
            return dosageDetailCell!
        }
    }
    
    func validateTheAddConditionValues() -> Bool {
        if (self.conditionItem?.change == REDUCING) {
            if (newStartingDose! <= NSString(string: (self.conditionItem?.until)!).floatValue || NSString(string: (self.conditionItem?.dose)!).floatValue <= 0) {
                return false
            }
        } else {
            if newStartingDose >= NSString(string: (self.conditionItem?.until)!).floatValue || NSString(string: (self.conditionItem?.dose)!).floatValue <= 0 || self.conditionItem?.until!.characters.count >= 8 {
                return false
            }
        }
        return true
    }
    
    func valueForVariablesIsNotNull() -> Bool {
    
        if((self.conditionItem?.until)! == EMPTY_STRING || (self.conditionItem?.dose)! == EMPTY_STRING || (self.conditionItem?.every)! == EMPTY_STRING || (self.conditionItem?.change)! == EMPTY_STRING) {
            return false
        } else {
            return true
        }
    }
    
    func updatePreviewDetails () {
        
        if self.valueForVariablesIsNotNull() {
            self.updateAlertMessageForMismatch()
            if self.validateTheAddConditionValues() {
                self.previewDetails = DCDosageHelper.updatePreviewDetailsArray(self.conditionItem!, currentStartingDose: self.newStartingDose!, doseUnit:(self.dosage?.doseUnit)!)
                if (NSString(string: (self.conditionItem?.until)!).floatValue > 0) {
                    let untilValue = (self.conditionItem?.until)!
                    self.previewDetails.append("\(untilValue) thereafter")
                } else {
                    self.previewDetails.append("Stop")
                }
            }
        }
    }
    
    func updateAlertMessageForMismatch() {
        let newStartingDoseString : String = String(format: newStartingDose! == floor(newStartingDose!) ? "%.0f" : "%.1f", newStartingDose!)
        if ((self.conditionItem?.change)! == REDUCING) {
            if (newStartingDose <= NSString(string: (self.conditionItem?.until)!).floatValue || NSString(string: (self.conditionItem?.dose)!).floatValue <= 0) {
                alertMessagForMismatch = "Starting dose for the condition is \(newStartingDoseString) \(self.dosage!.doseUnit). Please enter a valid value for Until."
            } else {
                alertMessagForMismatch = EMPTY_STRING
            }
        } else {
            if newStartingDose >= NSString(string: (self.conditionItem?.until)!).floatValue || NSString(string: (self.conditionItem?.dose)!).floatValue <= 0 || String((self.conditionItem?.until)!).characters.count >= 8 {
                alertMessagForMismatch = "Starting dose for the condition is \(newStartingDoseString) \(self.dosage!.doseUnit). Please enter a valid value for Until."
            } else {
                alertMessagForMismatch = EMPTY_STRING
            }
        }
        addConditionTableView.headerViewForSection(0)?.textLabel?.text = alertMessagForMismatch
        addConditionTableView.reloadData()
    }
    
    // MARK: - Action Methods
    
    func cancelButtonPressed() {
        if isEditCondition {
            self.newConditionEntered(self.conditionItem)
        }
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed() {
        doneClicked = true;
        if self.valueForVariablesIsNotNull() {
            if self.validateTheAddConditionValues() {
                DCDosageHelper.createDescriptionStringForDosageCondition(conditionItem!, dosageUnit: (self.dosage?.doseUnit)!)
                self.newConditionEntered(self.conditionItem)
                self.navigationController!.dismissViewControllerAnimated(true, completion:nil)
            } else {
                alertMessagForMismatch = EMPTY_STRING
                self.updateAlertMessageForMismatch()
                addConditionTableView.reloadData()
            }
        } else {
            addConditionTableView.reloadData()
        }
    }
}
