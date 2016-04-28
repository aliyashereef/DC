//
//  DCOneThirdScreenPharmacistActionsViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 27/04/16.
//
//

import UIKit

typealias OneThirdPharmacistActionSelected = NSIndexPath? -> Void

class DCOneThirdScreenPharmacistActionsViewController: UIViewController {
    
    @IBOutlet weak var actionDisplayTableView: UITableView!
    var fontSize : CGFloat = 15
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
    var oneThirdPharmacistActionSelected :OneThirdPharmacistActionSelected = { value in }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureNavigationBarProperties()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBarProperties() {
        
        self.title = "Pharmacy Actions"
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target: self, action: #selector(DCAddConditionViewController.cancelButtonPressed))
        self.navigationItem.rightBarButtonItem = cancelButton
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        if appDelegate.windowState == DCWindowState.twoThirdWindow || appDelegate.windowState == DCWindowState.fullWindow {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: - TableView Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return SectionCount.eFourthSection.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == eFirstSection.rawValue {
            return RowCount.eThirdRow.rawValue
        } else if section == eSecondSection.rawValue{
            return RowCount.eFirstRow.rawValue
        } else {
            return RowCount.eSecondRow.rawValue
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //Set the header as PREVIEW
        switch section {
        case SectionCount.eZerothSection.rawValue:
            return CLINICAL_CHECK
        case SectionCount.eFirstSection.rawValue:
            return INTERVENTION_TEXT
        case SectionCount.eSecondSection.rawValue:
            return UPDATE_POD_STATUS
        case SectionCount.eThirdSection.rawValue:
            return SUPPLY_REQUEST
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let displayCell : DCOneThirdScreenPharmacistActionsTableViewCell = self.confugureCellForDisplay(indexPath)
        return displayCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.dismissViewControllerAnimated(true, completion: { void in
        })
        self.oneThirdPharmacistActionSelected(indexPath)
    }
    
    func confugureCellForDisplay(indexPath: NSIndexPath) -> DCOneThirdScreenPharmacistActionsTableViewCell {
        
        let cell : DCOneThirdScreenPharmacistActionsTableViewCell = actionDisplayTableView.dequeueReusableCellWithIdentifier(ACTION_DISPLAY_CELL) as! DCOneThirdScreenPharmacistActionsTableViewCell
        cell.textLabel?.font = UIFont.systemFontOfSize(fontSize)
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            cell.textLabel?.text = clinicalCheckActionItems[indexPath.row]
        case SectionCount.eFirstSection.rawValue:
            cell.textLabel?.text = interventionActionItems[indexPath.row]
        case SectionCount.eSecondSection.rawValue:
            cell.textLabel?.text = updatePodStatusActionItems[indexPath.row]
        case SectionCount.eThirdSection.rawValue:
            cell.textLabel?.text = supplyRequestActionItems[indexPath.row]
        default:
            break
        }
        return cell
    }
    
    func cancelButtonPressed() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
