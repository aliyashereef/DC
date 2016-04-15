//
//  DCAddNewValueViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 02/02/16.
//
//

import UIKit

typealias NewValueEntered = String? -> Void

class DCAddNewValueViewController: DCBaseViewController , UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var detailType : ValueType = eAddIntegerValue
    var placeHolderString : String = EMPTY_STRING
    var unitArray = [String]()
    var titleString : String = EMPTY_STRING
    var textFieldValue : String = EMPTY_STRING
    var valueForUnit : String = EMPTY_STRING
    var backButtonTitle : String = EMPTY_STRING
    var isInlinePickerActive : Bool = false
    var newValueEntered: NewValueEntered = { value in }
    var previousValue : String = EMPTY_STRING
    var previousValueInFloat : Float = 0
    @IBOutlet weak var mainTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        if detailType == eAddIntegerValue {
            if previousValue != EMPTY_STRING {
                previousValueInFloat = NSString(string: previousValue).floatValue
                textFieldValue = String(format: previousValueInFloat == floor(previousValueInFloat) ? "%.0f" : "%.1f", previousValueInFloat)
            } else {
                textFieldValue = EMPTY_STRING
            }
        } else {
            if previousValue != EMPTY_STRING {
                let arrayOfValueAndUnit: [AnyObject] = previousValue.componentsSeparatedByString(" ")
                let lastIndex : Int = arrayOfValueAndUnit.endIndex - 1
                textFieldValue = arrayOfValueAndUnit[lastIndex - 1] as! String
                valueForUnit = arrayOfValueAndUnit[lastIndex] as! String
            } else {
                textFieldValue = EMPTY_STRING
                valueForUnit = unitArray[0]
            }
        }
        self.configureNavigationBar()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        self.navigationController?.navigationBar.frame = DCUtility.navigationBarFrameForNavigationController(self.navigationController)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        let newValueCell : DCAddNewValueTableViewCell = mainTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DCAddNewValueTableViewCell
        textFieldValue = newValueCell.newValueTextField.text!
        if detailType == eAddIntegerValue {
            if textFieldValue != EMPTY_STRING {
                self.newValueEntered(textFieldValue)
            }
        }
        else {
            if textFieldValue != EMPTY_STRING && valueForUnit != EMPTY_STRING {
                let number: Int? = Int(textFieldValue)
                if number > 1 {
                    self.newValueEntered("\(textFieldValue) \(valueForUnit)")
                }
                else {
                    let unit = String(valueForUnit.characters.dropLast())
                    self.newValueEntered("\(textFieldValue) \(unit)")
                }
            } else {
                self.newValueEntered(nil)
            }
        }
    }
    
    func configureNavigationBar() {
        
        DCUtility.backButtonItemForViewController(self, inNavigationController: self.navigationController, withTitle:backButtonTitle as String)
        self.navigationItem.title = titleString
        self.title = titleString
    }

    // MARK: - Table View Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (detailType == eAddIntegerValue){
            return 1
        } else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let newValueTableCell : DCAddNewValueTableViewCell = (mainTableView.dequeueReusableCellWithIdentifier(VALUE_TEXTFIELD_CELL) as? DCAddNewValueTableViewCell)!
            newValueTableCell.newValueTextField.placeholder = placeHolderString
            if textFieldValue != EMPTY_STRING {
                newValueTableCell.newValueTextField.text = textFieldValue
            }
            newValueTableCell.newValueTextField.becomeFirstResponder()
           // newValueTableCell.newValueTextField.delegate = self
            return newValueTableCell
        } else if indexPath.row == 1 {
            let newValueTableCell : DCAddNewValueTableViewCell = (mainTableView.dequeueReusableCellWithIdentifier(PICKER_DROP_DOWN_CELL) as? DCAddNewValueTableViewCell)!
            newValueTableCell.unitLabel.text = "Unit"
            newValueTableCell.unitValueLabel.text = valueForUnit
            if isInlinePickerActive == false {
                newValueTableCell.preservesSuperviewLayoutMargins = false
                newValueTableCell.separatorInset = UIEdgeInsetsZero
                newValueTableCell.layoutMargins = UIEdgeInsetsZero
            }
            return newValueTableCell
        } else {
            let pickerCell : DCAddNewValuePickerCell = (mainTableView.dequeueReusableCellWithIdentifier(PICKER_CELL) as? DCAddNewValuePickerCell)!
            pickerCell.configurePickerCellWithValues(unitArray)
            if detailType == eAddValueWithUnit {
                if valueForUnit != EMPTY_STRING {
                    pickerCell.selectPickerViewForValue(valueForUnit)
                }
            }
            pickerCell.pickerCompletion = { value in
                self.valueForUnit = value!
                self.mainTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
            }
            pickerCell.preservesSuperviewLayoutMargins = false
            pickerCell.separatorInset = UIEdgeInsetsZero
            pickerCell.layoutMargins = UIEdgeInsetsZero
            return pickerCell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.resignKeyboard()
        switch indexPath.row {
        case 0:
            break
        case 1:
            if isInlinePickerActive {
                isInlinePickerActive = false
            } else {
                isInlinePickerActive = true
            }
            self.displayInlinePickerForUnit(indexPath)
        case 2:
            if isInlinePickerActive {
            } else {
            }
        default :
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        switch indexPath.row {
        case 0:
            return 44
        case 1:
            return 44
        case 2:
            if isInlinePickerActive {
                return 217
            } else {
                return 0
            }
        default :
            return 0
        }
    }
    
    // MARK: - Private Methods
    
    func displayInlinePickerForUnit(indexPath: NSIndexPath) {
        
        let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section), NSIndexPath(forItem: indexPath.row, inSection: indexPath.section)]
        mainTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
    }
    
    func resignKeyboard() {
        
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        let valueTextFieldCell : DCAddNewValueTableViewCell = (mainTableView.cellForRowAtIndexPath(indexPath) as? DCAddNewValueTableViewCell)!
        if valueTextFieldCell.newValueTextField.isFirstResponder() {
            valueTextFieldCell.newValueTextField.resignFirstResponder()
        }
    }
    
    func closeInlinePickers () {
        
        if isInlinePickerActive == true {
            let previousPickerIndexPath = NSIndexPath(forItem: RowCount.eFirstRow.rawValue , inSection: SectionCount.eZerothSection.rawValue)
            self.displayInlinePickerForUnit(previousPickerIndexPath)
        }
    }
    
    func keyboardDidShow(notification : NSNotification) {
        
        closeInlinePickers()
    }
}
