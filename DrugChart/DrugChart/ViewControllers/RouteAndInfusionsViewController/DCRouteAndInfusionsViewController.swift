//
//  DCRouteAndInfusionsViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/12/16.
//
//

import UIKit

let DESCRIPTION_LABEL_TRAILING_IN : CGFloat = 18.0
let DESCRIPTION_LABEL_TARINLING_DEFAULT : CGFloat = 3.0
let DESCRITION_LABEL_WIDTH_DEFAULT : CGFloat = 155.0
let DESCRIPTION_LABEL_WIDTH_IN : CGFloat = 225.0
let TABLE_CELL_HEIGHT : CGFloat = 44.0

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
    var inlinePickerIndexPath : NSIndexPath?
    var previousSelectedRouteIndexPath : NSIndexPath?
    
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
                var rowCount = RowCount.eZerothRow.rawValue
                if (infusion!.administerAsOption == DURATION_BASED_INFUSION) {
                    rowCount = RowCount.eFirstRow.rawValue
                } else {
                    rowCount = RowCount.eFourthRow.rawValue
                    if (tableViewHasInlinePickerForSection(section)) {
                        rowCount++
                    }
                }
             return rowCount
            case SectionCount.eThirdSection.rawValue :
                var rowCount = RowCount.eThirdRow.rawValue
                if (tableViewHasInlinePickerForSection(section)) {
                    rowCount++
                }
                return rowCount
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
                if (self.infusion?.administerAsOption == DURATION_BASED_INFUSION) {
                    let infusionCell = self.configureInfusionCellAtIndexPath(indexPath)
                    return infusionCell!
                } else {
                    let tableCell = self.configureSecondSectionOfTableViewForBolusInjectionAtIndexPath(indexPath)
                    return tableCell
                }
            case SectionCount.eThirdSection.rawValue :
                let tableCell = self.configureSolutionInfoCellAtIndexPath(indexPath)
                return tableCell
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
            case SectionCount.eSecondSection.rawValue :
                //present infusion solvent view
                if (indexPath.row == RowCount.eFirstRow.rawValue) {
                    self.displayInfusionSolventView()
                } else if (indexPath.row == RowCount.eSecondRow.rawValue) {
                    self.displayInlinePickerForRowAtIndexPath(indexPath)
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
        if (DCInfusionsHelper.routeIsIntravenous(route) == false) {
            self.infusion?.administerAsOption = nil
            if let infusionDelegate = self.delegate {
                infusionDelegate.updatedInfusionObject(self.infusion!)
            }
            self.navigationController?.popToRootViewControllerAnimated(true)
        } else {
            routesTableView.beginUpdates()
            if (previousSelectedRouteIndexPath != nil) {
                routesTableView.reloadRowsAtIndexPaths([previousSelectedRouteIndexPath!], withRowAnimation: .Fade)
            }
            routesTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            let sectionCount = routesTableView.numberOfSections
            if sectionCount == SectionCount.eFirstSection.rawValue {
                //if section count is zero insert new section with animation
                routesTableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
            }
            routesTableView.endUpdates()
        }
    }
    
    func reloadCellAfterDelayAtIndexPath(indexPath : NSIndexPath) {
        
        //reload cell after delay
        self.routesTableView.beginUpdates()
        self.routesTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        self.routesTableView.endUpdates()
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
            previousSelectedRouteIndexPath = indexPath
            routeCell?.accessoryType = .Checkmark
        } else {
            routeCell?.accessoryType = .None
        }
        return routeCell!
    }
    
    func configureSecondSectionOfTableViewForBolusInjectionAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == RowCount.eZerothRow.rawValue) {
            let bolusCell = self.configureSlowBolusCellIndexPath(indexPath)
            return bolusCell
        } else {
            let tableCell = self.configureSolutionInfoCellAtIndexPath(indexPath)
            return tableCell
        }
    }
    
    func configureSolutionInfoCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        if (self.inlinePickerIndexPath?.row == indexPath.row) {
            let infusionPickerCell = routesTableView.dequeueReusableCellWithIdentifier(INFUSION_PICKER_CELL_ID) as? DCInfusionPickerCell
            infusionPickerCell?.previousValue = self.infusion?.bolusInjection?.quantity
            infusionPickerCell?.unitCompletion = { unit in
                self.infusion?.bolusInjection?.quantity = unit! as String
                self.performSelector(Selector("reloadCellAfterDelayAtIndexPath:"), withObject: NSIndexPath(forRow: 2, inSection: 2), afterDelay: 0.04)
            }
            infusionPickerCell?.configurePickerView()
            return infusionPickerCell!
        } else {
            let infusionCell = self.configureInfusionCellAtIndexPath(indexPath)
            return infusionCell!
        }
    }
    
    func configureInfusionCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell? {
        
        //configure infusions cell
        let infusionCell = routesTableView.dequeueReusableCellWithIdentifier(INFUSIONS_CELL_ID) as? DCInfusionCell
        if (indexPath.section == SectionCount.eFirstSection.rawValue) {
            infusionCell?.titleLabel.text = NSLocalizedString("ADMINISTER_AS", comment: "")
            infusionCell?.descriptionLabel.text = infusion?.administerAsOption
        } else {
            if (self.infusion?.administerAsOption == DURATION_BASED_INFUSION && indexPath.section == SectionCount.eSecondSection.rawValue) {
                infusionCell?.titleLabel.text = NSLocalizedString("OVER", comment: "")
                infusionCell?.descriptionLabel.text = "1 hr"
                infusionCell?.accessoryType = .DisclosureIndicator
            } else {
                switch indexPath.row {
                case RowCount.eFirstRow.rawValue :
                    infusionCell?.accessoryType = .None
                    infusionCell?.titleLabel.text = NSLocalizedString("IN", comment: "")
                    infusionCell?.descriptionLabel.text = infusion?.bolusInjection?.solvent
                    infusionCell?.descriptionTrailingConstraint.constant = DESCRIPTION_LABEL_TRAILING_IN
                    infusionCell?.descriptionLabelWidthConstraint.constant = DESCRIPTION_LABEL_WIDTH_IN
                case RowCount.eSecondRow.rawValue :
                    infusionCell?.accessoryType = .DisclosureIndicator
                    infusionCell?.titleLabel.text = NSLocalizedString("ML", comment: "")
                    infusionCell?.descriptionLabel.text = infusion?.bolusInjection?.quantity
                    infusionCell?.descriptionTrailingConstraint.constant = DESCRIPTION_LABEL_TARINLING_DEFAULT
                    infusionCell?.descriptionLabelWidthConstraint.constant = DESCRITION_LABEL_WIDTH_DEFAULT
                case RowCount.eThirdRow.rawValue :
                    infusionCell?.accessoryType = .DisclosureIndicator
                    infusionCell?.titleLabel.text = NSLocalizedString("INTO", comment: "")
                    infusionCell?.descriptionLabel.text = infusion?.bolusInjection?.injectionRegion
                    infusionCell?.descriptionTrailingConstraint.constant = DESCRIPTION_LABEL_TARINLING_DEFAULT
                default :
                    break
            }
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
        injectionRegionViewController?.injectionRegion = { region in
            self.infusion?.bolusInjection?.injectionRegion = region
            self.routesTableView.reloadData()
        }
        self.navigationController?.pushViewController(injectionRegionViewController!, animated: true)
    }
    
    func presentNavigationControllerWithRootViewController(rootViewController : UIViewController) {
        
        let navigationController = UINavigationController.init(rootViewController: rootViewController)
        navigationController.modalPresentationStyle = .CurrentContext
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func tableViewHasInlinePickerForSection (section : NSInteger) -> Bool {
        
        return (self.inlinePickerIndexPath != nil && section == self.inlinePickerIndexPath?.section)
    }
    
    func displayInlinePickerForRowAtIndexPath(indexPath : NSIndexPath) {
        
        routesTableView.beginUpdates()
        var pickerBeforeSelectedIndexPath = false
        var sameCellClicked = false
        if (self.inlinePickerIndexPath != nil) {
            pickerBeforeSelectedIndexPath = self.inlinePickerIndexPath!.row < indexPath.row
            if (tableViewHasInlinePickerForSection(indexPath.section)) {
                sameCellClicked = (self.inlinePickerIndexPath!.row - 1 == indexPath.row);
            }
            let pickerIndexPath : NSIndexPath = self.inlinePickerIndexPath!
            self.inlinePickerIndexPath = nil
            routesTableView.deleteRowsAtIndexPaths([pickerIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        // remove any picker cell if it exists
        if (!sameCellClicked) {
            // hide the date picker and display the new one
            let rowToReveal : NSInteger = (pickerBeforeSelectedIndexPath ? indexPath.row - 1 : indexPath.row);
            let indexPathToReveal : NSIndexPath = NSIndexPath(forItem: rowToReveal, inSection: indexPath.section)
            togglePickerForSelectedIndexPath(indexPathToReveal)
            self.inlinePickerIndexPath = NSIndexPath(forItem: indexPathToReveal.row + 1, inSection: indexPath.section)
        }
        routesTableView.deselectRowAtIndexPath(indexPath, animated: true)
        routesTableView.endUpdates()
    }
    
    func togglePickerForSelectedIndexPath(indexPath : NSIndexPath) {
        
        // detailTableView.beginUpdates()
        let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
        if (tableViewHasInlinePickerForSection(indexPath.section)) {
            routesTableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            // didn't find a picker below it, so we should insert it
            routesTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }

}
