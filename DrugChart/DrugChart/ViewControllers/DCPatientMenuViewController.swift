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
    
    //MARK: View Management Methods

    override func viewDidLoad() {
        self.title = viewTitle as String
        menuTableView!.tableFooterView = UIView(frame: CGRectZero)
        super.viewDidLoad()
    }
    
    //MARK: Table View Data Source Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = (tableView.dequeueReusableCellWithIdentifier(menuTableCellIdentifier as String))!
        cell.layoutMargins = UIEdgeInsetsZero
        cell.textLabel!.text = menuArray[indexPath.row] as? String
        return cell
    }
    
    //MARK: Table View Delegate Methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
            //Go to the drug chart view : we use a helper method to do this.
        case 0 :
            DCSwiftObjCNavigationHelper.goToPrescriberMedicationViewControllerForPatient(self.patient, fromNavigationController:self.navigationController)
            break
            // Go to the vital signs view.
        case 1:
            let vitalSignViewController : VitalsignDashboard? = UIStoryboard(name: PATIENT_MENU_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(VITAL_SIGNS_VIEW_CONTROLLER_VIEW_CONTROLLER_SB_ID) as? VitalsignDashboard
            self.navigationController!.showViewController(vitalSignViewController!, sender: self)
            break
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}