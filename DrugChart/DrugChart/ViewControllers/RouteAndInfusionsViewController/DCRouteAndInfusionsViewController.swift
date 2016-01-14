//
//  DCRouteAndInfusionsViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/12/16.
//
//

import UIKit

@objc public protocol RoutesAndInfusionsDelegate {
    
    func newRouteSelected(route : NSString)
    func updatedInfusionObject(infusion : DCInfusion)
}

class DCRouteAndInfusionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, InfusionAdministerDelegate {

    @IBOutlet weak var routesTableView: UITableView!
    var delegate : RoutesAndInfusionsDelegate?
    var routesArray : [String]? = []
    var previousRoute : String = EMPTY_STRING
    var infusion : DCInfusion?
    var patientId : String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = NSLocalizedString("ROUTES", comment: "screen title")
        routesArray = (DCPlistManager.medicationRoutesList() as? [String])!
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UITableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let sectionCount = DCInfusionsHelper.routesAndInfusionsSectionCountForSelectedRoute(previousRoute, infusion: self.infusion!)
        return sectionCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case SectionCount.eZerothSection.rawValue :
                return (routesArray?.count)!
            case SectionCount.eFirstSection.rawValue :
                return RowCount.eFirstRow.rawValue
            case SectionCount.eSecondSection.rawValue :
                return RowCount.eFourthRow.rawValue
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
            case SectionCount.eSecondSection.rawValue :
                if (indexPath.row == RowCount.eZerothRow.rawValue) {
                    let bolusCell = self.configureSlowBolusCellIndexPath(indexPath)
                    return bolusCell
                } else {
                    let infusionCell = self.configureInfusionCellAtIndexPath(indexPath)
                    return infusionCell!
                }
            default :
                let routeCell = tableView.dequeueReusableCellWithIdentifier(ROUTE_CELL_ID) as? DCRouteCell
                return routeCell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
            case SectionCount.eZerothSection.rawValue :
                self.updateViewForZerothSectionSelectionAtIndexPath(indexPath)
                break
            case SectionCount.eFirstSection.rawValue :
                self.displayAdministerOptionsView()
                break
            case SectionCount.eSecondSection.rawValue :
                //present infusion solvent view
                if (indexPath.row == RowCount.eFirstRow.rawValue) {
                    self.displayInfusionSolventView()
                } else if (indexPath.row == RowCount.eThirdRow.rawValue) {
                    self.displayInjectionRegionView()
                }
                break
            default :
                break
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: Private Methods
    
    func updateViewForZerothSectionSelectionAtIndexPath(indexPath : NSIndexPath) {
        
        let route : NSString = routesArray![indexPath.item]
        previousRoute = route as String;
        if let routeDelegate = delegate {
            routeDelegate.newRouteSelected(route)
        }
        routesTableView.beginUpdates()
        routesTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        if (DCInfusionsHelper.routeIsIntravenous(route)) {
            let sectionCount = routesTableView.numberOfSections
            if sectionCount == SectionCount.eFirstSection.rawValue {
                //if section count is zero insert new section with animation
                routesTableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
            }
            routesTableView.endUpdates()
        } else {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func displayAdministerOptionsView() {
        
        //display administer as options view
        let addMedicationStoryBoard : UIStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let administerOptionsViewController  = addMedicationStoryBoard.instantiateViewControllerWithIdentifier(INFUSIONS_ADMINISTER_OPTIONS_SB_ID) as? DCInfusionsAdministerAsViewController
        administerOptionsViewController!.previousAdministerOption = infusion?.administerAsOption
        administerOptionsViewController!.administerDelegate  = self
        self.navigationController?.pushViewController(administerOptionsViewController!, animated: true)
    }
    
    func configureZerothSectionOfTableViewAtIndexPath(indexPath : NSIndexPath) -> DCRouteCell {
        
        //zeroth section 
        let routeCell = routesTableView.dequeueReusableCellWithIdentifier(ROUTE_CELL_ID) as? DCRouteCell
        let route : NSString = routesArray![indexPath.item]
        routeCell?.titleLabel.text = route as String
        let range = route.rangeOfString(" ")
        let croppedString = route.substringToIndex(range.location)
        if (previousRoute.containsString(croppedString) == true) {
            routeCell?.accessoryType = .Checkmark
        } else {
            routeCell?.accessoryType = .None
        }
        return routeCell!
    }
    
    func configureInfusionCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell? {
        
        //configure infusions cell
        let infusionCell = routesTableView.dequeueReusableCellWithIdentifier(INFUSIONS_CELL_ID) as? DCInfusionCell
        if (indexPath.section == SectionCount.eFirstSection.rawValue) {
            infusionCell?.titleLabel.text = NSLocalizedString("ADMINISTER_AS", comment: "")
            infusionCell?.descriptionLabel.text = infusion?.administerAsOption
        } else {
            switch indexPath.row {
                case RowCount.eFirstRow.rawValue :
                    infusionCell?.accessoryType = .None
                    infusionCell?.titleLabel.text = NSLocalizedString("IN", comment: "")
                    infusionCell?.descriptionLabel.text = infusion?.bolusInjection?.solvent
                case RowCount.eSecondRow.rawValue :
                    infusionCell?.accessoryType = .DisclosureIndicator
                    infusionCell?.titleLabel.text = NSLocalizedString("ML", comment: "")
                    infusionCell?.descriptionLabel.text = infusion?.bolusInjection?.quantity
                case RowCount.eThirdRow.rawValue :
                    infusionCell?.accessoryType = .DisclosureIndicator
                    infusionCell?.titleLabel.text = NSLocalizedString("INTO", comment: "")
                    infusionCell?.descriptionLabel.text = infusion?.bolusInjection?.injectionRegion
                default :
                    break
            }
        }
        return infusionCell!
    }
    
    func configureSlowBolusCellIndexPath(indexPath : NSIndexPath) -> DCSlowBolusCell {
        
        //configure slow bolus cell
        let bolusCell = routesTableView.dequeueReusableCellWithIdentifier(SLOW_BOLUS_CELL_ID) as? DCSlowBolusCell
        if let switchState = self.infusion?.bolusInjection?.slowBolus {
            bolusCell?.bolusSwitch.on = switchState
        }
        bolusCell?.switchState = { state in
            let switchValue : Bool = state!
            self.infusion?.bolusInjection?.slowBolus = switchValue
            if let infusionDelegate = self.delegate {
                infusionDelegate.updatedInfusionObject(self.infusion!)
            }
        }
        return bolusCell!
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
    
    func displayInfusionSolventView() {
        
        //display infusion in view
        let addMedicationStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let infusionSolventViewController = addMedicationStoryboard.instantiateViewControllerWithIdentifier(MEDICATION_LIST_STORYBOARD_ID) as? DCMedicationListViewController
        infusionSolventViewController?.patientId = self.patientId
        infusionSolventViewController?.title = NSLocalizedString("IN", comment: "")
        infusionSolventViewController?.selectedMedication = { (medication, warnings) in
            self.infusion?.bolusInjection?.solvent = medication.name
            self.routesTableView.reloadData()
        }
        self.presentNavigationControllerWithRootViewController(infusionSolventViewController!)
    }
    
    func displayInjectionRegionView() {
        
        //injection region view
        let addMedicationStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let injectionRegionViewController = addMedicationStoryboard.instantiateViewControllerWithIdentifier(INJECTION_REGION_SB_ID) as? DCInjectionRegionViewController
        injectionRegionViewController?.previousRegion = infusion?.bolusInjection?.injectionRegion
        self.navigationController?.pushViewController(injectionRegionViewController!, animated: true)
    }
    
    func presentNavigationControllerWithRootViewController(rootViewController : UIViewController) {
        
        let navigationController = UINavigationController.init(rootViewController: rootViewController)
        navigationController.modalPresentationStyle = .CurrentContext
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
    }
    
}
