//
//  AdministratingDoseViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 19/04/16.
//
//

import UIKit

class AdministratingDoseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var rowCountOfTable: Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowCountOfTable
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == SectionCount.eFirstSection.rawValue {
            return CGFloat(TEXT_VIEW_CELL_HEIGHT)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == RowCount.eZerothRow.rawValue {
            let cell = tableView.dequeueReusableCellWithIdentifier(POD_STATUS_CELL) as? DCPodStatusTableViewCell
            cell?.podStatusLabel.text = podStatusArray[indexPath.row]
            return cell!
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(POD_NOTES_CELL_ID) as? DCInterventionAddResolveTextViewCell
            cell!.placeHolderString = REASON
            cell?.initializeTextView()
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
