//
//  DCPharmacistActionPopOverViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 26/04/16.
//
//

import UIKit

typealias PharmacistActionSelectedAtIndex = Int? -> Void

let clinicalCheckActionItems = [CLINICAL_CHECK,CLINICAL_REMOVE]
let interventionActionItems = [ADD_INTERVENTION,EDIT_INTERVENTION,RESOLVE_INTERVENTION]
let updatePodStatusActionItems = [UPDATE_POD_STATUS]
let supplyRequestActionItems = [ADD_SUPPLY_REQUEST,CANCEL_SUPPLY_REQUEST]

class DCPharmacistActionPopOverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var barButtonActionsTableView: UITableView!
    var actionType : PharmacistBarButtonActionType?
    var pharmacistActionSelectedAtIndex : PharmacistActionSelectedAtIndex = { value in }
    var fontSize : CGFloat = 15
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate

    override func viewDidLoad() {
  
        super.viewDidLoad()
        self.navigationController!.navigationBar.hidden = true
    }

    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        if appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
       
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return SectionCount.eFirstSection.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if actionType == eIntervention {
            return RowCount.eThirdRow.rawValue
        } else if actionType == eUpdatePodStatus{
            return RowCount.eFirstRow.rawValue
        } else {
            return RowCount.eSecondRow.rawValue
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let displayCell : DCPharmacistActionPopOverTableViewCell = self.confugureCellForDisplay(indexPath)
        return displayCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.dismissViewControllerAnimated(true, completion: { void in
            self.pharmacistActionSelectedAtIndex(indexPath.row)
        })
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func confugureCellForDisplay(indexPath: NSIndexPath) -> DCPharmacistActionPopOverTableViewCell {
        
        let cell : DCPharmacistActionPopOverTableViewCell = barButtonActionsTableView.dequeueReusableCellWithIdentifier(ACTION_DISPLAY_CELL) as! DCPharmacistActionPopOverTableViewCell
        cell.textLabel?.font = UIFont.systemFontOfSize(fontSize)
        switch actionType!.rawValue {
        case eClinicalCheck.rawValue:
            cell.textLabel?.text = clinicalCheckActionItems[indexPath.row]
        case eIntervention.rawValue:
            cell.textLabel?.text = interventionActionItems[indexPath.row]
        case eUpdatePodStatus.rawValue:
            cell.textLabel?.text = updatePodStatusActionItems[indexPath.row]
        case eSupplyRequest.rawValue:
            cell.textLabel?.text = supplyRequestActionItems[indexPath.row]
        default:
            break
        }
        return cell
    }
}
