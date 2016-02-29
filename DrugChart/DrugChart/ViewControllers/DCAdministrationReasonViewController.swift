//
//  DCAdministrationReasonViewController.swift
//  DrugChart
//
//  Created by aliya on 24/02/16.
//
//

import Foundation


protocol reasonDelegate {
    
    func reasonSelected(reason : String)
}

class DCAdministrationReasonViewController : UIViewController {
    
    var delegate: reasonDelegate?
    var administrationStatus : String?
    let successReasonArray = ["Nurse Administered","Patient Declared Administered","Supervised Self Administered","Covertly Administered","IV Access Lost","Vomitted","Partial Administration"]
    let failureReasonArray = ["Omitted","Patient Refused","Nil by Mouth","Drug Unavailable","Not Administered other"]
    var previousSelection : String?
    //MARK: TableView Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (administrationStatus!) {
        case NOT_ADMINISTRATED :
            return failureReasonArray.count
        default:
            return successReasonArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StatusReasonCell")! as UITableViewCell
        switch (administrationStatus!) {
        case NOT_ADMINISTRATED :
            cell.textLabel?.text = failureReasonArray[indexPath.row]
            cell.accessoryType = (previousSelection == failureReasonArray[indexPath.row]) ? .Checkmark : .None

        default:
            cell.textLabel?.text = successReasonArray[indexPath.row]
            cell.accessoryType = (previousSelection == successReasonArray[indexPath.row]) ? .Checkmark : .None

        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var reasonString = EMPTY_STRING
        switch (administrationStatus!) {
        case NOT_ADMINISTRATED :
            reasonString = failureReasonArray[indexPath.row]
        default:
            reasonString = successReasonArray[indexPath.row]
        }
        if (self.delegate != nil) {
            self.delegate?.reasonSelected(reasonString)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

    
}