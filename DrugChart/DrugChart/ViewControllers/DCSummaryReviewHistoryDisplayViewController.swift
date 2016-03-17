//
//  DCSummaryReviewHistoryDisplayViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 14/03/16.
//
//

import UIKit

class DCSummaryReviewHistoryDisplayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var displayDictionary = [String:String]()
    var displayArray = [[String:String]]()
    @IBOutlet weak var historyDisplayTableView: UITableView!
    override func viewDidLoad() {
        
        self.configureNavigationBar()
        self.initializeTemporaryDemoDataForDisplay()
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        
        historyDisplayTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBar() {
        
        self.title = "Review History"
    }
    
    func initializeTemporaryDemoDataForDisplay() {
    
        displayArray = []
        displayDictionary["date"] = "26-Feb-2016"
        displayDictionary["notes"] = "Intake of the medications should be supplemented with proper anti allergens throughout the course of this medication."
        displayArray.append(displayDictionary)
        
        displayDictionary["date"] = "18-Dec-2016"
        displayDictionary["notes"] = "Stop the course if the patient shows any vomiting tendency."
        displayArray.append(displayDictionary)
    }
    
    // MARK: - Tableview Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return displayArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //Set the header as date
        return displayArray[section]["date"]
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("headerCell") as! DCSummaryReviewHistoryTableViewCell
        headerCell.backgroundColor = UIColor.clearColor()
        
        headerCell.headerLabel.text = displayArray[section]["date"]
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (DCUtility.heightValueForText(displayArray[indexPath.section]["notes"], withFont: UIFont.systemFontOfSize(15.0), maxWidth: self.view.bounds.width - 30) + 20) < 79 {
            return 79
        } else {
            return DCUtility.heightValueForText(displayArray[indexPath.section]["notes"], withFont: UIFont.systemFontOfSize(15.0), maxWidth: self.view.bounds.width - 30) + 20
        }
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return configureMedicationDetailsCellAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func configureMedicationDetailsCellAtIndexPath (indexPath :NSIndexPath) -> UITableViewCell {
        
        let cell = historyDisplayTableView.dequeueReusableCellWithIdentifier("reviewHistoryDisplayCell") as? DCSummaryReviewHistoryTableViewCell
        cell!.reviewHistoryDisplayLabel.text = displayArray[indexPath.section]["notes"]
        return cell!
    }
}


