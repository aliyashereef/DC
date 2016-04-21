//
//  DCSummaryAdministrationHistoryViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 14/03/16.
//
//

import UIKit

class DCSummaryAdministrationHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var medicationType = String()
    var displayDictionary = [String:String]()
    var displayArray = [[String:String]]()
    @IBOutlet weak var historyDisplayTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.initializeTemporaryDemoDataForDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBar() {
        
        self.title = "Administration History"
    }

    func initializeTemporaryDemoDataForDisplay() {
        
        displayArray = []
        if medicationType == ONCE_MEDICATION {
            displayDictionary["date"] = "28-Nov-2015"
            displayDictionary["time"] = "15:00"
            displayDictionary["status"] = "Administered"
            displayArray.append(displayDictionary)
        } else if medicationType == WHEN_REQUIRED_VALUE {
            
            displayDictionary["date"] = "14-Mar-2016"
            displayDictionary["time"] = "10:00"
            displayDictionary["status"] = "Administered"
            displayArray.append(displayDictionary)
            
            displayDictionary["date"] = "26-Jan-2016"
            displayDictionary["time"] = "14:00"
            displayDictionary["status"] = "Administered"
            displayArray.append(displayDictionary)

            displayDictionary["date"] = "16-Nov-2015"
            displayDictionary["time"] = "18:00"
            displayDictionary["status"] = "Administered"
            displayArray.append(displayDictionary)
        } else {
            
            var currentDate: NSDate = NSDate()
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            var count : Int = 15
            var randomNumber : Int = 0
            while count > 0 {
                currentDate = currentDate.dateByAddingTimeInterval(-60 * 60 * 24)
                displayDictionary["date"] = dateFormatter.stringFromDate(currentDate)
                displayDictionary["time1"] = "10:00"
                randomNumber = Int(arc4random_uniform(21))
                if randomNumber % 2 == 0 || randomNumber % 3 == 0 {
                    displayDictionary["status1"] = "Administered"
                } else {
                    displayDictionary["status1"] = "Not Administered"
                }
                
                displayDictionary["time2"] = "14:00"
                randomNumber = Int(arc4random_uniform(21))
                if randomNumber % 2 == 0 || randomNumber % 3 == 0 {
                    displayDictionary["status2"] = "Administered"
                } else {
                    displayDictionary["status2"] = "Not Administered"
                }

                displayDictionary["time3"] = "20:00"
                randomNumber = Int(arc4random_uniform(21))
                if randomNumber % 2 == 0 || randomNumber % 3 == 0 {
                    displayDictionary["status3"] = "Administered"
                } else {
                    displayDictionary["status3"] = "Not Administered"
                }

                displayArray.append(displayDictionary)
                count -= 1
            }
        }
    }
    
    // MARK: - Tableview Methods

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return displayArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if medicationType == WHEN_REQUIRED_VALUE || medicationType == ONCE_MEDICATION {
            return 1
        } else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //Set the header as date
        return displayArray[section]["date"]
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("headerCell") as! DCSummaryAdministrationHistoryTableViewCell
        headerCell.backgroundColor = UIColor.clearColor()
        
        headerCell.headerLabel.text = displayArray[section]["date"]!
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return configureMedicationDetailsCellAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Private Methods

    func configureMedicationDetailsCellAtIndexPath (indexPath :NSIndexPath) -> UITableViewCell {
        
        let cell = historyDisplayTableView.dequeueReusableCellWithIdentifier("statusDisplayCell") as? DCSummaryAdministrationHistoryTableViewCell
        if medicationType == WHEN_REQUIRED_VALUE || medicationType == ONCE_MEDICATION {
            cell?.timeLabel.text = displayArray[indexPath.section]["time"]
            cell?.statusLabel.text = displayArray[indexPath.section]["status"]
        } else {
            if indexPath.row == 0 {
                cell?.timeLabel.text = displayArray[indexPath.section]["time1"]
                cell?.statusLabel.text = displayArray[indexPath.section]["status1"]
            } else if indexPath.row == 1 {
                cell?.timeLabel.text = displayArray[indexPath.section]["time2"]
                cell?.statusLabel.text = displayArray[indexPath.section]["status2"]
            } else {
                cell?.timeLabel.text = displayArray[indexPath.section]["time3"]
                cell?.statusLabel.text = displayArray[indexPath.section]["status3"]
            }

        }
        return cell!
    }
}
