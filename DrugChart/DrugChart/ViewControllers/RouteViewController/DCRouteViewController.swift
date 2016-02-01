//
//  DCRouteAndInfusionsViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/12/16.
//
//

import UIKit

@objc public protocol RoutesDelegate {
    
    func newRouteSelected(route : NSString)
    func updatedInfusionObject(infusion : DCInfusion)
}

class DCRouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, InfusionDelegate {

    @IBOutlet weak var routesTableView: UITableView!
    var delegate : RoutesDelegate?
    var routesArray : NSMutableArray = []
    var previousRoute : String = EMPTY_STRING
    var infusion : DCInfusion?
    var dosage : DCDosage?
    var patientId : String?
    var inlinePickerIndexPath : NSIndexPath?
    var previousSelectedRouteIndexPath : NSIndexPath?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = NSLocalizedString("ROUTES", comment: "screen title")
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if let infusionDelegate = self.delegate {
            infusionDelegate.updatedInfusionObject(self.infusion!)
        }
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UITableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let sectionCount = DCAddMedicationHelper.routesTableViewSectionCountForSelectedRoute(previousRoute)
        return sectionCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case SectionCount.eZerothSection.rawValue :
                return routesArray.count
            case SectionCount.eFirstSection.rawValue :
                return RowCount.eFirstRow.rawValue
            default :
                return RowCount.eZerothRow.rawValue
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            case SectionCount.eZerothSection.rawValue :
                let routeCell = self.configureZerothSectionOfTableViewAtIndexPath(indexPath)
               return routeCell
            case SectionCount.eFirstSection.rawValue :
                let infusionCell = self.configureInfusionCellAtIndexPath(indexPath)
                return infusionCell!
            default :
                let routeCell = tableView.dequeueReusableCellWithIdentifier(ROUTE_CELL_ID) as? DCRouteCell
                return routeCell!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return (indexPath == self.inlinePickerIndexPath) ? PICKER_CELL_HEIGHT : TABLE_CELL_HEIGHT
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
            case SectionCount.eZerothSection.rawValue :
                self.updateViewForZerothSectionSelectionAtIndexPath(indexPath)
                break
            case SectionCount.eFirstSection.rawValue :
                self.displayAdministerOptionsView()
                break
            default :
                break
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: Private Methods
    
    func updateViewForZerothSectionSelectionAtIndexPath(indexPath : NSIndexPath) {
        
        let route : NSString = routesArray[indexPath.item] as! NSString
        previousRoute = route as String;
        if let routeDelegate = delegate {
            routeDelegate.newRouteSelected(route)
        }
        if (DCAddMedicationHelper.routeIsIntravenousOrSubcutaneous(route as String) == false) {
            self.infusion?.administerAsOption = nil
            if let infusionDelegate = self.delegate {
                infusionDelegate.updatedInfusionObject(self.infusion!)
            }
            self.navigationController?.popToRootViewControllerAnimated(true)
        } else {
            let sectionCount = routesTableView.numberOfSections
            if sectionCount == SectionCount.eFirstSection.rawValue {
                //if section count is zero insert new section with animation
                routesTableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
            }
            if (previousSelectedRouteIndexPath != nil) {
                routesTableView.reloadRowsAtIndexPaths([previousSelectedRouteIndexPath!], withRowAnimation: .Fade)
            }
            routesTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func displayAdministerOptionsView() {
        
        //display administer as options view
        let addMedicationStoryBoard : UIStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let administerOptionsViewController  = addMedicationStoryBoard.instantiateViewControllerWithIdentifier(INFUSIONS_STORYBOARD_ID) as? DCInfusionViewController
        administerOptionsViewController!.previousAdministerOption = infusion?.administerAsOption
        administerOptionsViewController!.infusion = infusion
        administerOptionsViewController!.dosage = dosage
        administerOptionsViewController!.patientId = self.patientId
        administerOptionsViewController!.administerDelegate  = self
        self.navigationController?.pushViewController(administerOptionsViewController!, animated: true)
    }
    
    func configureZerothSectionOfTableViewAtIndexPath(indexPath : NSIndexPath) -> DCRouteCell {
        
        //zeroth section 
        let routeCell = routesTableView.dequeueReusableCellWithIdentifier(ROUTE_CELL_ID) as? DCRouteCell
        let route : NSString = routesArray[indexPath.item] as! NSString
        routeCell?.titleLabel.text = route as String
        if (previousRoute.containsString(route as String) == true) {
            previousSelectedRouteIndexPath = indexPath
            routeCell?.accessoryType = .Checkmark
        } else {
            routeCell?.accessoryType = .None
        }
        return routeCell!
    }
    
    func configureInfusionCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell? {
        
        //configure infusions cell
        let infusionCell = routesTableView.dequeueReusableCellWithIdentifier(INFUSIONS_CELL_ID) as? DCInfusionCell
        infusionCell?.titleLabel.text = NSLocalizedString("ADMINISTER_AS", comment: "")
        infusionCell?.descriptionLabel.text = infusion?.administerAsOption
        return infusionCell!
    }
    
    //MARK : InfusionAdministerDelegate Methods
    
    func administerAsOptionSelected(option : NSString) {
        
        //administer as option value selected,
        self.infusion?.administerAsOption = option as String
        if (option == BOLUS_INJECTION) {
            self.infusion?.bolusInjection = DCBolusInjection.init()
        } else if (option == DURATION_BASED_INFUSION) {
            self.infusion?.durationInfusion = DCDurationInfusion.init()
        } else {
            //rate based infusion
            self.infusion?.rateInfusion = DCRateInfusion.init()
        }
        if let infusionDelegate = self.delegate {
            infusionDelegate.updatedInfusionObject(self.infusion!)
        }
        self.routesTableView.reloadData()
    }
    
    //MARK: Infusion Delegate Methods
    
    func newInfusionObject(newInfusion : DCInfusion) {
        
        self.infusion = newInfusion
        routesTableView.reloadData()
    }

}
