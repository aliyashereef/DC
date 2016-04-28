//
//  DCStopMedicationReasonViewController.swift
//  DrugChart
//
//  Created by aliya on 25/04/16.
//
//

import Foundation

class DCStopMedicationReasonViewController : UITableViewController {
    
    let reasonArray = [StopMedicationConstants.ALLERGIC_REACTION,StopMedicationConstants.FORMULARY_SUBSTITUTION,StopMedicationConstants.NO_LONGER_REQUIRED,StopMedicationConstants.PRESCRIBED_IN_ERROR,StopMedicationConstants.FORM_ROUTE_STRENGTH_CHANGE,StopMedicationConstants.OTHERS]
    
    var inactiveDetails : DCInactiveDetails?
    
    override func viewDidLoad() {
         super.viewDidLoad()
        self.navigationItem.title = StopMedicationConstants.REASON
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reasonArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(StopMedicationConstants.REASON_CELL_ID)! as UITableViewCell
        cell.textLabel!.font = UIFont.systemFontOfSize(15.0)
        let reasonString = reasonArray[indexPath.row] as String
        if inactiveDetails?.reason == reasonString {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        cell.textLabel?.text = reasonString
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let reasonString = reasonArray[indexPath.row] as String
        self.inactiveDetails?.reason = reasonString
        self.navigationController?.popViewControllerAnimated(true)
    }
}