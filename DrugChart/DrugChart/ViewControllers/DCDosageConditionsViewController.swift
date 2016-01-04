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
    var addConditionMenuItems = ["Change","Dose","Every","Until"]
    var doseForTimeArray = ["250","100","50","30","20","10"]
    var doseArrayForAddCondition = ["500 mg","250 mg","100 mg","50 mg","10 mg","5 mg"]
    var doseUntilArrayForAddCondition = [String]()
    var previewDetailsTable = [String]()
    var viewTitleForDisplay : NSString = ""
    var previousSelectedValue : NSString = ""
    var valueForChange : NSString = ""
    var valueForDose : NSString = ""
    var valueForEvery : NSString = ""
    var valueForUntil : NSString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBarItems()
        doseUntilArrayForAddCondition.appendContentsOf(doseArrayForAddCondition)
        doseUntilArrayForAddCondition.append("0 mg")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBarItems() {
        
            viewTitleForDisplay = CONDITIONS_TITLE
            self.navigationItem.title = viewTitleForDisplay as String
            self.title = viewTitleForDisplay as String
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
        switch indexPath.section {
        case 0:
            dosageConditionCell!.conditionsMainLabel.text = conditionsItemsArray[indexPath.row]
        case 1:
            dosageConditionCell?.conditionsMainLabel.text = "Add Condition"
        default:
            break
        }
            return dosageConditionCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
