//
//  DCAddConditionDetailViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 05/01/16.
//
//

import UIKit

typealias ValueForDoseSelected = String? -> Void

class DCAddConditionDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var doseArrayForChange = [String]()
    var doseArrayForUntil = [String]()
    var detailType : AddConditionDetailType = eDoseChange
    var previousSelectedValue : NSString = ""
    var valueForDoseSelected: ValueForDoseSelected = { value in }

    @IBOutlet weak var detailTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBarItems()
        doseArrayForUntil.appendContentsOf(doseArrayForChange)
        doseArrayForUntil.append("0 mg")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if let dosageCell: DCAddConditionDetailTableViewCell = detailTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? DCAddConditionDetailTableViewCell {
            if (dosageCell.newDoseTextField.text! != "" && validateNewDosageValue(dosageCell.newDoseTextField.text!)) {
                self.previousSelectedValue = "\(dosageCell.newDoseTextField.text!) mg"
                self.valueForDoseSelected("\(dosageCell.newDoseTextField.text!) mg")
                if self.detailType == eDoseChange {
                    if !self.doseArrayForChange.contains("\(dosageCell.newDoseTextField.text!) mg") {
                        self.doseArrayForChange.append("\(dosageCell.newDoseTextField.text!) mg")
                        self.doseArrayForChange =  self.doseArrayForChange.sort { NSString(string: $0).floatValue > NSString(string: $1).floatValue }
                    }
                } else {
                    if !self.doseArrayForUntil.contains("\(dosageCell.newDoseTextField.text!) mg") {
                        self.doseArrayForUntil.append("\(dosageCell.newDoseTextField.text!) mg")
                        self.doseArrayForUntil =  self.doseArrayForUntil.sort { NSString(string: $0).floatValue > NSString(string: $1).floatValue }
                    }
                }
            }
        }
        self.detailTableView.reloadData()
    }
    
    func configureNavigationBarItems() {
        
        if (detailType == eDoseChange) {
            self.navigationItem.title = DOSE_VALUE_TITLE
            self.title = DOSE_VALUE_TITLE
        } else {
            self.navigationItem.title = UNTIL_TITLE
            self.title = UNTIL_TITLE
        }
    }

    // MARK: - Table View Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if detailType == eDoseChange {
                return doseArrayForChange.count
            } else {
                return doseArrayForUntil.count
            }
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let dosageValueCell : DCAddConditionDetailTableViewCell? = tableView.dequeueReusableCellWithIdentifier(DOSE_VALUE_CELL_ID) as? DCAddConditionDetailTableViewCell
            if detailType == eDoseChange {
                dosageValueCell?.accessoryType = (previousSelectedValue == doseArrayForChange[indexPath.row]) ? .Checkmark : .None
                dosageValueCell!.valueForDoseLabel.text = doseArrayForChange[indexPath.row]
            } else {
                dosageValueCell?.accessoryType = (previousSelectedValue == doseArrayForUntil[indexPath.row]) ? .Checkmark : .None
                dosageValueCell!.valueForDoseLabel.text = doseArrayForUntil[indexPath.row]
            }
            dosageValueCell?.valueForDoseLabel.textColor = UIColor.blackColor()
            return dosageValueCell!
        } else {
            let dosageDetailCell : DCAddConditionDetailTableViewCell? = detailTableView.dequeueReusableCellWithIdentifier(ADD_NEW_VALUE_CELL_ID) as? DCAddConditionDetailTableViewCell
            dosageDetailCell?.accessoryType = .None
            dosageDetailCell?.newDoseTextField.delegate = dosageDetailCell
            return dosageDetailCell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            if detailType == eDoseChange {
                self.valueForDoseSelected(doseArrayForChange[indexPath.row])
            } else {
                self.valueForDoseSelected(doseArrayForUntil[indexPath.row])
            }
            self.navigationController?.popViewControllerAnimated(true)
        case 1:
            break
//            self.transitToAddNewDoseScreen()
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    // MARK: - Private Methods
    
    func transitToAddNewDoseScreen() {
        
        let addNewDosageViewController : DCAddNewDoseAndTimeViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_NEW_DOSE_TIME_SBID) as? DCAddNewDoseAndTimeViewController
        addNewDosageViewController?.detailType = eAddNewDose
        addNewDosageViewController!.newDosageEntered = { value in
            self.previousSelectedValue = "\(value!) mg"
            self.valueForDoseSelected("\(value!) mg")
            if self.detailType == eDoseChange {
                if !self.doseArrayForChange.contains("\(value!) mg") {
                    self.doseArrayForChange.append("\(value!) mg")
                    self.doseArrayForChange =  self.doseArrayForChange.sort { NSString(string: $0).floatValue > NSString(string: $1).floatValue }
                }
            } else {
                if !self.doseArrayForUntil.contains("\(value!) mg") {
                    self.doseArrayForUntil.append("\(value!) mg")
                    self.doseArrayForUntil =  self.doseArrayForUntil.sort { NSString(string: $0).floatValue > NSString(string: $1).floatValue }
                }
            }
            self.detailTableView.reloadData()
        }
        let navigationController: UINavigationController = UINavigationController(rootViewController: addNewDosageViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func validateNewDosageValue (value: String) -> Bool {
        
        let scanner: NSScanner = NSScanner(string:value)
        let isNumeric = scanner.scanDecimal(nil) && scanner.atEnd
        return isNumeric && (NSString(string: value).floatValue < maximumValueOfDose)
    }
}
