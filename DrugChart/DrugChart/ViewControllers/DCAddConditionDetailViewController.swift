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
            let newDosageCell : DCAddConditionDetailTableViewCell? = tableView.dequeueReusableCellWithIdentifier(ADD_NEW_DOSE_CELL_ID) as? DCAddConditionDetailTableViewCell
            newDosageCell?.newDoseLabel.text = ADD_NEW_TITLE
            newDosageCell?.accessoryType = .None
            newDosageCell?.newDoseLabel.textColor = tableView.tintColor
            return newDosageCell!
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
            self.transitToAddNewDoseScreen()
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
            if self.detailType == eDoseChange {
                if !self.doseArrayForChange.contains("\(value!) mg") {
                    self.valueForDoseSelected("\(value!) mg")
                    self.doseArrayForChange.append("\(value!) mg")
                    self.doseArrayForChange =  self.doseArrayForChange.sort { NSString(string: $0).floatValue > NSString(string: $1).floatValue }
                }
            } else {
                if !self.doseArrayForUntil.contains("\(value!) mg") {
                    self.valueForDoseSelected("\(value!) mg")
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
    
}
