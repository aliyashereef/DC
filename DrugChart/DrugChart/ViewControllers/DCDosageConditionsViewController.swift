//
//  DCDosageConditionsViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 04/01/16.
//
//

import UIKit

class DCDosageConditionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var conditionsItemsArray = ["Reduce 50 mg every day"]
    var previewDetailsTable = [String]()
    var previousSelectedValue : NSString = ""
    var reducingIncreasing : DCReducingIncreasingDose?

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.reducingIncreasing?.conditionsArray == nil {
            self.reducingIncreasing?.conditionsArray = []
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
        if (self.reducingIncreasing?.conditionsArray.count != 0) {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            if self.reducingIncreasing?.conditionsArray.count != 0 {
                return (self.reducingIncreasing?.conditionsArray.count)!
            } else {
                return 1
            }
        } else if section == 1 {
            return 1
        } else {
            return previewDetailsTable.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let dosageConditionCell : DCDosageConditionsTableViewCell? = tableView.dequeueReusableCellWithIdentifier(DOSE_CONDITION_CELL_ID) as? DCDosageConditionsTableViewCell
        dosageConditionCell?.conditionsMainLabel.textColor = UIColor.blackColor()
        switch indexPath.section {
        case 0:
            if self.reducingIncreasing?.conditionsArray.count != 0 {
                dosageConditionCell!.conditionsMainLabel.text = self.reducingIncreasing?.conditionsArray[indexPath.row].conditionDescription
            } else {
                dosageConditionCell?.conditionsMainLabel.text = ADD_CONDITION_TITLE
                dosageConditionCell?.conditionsMainLabel.textColor = tableView.tintColor
            }
        case 1:
            dosageConditionCell?.conditionsMainLabel.text = ADD_CONDITION_TITLE
            dosageConditionCell?.conditionsMainLabel.textColor = tableView.tintColor
        default:
            break
        }
            return dosageConditionCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            if self.reducingIncreasing?.conditionsArray.count != 0 {
                
            } else {
                let addConditionViewController : DCAddConditionViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_CONDITION_SBID) as? DCAddConditionViewController
                addConditionViewController?.newConditionEntered = { value in
                    self.reducingIncreasing?.conditionsArray.addObject(value!)
                    tableView.reloadData()
                }
                addConditionViewController!.newStartingDose = self.currentStartingDose()
                let navigationController: UINavigationController = UINavigationController(rootViewController: addConditionViewController!)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
                self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
            }
        case 1:
            let addConditionViewController : DCAddConditionViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_CONDITION_SBID) as? DCAddConditionViewController
            addConditionViewController?.newConditionEntered = { value in
                self.reducingIncreasing?.conditionsArray.addObject(value!)
                tableView.reloadData()
            }
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
        if self.reducingIncreasing?.conditionsArray.count == 0 {
            return NSString(string: (self.reducingIncreasing?.startingDose)!).floatValue
        } else {
            let indexOfLastObject = self.reducingIncreasing?.conditionsArray.indexOfObject((self.reducingIncreasing?.conditionsArray.lastObject)!)
            return NSString(string: (self.reducingIncreasing?.conditionsArray[indexOfLastObject!].until)!).floatValue
        }
    }
}
