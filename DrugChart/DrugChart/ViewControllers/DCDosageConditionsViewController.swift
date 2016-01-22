//
//  DCDosageConditionsViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 04/01/16.
//
//

import UIKit

class DCDosageConditionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var previewDetailsArray = [String]()
    var previousSelectedValue : NSString = ""
    var dosage : DCDosage?
    var conditionDescriptionArray = [String]()

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
        // Do any additional setup after loading the view.
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
        if (self.dosage?.reducingIncreasingDose?.conditionsArray.count != 0) {
            return 3
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            if self.dosage?.reducingIncreasingDose?.conditionsArray.count != 0 {
                return (self.dosage?.reducingIncreasingDose?.conditionsArray.count)!
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
            if self.dosage?.reducingIncreasingDose?.conditionsArray.count != 0 {
                dosageConditionCell!.conditionsMainLabel.text = conditionDescriptionArray[indexPath.row]
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
            if self.dosage?.reducingIncreasingDose?.conditionsArray.count != 0 {

            } else {
                let addConditionViewController : DCAddConditionViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_CONDITION_SBID) as? DCAddConditionViewController
                addConditionViewController?.newConditionEntered = { value in
                    self.dosage?.reducingIncreasingDose?.conditionsArray.addObject(value!)
                    self.updateConditionDescriptionArray()
                    self.updateMainPreviewDetailsArray()
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

// MARK: - Private Methods

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
        previewDetailsArray = []
        for ( var index = 0; index < self.dosage?.reducingIncreasingDose?.conditionsArray.count; index++) {
            if index == 0 {
                currentStartingDose = NSString(string: (self.dosage?.reducingIncreasingDose?.startingDose)!).floatValue
            } else {
                currentStartingDose = NSString(string: (self.dosage?.reducingIncreasingDose?.conditionsArray[index - 1].until)!).floatValue
            }
            previewDetailsArray.appendContentsOf(DCDosageHelper.updatePreviewDetailsArray((self.dosage?.reducingIncreasingDose?.conditionsArray[index])! as! DCConditions, currentStartingDose: currentStartingDose!, doseUnit: (self.dosage?.doseUnit)!))
        }
        previewDetailsArray.append("Stop")
    }
    
    func updateConditionDescriptionArray () {
        conditionDescriptionArray = []
        for ( var index = 0; index < self.dosage?.reducingIncreasingDose?.conditionsArray.count; index++) {
            conditionDescriptionArray.append(DCDosageHelper.createDescriptionStringForDosageCondition((self.dosage?.reducingIncreasingDose.conditionsArray[index])! as! DCConditions, dosageUnit: (self.dosage?.doseUnit)!))
        }
    }
}
