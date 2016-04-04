//
//  DCDosageConditionsViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 04/01/16.
//
//

import UIKit

typealias ReducingIncreasingDoseEntered = DCReducingIncreasingDose? -> Void

class DCDosageConditionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    let editButtonColor   = "#719fd3"
    let deleteButtonColor = "#fc5251"
    let EDIT_TEXT         = "Edit"
    let DELETE_TEXT       = "Delete"

    var previewDetailsArray = [String]()
    var dosage : DCDosage?
    var conditionDescriptionArray = [String]()
    var reducingIncreasingDoseEntered: ReducingIncreasingDoseEntered = { value in }
    var isConditionsValid : Bool = true
    var deletedIndexPath : NSIndexPath = NSIndexPath(forRow: 1, inSection:0)

    @IBOutlet weak var conditionTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.dosage?.reducingIncreasingDose?.conditionsArray == nil {
            self.dosage?.reducingIncreasingDose?.conditionsArray = []
        }
        if self.dosage?.reducingIncreasingDose?.conditionsArray.count > 0 {
            self.updateConditionDescriptionArray()
            self.updateMainPreviewDetailsArray()
        }
        self.configureNavigationBarItems()
        conditionTableView.estimatedRowHeight = 44
        conditionTableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        conditionTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBarItems() {
        
            self.navigationItem.title = CONDITIONS_TITLE
            self.title = CONDITIONS_TITLE
    }

    // MARK: - Table View Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (self.dosage?.reducingIncreasingDose?.conditionsArray.count > 0) {
            return 3
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            if self.dosage?.reducingIncreasingDose?.conditionsArray.count > 0 {
                return conditionDescriptionArray.count
            } else {
                return 1
            }
        } else if section == 1 {
            return 1
        } else {
            return previewDetailsArray.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //Set the header as PREVIEW
        if (section == 2 && self.previewDetailsArray.count != 0) {
            return "preview"
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let dosageConditionCell : DCDosageConditionsTableViewCell? = tableView.dequeueReusableCellWithIdentifier(DOSE_CONDITION_CELL_ID) as? DCDosageConditionsTableViewCell
        dosageConditionCell?.conditionsMainLabel.textColor = UIColor.blackColor()
        switch indexPath.section {
        case 0:
            if self.dosage?.reducingIncreasingDose?.conditionsArray.count > 0 {
                dosageConditionCell!.conditionsMainLabel.text = conditionDescriptionArray[indexPath.row]
                if !isConditionsValid && indexPath.row >= deletedIndexPath.row {
                    dosageConditionCell?.conditionsMainLabel.textColor = UIColor.redColor()
                } else {
                    dosageConditionCell?.conditionsMainLabel.textColor = UIColor.blackColor()
                }
            } else {
                dosageConditionCell?.conditionsMainLabel.text = ADD_CONDITION_TITLE
                dosageConditionCell?.conditionsMainLabel.textColor = tableView.tintColor
            }
        case 1:
            dosageConditionCell?.conditionsMainLabel.text = ADD_CONDITION_TITLE
            dosageConditionCell?.conditionsMainLabel.textColor = tableView.tintColor
        case 2:
            dosageConditionCell?.conditionsMainLabel.text = previewDetailsArray[indexPath.row]
        default:
            break
        }
            return dosageConditionCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            if self.dosage?.reducingIncreasingDose?.conditionsArray.count > 0 {

            } else {
                let addConditionViewController : DCAddConditionViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_CONDITION_SBID) as? DCAddConditionViewController
                addConditionViewController?.newConditionEntered = { value in
                    self.dosage?.reducingIncreasingDose?.conditionsArray.addObject(value!)
                    self.updateConditionDescriptionArray()
                    self.updateMainPreviewDetailsArray()
                    self.reducingIncreasingDoseEntered(self.dosage?.reducingIncreasingDose)
                    tableView.reloadData()
                }
                addConditionViewController!.dosage = self.dosage
                addConditionViewController!.newStartingDose = self.currentStartingDose()
                let navigationController: UINavigationController = UINavigationController(rootViewController: addConditionViewController!)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
                self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
            }
        case 1:
            let addConditionViewController : DCAddConditionViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_CONDITION_SBID) as? DCAddConditionViewController
            addConditionViewController?.newConditionEntered = { value in
                self.dosage?.reducingIncreasingDose?.conditionsArray.addObject(value!)
                self.updateConditionDescriptionArray()
                self.updateMainPreviewDetailsArray()
                self.reducingIncreasingDoseEntered(self.dosage?.reducingIncreasingDose)
                tableView.reloadData()
            }
            addConditionViewController!.dosage = self.dosage
            addConditionViewController?.newStartingDose = self.currentStartingDose()
            let navigationController: UINavigationController = UINavigationController(rootViewController: addConditionViewController!)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .Default, title:
            EDIT_TEXT,handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
            self.conditionTableView.setEditing(false, animated: false)
            }
        )
        editAction.backgroundColor = UIColor.init(forHexString:editButtonColor)
        
        let deleteAction = UITableViewRowAction(style: .Normal, title: DELETE_TEXT,
            handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
                self.checkConditionValidityAndDeleteCell(indexPath.row)
            }
        );
        deleteAction.backgroundColor = UIColor.init(forHexString:deleteButtonColor)
        if indexPath.row == 0 {
            return [editAction]
        }
        return [deleteAction, editAction]
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        //Set the header as PREVIEW
        if section == 0 {
            if (!isConditionsValid) {
                return DCDosageHelper.errorStringForInvalidCondition()
            }
        }
        return nil
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        //Change text color to red and change text from full upper case to desired sentence.
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel!.font = UIFont.systemFontOfSize(14.0)
            view.textLabel?.textColor = UIColor.redColor()
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 {
            if (!isConditionsValid) {
                let height: CGFloat = DCUtility.heightValueForText(DCDosageHelper.errorStringForInvalidCondition(), withFont: UIFont.systemFontOfSize(14.0), maxWidth: self.view.bounds.width - 30) + 10
                return height
            }
        }
        return 0
    }
    
// MARK: - Private Methods

    func checkConditionValidityAndDeleteCell(index: Int) {
        if self.dosage?.reducingIncreasingDose?.conditionsArray.count > index+1 {
            if self.dosage?.reducingIncreasingDose?.conditionsArray[index+1].change == REDUCING {
                if (NSString(string: (self.dosage?.reducingIncreasingDose?.conditionsArray[index-1].until)!)).floatValue < (NSString(string: (self.dosage?.reducingIncreasingDose?.conditionsArray[index+1].dose)!)).floatValue {
                    isConditionsValid = false
                } else if ((NSString(string: (self.dosage?.reducingIncreasingDose?.conditionsArray[index-1].until)!)).floatValue == 0){
                    isConditionsValid = false
                } else {
                    isConditionsValid = true
                }
            } else if self.dosage?.reducingIncreasingDose?.conditionsArray[index+1].change == INCREASING {
                if (NSString(string: (self.dosage?.reducingIncreasingDose?.conditionsArray[index-1].until)!)).floatValue >= (NSString(string: (self.dosage?.reducingIncreasingDose?.conditionsArray[index+1].until)!)).floatValue {
                    isConditionsValid = false
                } else {
                    isConditionsValid = true
                }
            }
        } else {
            isConditionsValid = true
        }
        deletedIndexPath = NSIndexPath(forRow: index, inSection:0)
        deleteObjectAtIndex(index)
        self.conditionTableView.reloadData()
    }
    
    func deleteObjectAtIndex (index: Int) {
        self.conditionTableView.beginUpdates()
        if self.dosage?.reducingIncreasingDose?.conditionsArray.count > 0 {
            self.dosage?.reducingIncreasingDose?.conditionsArray?.removeObjectAtIndex(index)
            self.updateConditionDescriptionArray()
            self.updateMainPreviewDetailsArray()
        }
        let section : NSIndexSet = NSIndexSet(index:2)
        self.conditionTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow:index, inSection:0)], withRowAnimation: .Automatic);
        self.conditionTableView.reloadSections(section, withRowAnimation: .None)
        self.conditionTableView.endUpdates()
    }
    
    func currentStartingDose() -> Float {
        if self.dosage?.reducingIncreasingDose?.conditionsArray.count == 0 {
            return NSString(string: (self.dosage?.reducingIncreasingDose?.startingDose)!).floatValue
        } else {
            let indexOfLastObject = self.dosage?.reducingIncreasingDose?.conditionsArray.indexOfObject((self.dosage?.reducingIncreasingDose?.conditionsArray.lastObject)!)
            return NSString(string: (self.dosage?.reducingIncreasingDose?.conditionsArray[indexOfLastObject!].until)!).floatValue
        }
    }
    
    func updateMainPreviewDetailsArray () {
    
        var currentStartingDose : Float?
        let lastIndexOfArray : Int = (self.dosage?.reducingIncreasingDose.conditionsArray.count)! - 1
        previewDetailsArray = []
        for ( var index = 0; index < self.dosage?.reducingIncreasingDose?.conditionsArray.count; index++) {
            if index == 0 {
                currentStartingDose = NSString(string: (self.dosage?.reducingIncreasingDose?.startingDose)!).floatValue
            } else {
                currentStartingDose = NSString(string: (self.dosage?.reducingIncreasingDose?.conditionsArray[index - 1].until)!).floatValue
            }
            previewDetailsArray.appendContentsOf(DCDosageHelper.updatePreviewDetailsArray((self.dosage?.reducingIncreasingDose?.conditionsArray[index])! as! DCConditions, currentStartingDose: currentStartingDose!, doseUnit: (self.dosage?.doseUnit)!))
        }
        if (NSString(string: (self.dosage?.reducingIncreasingDose?.conditionsArray[lastIndexOfArray].until)!)).floatValue > 0 {
            self.previewDetailsArray.append("\(self.dosage!.reducingIncreasingDose!.conditionsArray[lastIndexOfArray].until) thereafter")
        } else {
            self.previewDetailsArray.append("Stop")
        }
    }
    
    func updateConditionDescriptionArray () {
        conditionDescriptionArray = []
        for ( var index = 0; index < self.dosage?.reducingIncreasingDose?.conditionsArray.count; index++) {
            conditionDescriptionArray.append(DCDosageHelper.createDescriptionStringForDosageCondition((self.dosage?.reducingIncreasingDose.conditionsArray[index])! as! DCConditions, dosageUnit: (self.dosage?.doseUnit)!))
        }
    }
}
