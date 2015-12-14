//
//  DCDosageDetailViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 11/12/15.
//
//

import UIKit

let dosageUnitTitle : NSString = "Unit"
let dosageValueTitle : NSString = "Dose"
let dosageFromTitle : NSString = "From"
let dosageToTitle : NSString = "To"
let dosageDetailDisplayCell : NSString = "dosageDetailCell"
let doseDetailDisplayCellID : NSString = "dosageDetailDisplay"
let addNewLabel : NSString = "Add new"
let dosageUnitItems = ["mg","ml","%"]

// protocol used for sending data back
protocol DataEnteredDelegate: class {
    
    func userDidSelectDosageUnit(value: String)
    func userDidSelectDosageValue(value: String)
}

class DCDosageDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var dosageDetailTableView: UITableView!
    var detailType : DosageDetailType = eDoseUnit
    var viewTitleForDisplay : NSString = ""
    var previousSelectedValue : NSString = ""
    var dosageDetailsArray = [String]()
    weak var delegate: DataEnteredDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavigationBarItems()
//        dosageDetailTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBarItems() {
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Default)
        
        switch (detailType.rawValue) {
            
        case eDoseUnit.rawValue:
            viewTitleForDisplay = dosageUnitTitle
        case eDoseValue.rawValue:
            viewTitleForDisplay = dosageValueTitle
        case eDoseFrom.rawValue:
            viewTitleForDisplay = dosageFromTitle
        case eDoseTo.rawValue:
            viewTitleForDisplay = dosageToTitle
        default:
            break
        }
        self.navigationItem.title = viewTitleForDisplay as String
        self.title = viewTitleForDisplay as String
    }

    // MARK: - TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        if (detailType == eDoseUnit) {
            
            return 1
        } else {
            
            return 2
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (detailType == eDoseUnit) {
            
            return 3
        } else if (section == 0) {
            
            return dosageDetailsArray.count
        } else {
            
            return 1 
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        if (indexPath.section == 0) {
            
            let dosageDetailCell : DCDosageDetailTableViewCell? = dosageDetailTableView.dequeueReusableCellWithIdentifier(dosageDetailDisplayCell as String) as? DCDosageDetailTableViewCell
            // Configure the cell...
            switch (detailType.rawValue) {
                
            case eDoseUnit.rawValue:
                dosageDetailCell?.accessoryType = (previousSelectedValue == dosageUnitItems[indexPath.row]) ? .Checkmark : .None
                dosageDetailCell!.dosageDetailDisplayCell.text = dosageUnitItems[indexPath.row]
            case eDoseValue.rawValue:
                dosageDetailCell?.accessoryType = (previousSelectedValue == dosageDetailsArray[indexPath.row]) ? .Checkmark : .None
                dosageDetailCell!.dosageDetailDisplayCell.text = dosageDetailsArray[indexPath.row]
            case eDoseFrom.rawValue:
                dosageDetailCell?.accessoryType = (previousSelectedValue == dosageDetailsArray[indexPath.row]) ? .Checkmark : .None
                dosageDetailCell!.dosageDetailDisplayCell.text = dosageDetailsArray[indexPath.row]
            case eDoseTo.rawValue:
                dosageDetailCell?.accessoryType = (previousSelectedValue == dosageDetailsArray[indexPath.row]) ? .Checkmark : .None
                dosageDetailCell!.dosageDetailDisplayCell.text = dosageDetailsArray[indexPath.row]

            default:
                break
            }
            return dosageDetailCell!
        } else {
            
            let dosageDetailDisplayCell : DCDosageDetailTableViewCell? = dosageDetailTableView.dequeueReusableCellWithIdentifier(doseDetailDisplayCellID as String) as? DCDosageDetailTableViewCell
            dosageDetailDisplayCell?.dosageDetailCellLabel.text = addNewLabel as String
            return dosageDetailDisplayCell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) { 
    
        switch (detailType.rawValue) {
            
        case eDoseUnit.rawValue:
            delegate?.userDidSelectDosageUnit(dosageUnitItems[indexPath.row])
            self.navigationController?.popViewControllerAnimated(true)
        case eDoseValue.rawValue,eDoseFrom.rawValue,eDoseTo.rawValue:
            delegate?.userDidSelectDosageValue(dosageDetailsArray[indexPath.row])
            self.navigationController?.popViewControllerAnimated(true)

        default:
            break
        }
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
