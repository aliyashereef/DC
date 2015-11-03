//
//  DCPatientMenuViewController.swift
//  DrugChart
//
//  Created by aliya on 03/11/15.
//
//

import Foundation

// Strings
let drugChart : NSString = "Drug Chart"
let vitalSigns : NSString = "Vital Signs"
let viewTitle : NSString = "Menu"
let menuTableCellIdentifier : NSString = "MenuTableCell"

// DCBaseViewController is a subclass for UIViewController
class DCPatientMenuViewController: DCBaseViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var menuTableView: UITableView!
    var patient : DCPatient = DCPatient.init()
    let menuArray : NSArray = [drugChart,vitalSigns]
    
    override func viewDidLoad() {
        self.title = viewTitle as String
        menuTableView!.tableFooterView = UIView(frame: CGRectZero)
        super.viewDidLoad()
    }
    
    // Table View data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = (tableView.dequeueReusableCellWithIdentifier(menuTableCellIdentifier as String))!
        cell.layoutMargins = UIEdgeInsetsZero
        cell.textLabel!.text = menuArray[indexPath.row] as? String
        return cell
    }
    
    // Table View delegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Go to the drug chart view , we use a helper method to do this.
        if indexPath.row == 0 {
             DCSwiftObjCNavigationHelper.goToPrescriberMedicationViewControllerForPatient(self.patient, fromNavigationController:self.navigationController)
            // Go to the vital signs view.
        } else if indexPath.row == 1 {
            let vitalSignViewController : DCVitalSignViewController? = UIStoryboard(name: PATIENT_MENU_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(VITAL_SIGNS_VIEW_CONTROLLER_VIEW_CONTROLLER_SB_ID) as? DCVitalSignViewController
            self.navigationController!.showViewController(vitalSignViewController!, sender: self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}