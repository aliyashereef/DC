//
//  DCInterventionAddOrResolveViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 30/03/16.
//
//

import UIKit

class DCInterventionAddOrResolveViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var interventionType : InterventionType?
    var medicationList : NSMutableArray = []
    
    @IBOutlet weak var interventionDisplayTableView: UITableView!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        self.configureNavigationBarItems()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBarItems() {
        
        // Configure bar buttons for Add and Resolve Intervention.
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target: self, action: "cancelButtonPressed")
        self.navigationItem.leftBarButtonItem = cancelButton
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: SAVE_BUTTON_TITLE, style: .Plain, target: self, action: "doneButtonPressed")
        self.navigationItem.rightBarButtonItem = doneButton
        if interventionType == eAddIntervention {
            self.navigationItem.title = ADD_CONDITION_TITLE
            self.title = ADD_CONDITION_TITLE
        } else {
            self.navigationItem.title = ADD_CONDITION_TITLE
            self.title = ADD_CONDITION_TITLE
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if interventionType == eAddIntervention {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 90
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (interventionType!.rawValue) {
        case eAddIntervention.rawValue:
            let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(REASON_RESOLVE_TEXTVIEW_CELL) as? DCInterventionAddResolveTextViewCell
            cell?.initializeTextView(REASON_TEXT)
            return cell!
        case eResolveIntervention.rawValue:
            if indexPath.section == eZerothSection.rawValue {
                let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(RESOLVE_INTERVENTION_CELL) as? DCInterventionAddOrResolveTableCell
                return cell!
            } else {
                let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(REASON_RESOLVE_TEXTVIEW_CELL) as? DCInterventionAddResolveTextViewCell
                cell?.initializeTextView(RESOLUTION_TEXT)
                return cell!
            }
        default:
            let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(REASON_RESOLVE_TEXTVIEW_CELL) as? DCInterventionAddResolveTextViewCell
            return cell!
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func cancelButtonPressed() {
        
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed() {
    
    }
}
