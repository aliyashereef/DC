//
//  DCInterventionDetailsViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 27/04/16.
//
//

import UIKit

class DCInterventionDetailsViewController: UIViewController {
    
    @IBOutlet weak var interventionTableView: UITableView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = NSLocalizedString("INTERVENTION_DETAILS", comment: "")
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Tableview Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = interventionTableView.dequeueReusableCellWithIdentifier(RESOLVE_INTERVENTION_CELL) as? DCInterventionAddOrResolveTableCell
        switch indexPath.row {
            case RowCount.eZerothRow.rawValue:
                cell!.actionNameTitleLabel.text = NSLocalizedString("CREATED_BY", comment: "")
                cell!.actionDateTitleLabel.text = NSLocalizedString("INTERVENTION_ADDED", comment: "")
            case RowCount.eFirstRow.rawValue:
                cell!.actionNameTitleLabel.text = NSLocalizedString("EDITED_BY" , comment: "")
                cell!.actionDateTitleLabel.text = NSLocalizedString("INTERVENTION_EDITED", comment: "")
            case RowCount.eSecondRow.rawValue:
                cell!.actionNameTitleLabel.text = NSLocalizedString("RESOLVED_BY", comment: "")
                cell!.actionDateTitleLabel.text = NSLocalizedString("INTERVENTION_RESOLVED", comment: "")
            default:
                break
        }
        cell!.reasonTextLabel.text = OK_BUTTON_TITLE
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
