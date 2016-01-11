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
        
            self.navigationItem.title = CONDITIONS_TITLE
            self.title = CONDITIONS_TITLE
    }

    // MARK: - Table View Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return conditionsItemsArray.count
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
            dosageConditionCell!.conditionsMainLabel.text = conditionsItemsArray[indexPath.row]
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
        case 1:
            let addConditionViewController : DCAddConditionViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_CONDITION_SBID) as? DCAddConditionViewController
            addConditionViewController?.newConditionEntered = { value in
                self.conditionsItemsArray.append(value!)
                tableView.reloadData()
            }
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

}
