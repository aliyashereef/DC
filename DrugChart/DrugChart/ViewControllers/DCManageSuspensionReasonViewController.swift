//
//  DCManageSuspensionReasonViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 12/05/16.
//
//

import UIKit

let reasonList = ["Pending Procedure", "Awaiting Confirmation", "Pending Test Result", "Nil by Mouth", "Clinical Reason", "Other"]

class DCManageSuspensionReasonViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var selectedIndexPath : NSIndexPath?
    var manageSuspensionDetails : DCManageSuspensionDetails?
    var manageSuspensionUpdated: ManageSuspensionUpdated = { value in }

    @IBOutlet weak var manageSuspensionReasonTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = REASON_TEXT
        self.configureInitialView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(true)
        self.manageSuspensionUpdated(manageSuspensionDetails)
    }

    func configureInitialView() {
        
        if manageSuspensionDetails?.reason != nil {
            let indexOfSelectedReason = reasonList.indexOf(manageSuspensionDetails!.reason)
            selectedIndexPath = NSIndexPath(forRow: indexOfSelectedReason!, inSection: SectionCount.eZerothSection.rawValue)
        }
        manageSuspensionReasonTableView.reloadData()
    }

    // MARK: - TableView Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return SectionCount.eFirstSection.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return RowCount.eSixthRow.rawValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let displayCell = self.confugureCellForDisplay(indexPath)
        return displayCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.actionForCellSelectedAtIndexPath(indexPath)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func confugureCellForDisplay(indexPath : NSIndexPath) -> UITableViewCell {

        let cell : DCManageSuspensionReasonTableViewCell = manageSuspensionReasonTableView.dequeueReusableCellWithIdentifier(REASON_CELL_ID) as! DCManageSuspensionReasonTableViewCell
        cell.reasonLabel.text = reasonList[indexPath.row]
        if selectedIndexPath == indexPath {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    func actionForCellSelectedAtIndexPath(indexPath : NSIndexPath) {
    
        selectedIndexPath = indexPath
        manageSuspensionDetails?.reason = reasonList[indexPath.row]
        manageSuspensionReasonTableView.reloadData()
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
