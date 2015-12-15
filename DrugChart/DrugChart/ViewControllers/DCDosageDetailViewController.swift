//
//  DCDosageDetailViewController.swift
//  DrugChart
//
//  Created by Shaheer on 11/12/15.
//
//

import UIKit

let dosageUnitTitle : NSString = "Unit"
let dosageValueTitle : NSString = "Dose"
let dosageFromTitle : NSString = "From"
let dosageToTitle : NSString = "To"
let newDosageTitle : NSString = "Add Dosage"
let dosageDetailDisplayCell : NSString = "dosageDetailCell"
let doseDetailDisplayCellID : NSString = "dosageDetailDisplay"
let newDosageCellID : NSString = "newDosageCell"
let addNewLabel : NSString = "Add new"
let dosageUnitItems = ["mg","ml","%"]

// protocol used for sending data back to Dosage Selection
protocol DataEnteredDelegate: class {
    
    func userDidSelectDosageUnit(value: String)
    func userDidSelectDosageValue(value: String)
    func newDosageAdded(value : String)
}

// protocol used for sending data back to Dosage Detail
protocol newDosageEntered: class {
    
    func prepareForTransitionBackToSelection(value: String)
}


class DCDosageDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, newDosageEntered {
    
    @IBOutlet weak var dosageDetailTableView: UITableView!
    var detailType : DosageDetailType = eDoseUnit
    var viewTitleForDisplay : NSString = ""
    var previousSelectedValue : NSString = ""
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
        
        if (detailType == eAddNewDosage) {
            
            // Configure bar buttons for Add new.
            let cancelButton: UIBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target: self, action: "cancelButtonPressed")
            self.navigationItem.leftBarButtonItem = cancelButton
            let doneButton: UIBarButtonItem = UIBarButtonItem(title: DONE_BUTTON_TITLE, style: .Plain, target: self, action: "doneButtonPressed")
            self.navigationItem.rightBarButtonItem = doneButton
            
            self.navigationItem.title = newDosageTitle as String
            self.title = newDosageTitle as String
        } else {
            
            // Configure navigation title.
            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Default)
            
            switch (detailType.rawValue) {
                
            case eDoseUnit.rawValue:
                viewTitleForDisplay = dosageUnitTitle
            case eDoseValue.rawValue:
                viewTitleForDisplay = dosageValueTitle
            case eDoseFrom.rawValue:
                viewTitleForDisplay = dosageFromTitle
            case eDoseTo.rawValue:
                viewTitleForDisplay = dosageToTitle
            default:
                break
            }
            self.navigationItem.title = viewTitleForDisplay as String
            self.title = viewTitleForDisplay as String
        }
    }
    
    // MARK: - TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (detailType == eDoseUnit || detailType == eAddNewDosage || dosageDetailsArray.count == 0) {
            
            return 1
        } else {
            
            return 2
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (detailType == eDoseUnit && dosageDetailsArray.count != 0 ) {
            
            return 3
        } else if (section == 0 && detailType != eAddNewDosage && dosageDetailsArray.count != 0) {
            
            return dosageDetailsArray.count
        } else {
            
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (detailType == eAddNewDosage) {
            
            let dosageDetailCell : DCDosageDetailTableViewCell? = dosageDetailTableView.dequeueReusableCellWithIdentifier(newDosageCellID as String) as? DCDosageDetailTableViewCell
            return dosageDetailCell!
        } else {
            if (indexPath.section == 0 && dosageDetailsArray.count != 0 ) {
                
                let dosageDetailCell : DCDosageDetailTableViewCell? = dosageDetailTableView.dequeueReusableCellWithIdentifier(dosageDetailDisplayCell as String) as? DCDosageDetailTableViewCell
                // Configure the cell...
                switch (detailType.rawValue) {
                    
                case eDoseUnit.rawValue:
                    dosageDetailCell?.accessoryType = (previousSelectedValue == dosageUnitItems[indexPath.row]) ? .Checkmark : .None
                    dosageDetailCell!.dosageDetailDisplayCell.text = dosageUnitItems[indexPath.row]
                case eDoseValue.rawValue:
                    dosageDetailCell?.accessoryType = (previousSelectedValue == dosageDetailsArray[indexPath.row]) ? .Checkmark : .None
                    dosageDetailCell!.dosageDetailDisplayCell.text = dosageDetailsArray[indexPath.row]
                case eDoseFrom.rawValue:
                    dosageDetailCell?.accessoryType = (previousSelectedValue == dosageDetailsArray[indexPath.row]) ? .Checkmark : .None
                    dosageDetailCell!.dosageDetailDisplayCell.text = dosageDetailsArray[indexPath.row]
                case eDoseTo.rawValue:
                    dosageDetailCell?.accessoryType = (previousSelectedValue == dosageDetailsArray[indexPath.row]) ? .Checkmark : .None
                    dosageDetailCell!.dosageDetailDisplayCell.text = dosageDetailsArray[indexPath.row]
                    //Todo : Cases for Reducing/Increasing, Split Daily.
                default:
                    break
                }
                return dosageDetailCell!
            } else {
                
                let dosageDetailCell : DCDosageDetailTableViewCell? = dosageDetailTableView.dequeueReusableCellWithIdentifier(doseDetailDisplayCellID as String) as? DCDosageDetailTableViewCell
                dosageDetailCell?.dosageDetailCellLabel.text = addNewLabel as String
                return dosageDetailCell!
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0 && dosageDetailsArray.count != 0) {
            
            switch (detailType.rawValue) {
                
            case eDoseUnit.rawValue:
                delegate?.userDidSelectDosageUnit(dosageUnitItems[indexPath.row])
                self.navigationController?.popViewControllerAnimated(true)
            case eDoseValue.rawValue,eDoseFrom.rawValue,eDoseTo.rawValue:
                delegate?.userDidSelectDosageValue(dosageDetailsArray[indexPath.row])
                self.navigationController?.popViewControllerAnimated(true)
                //Todo : cases for reducing/increasing, split daily.
            default:
                break
            }
        } else {
            
            let dosageDetailViewController : DCDosageDetailViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(DOSAGE_DETAIL_SBID) as? DCDosageDetailViewController
            dosageDetailViewController?.newDosageDelegate = self
            dosageDetailViewController?.detailType = eAddNewDosage
            let navigationController: UINavigationController = UINavigationController(rootViewController: dosageDetailViewController!)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Action Methods
    
    func cancelButtonPressed() {
        
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed() {
        
        let dosageCell: DCDosageDetailTableViewCell = dosageDetailTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DCDosageDetailTableViewCell
        if (dosageCell.addNewDosageTextField.text! != "") {
            newDosageDelegate?.prepareForTransitionBackToSelection(dosageCell.addNewDosageTextField.text!)
            self.navigationController!.dismissViewControllerAnimated(true, completion:nil)
        }
    }
    
    // MARK: - Delegate Methods
    
    func prepareForTransitionBackToSelection (value: String) {
        
        delegate?.newDosageAdded(value)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
