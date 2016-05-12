//
//  DCMedicationListMoreButtonViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 02/05/16.
//
//

import UIKit

let moreButtonActions = [REVIEW_TITLE,MANAGE_SUSPENSION_TITLE]
let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate

typealias ActionForMoreButtonSelected = Int? -> Void

class DCMedicationListMoreButtonViewController: UIViewController {

    @IBOutlet weak var actionListTableView: UITableView!
    var actionForMoreButtonSelected : ActionForMoreButtonSelected = { void in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.hidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
     
        super.viewDidLayoutSubviews()
        if appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    // MARK: - TableView Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return SectionCount.eFirstSection.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return RowCount.eSecondRow.rawValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let displayCell : DCMedicationListMoreButtonTableViewCell = self.confugureCellForDisplay(indexPath)
        return displayCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.dismissViewControllerAnimated(true, completion: { void in })
        self.actionForMoreButtonSelected(indexPath.row)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func confugureCellForDisplay(indexPath: NSIndexPath) -> DCMedicationListMoreButtonTableViewCell {
        
        let cell : DCMedicationListMoreButtonTableViewCell = actionListTableView.dequeueReusableCellWithIdentifier(ACTION_DISPLAY_CELL) as! DCMedicationListMoreButtonTableViewCell
        cell.buttonLabel.text = moreButtonActions[indexPath.row]
        return cell
    }
}
