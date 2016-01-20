//
//  DCInfusionsAdministerAsViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/13/16.
//
//

import UIKit

protocol InfusionAdministerDelegate {
    
  //  func administerAsOptionSelected(option : NSString)
    func newInfusionObject(infusion : DCInfusion)
}


class DCInfusionsAdministerAsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var administerOptionsTableView: UITableView!
    var optionsArray : [String]? = []
    var previousAdministerOption : String? = EMPTY_STRING
    var administerDelegate : InfusionAdministerDelegate?
    var previousAdministerOptionIndexPath : NSIndexPath?
    var infusion : DCInfusion?
    var inlinePickerIndexPath : NSIndexPath?
    var patientId : String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = NSLocalizedString("ADMINISTER_AS", comment: "screen title")
        optionsArray = [BOLUS_INJECTION, DURATION_BASED_INFUSION, RATE_BASED_INFUSION]
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if let delegate = administerDelegate {
            delegate.newInfusionObject(self.infusion!)
        }
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    //MARK: TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let sectionCount = DCInfusionsHelper.infusionsTableViewSectionCount(self.infusion?.administerAsOption)
        return sectionCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case SectionCount.eZerothSection.rawValue :
            return RowCount.eThirdRow.rawValue
        case SectionCount.eFirstSection.rawValue :
            var rowCount = RowCount.eZerothRow.rawValue
            if (infusion?.administerAsOption == DURATION_BASED_INFUSION) {
                rowCount = RowCount.eFirstRow.rawValue
            } else {
                rowCount = RowCount.eFourthRow.rawValue
                if (tableViewHasInlinePickerForSection(section)) {
                    rowCount++
                }
            }
            return rowCount
        default :
            return RowCount.eZerothRow.rawValue
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            case SectionCount.eZerothSection.rawValue :
                let optionsCell = tableView.dequeueReusableCellWithIdentifier(INFUSIONS_ADMINISTER_AS_CELL_ID) as? DCInfusionsAdministerAsCell
                let option = optionsArray![indexPath.item]
                optionsCell?.titleLabel.text = option
                if (option == previousAdministerOption) {
                    optionsCell?.accessoryType = .Checkmark
                    previousAdministerOptionIndexPath = indexPath
                } else {
                    optionsCell?.accessoryType = .None
                }
                return optionsCell!
            case SectionCount.eFirstSection.rawValue :
                if (indexPath.row == RowCount.eZerothRow.rawValue) {
                    let bolusCell = self.slowBolusCellIndexPath(indexPath)
                    return bolusCell
                } else {
                    let tableCell = self.infusionSolutionInfoCellAtIndexPath(indexPath)
                    return tableCell
                }
            default :
                let optionsCell = tableView.dequeueReusableCellWithIdentifier(INFUSIONS_ADMINISTER_AS_CELL_ID) as? DCInfusionsAdministerAsCell
                return optionsCell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == SectionCount.eFirstSection.rawValue && indexPath.row != RowCount.eSecondRow.rawValue) {
            collapseOpenedPickerCell()
        }
        switch indexPath.section {
            case SectionCount.eZerothSection.rawValue :
                self.updateViewOnTableViewZerothSectionSelectionAtIndexPath(indexPath)
            case SectionCount.eFirstSection.rawValue :
                switch indexPath.row {
                    case RowCount.eFirstRow.rawValue :
                        self.displayInfusionSolventView()
                    case RowCount.eSecondRow.rawValue :
                        self.displayInlinePickerForRowAtIndexPath(indexPath)
                    case RowCount.eThirdRow.rawValue :
                        self.displayInjectionRegionView()
                    case RowCount.eFourthRow.rawValue :
                        self.displayInjectionRegionView()
                    default :
                        break
                }
            default :
                break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return (indexPath == self.inlinePickerIndexPath) ? PICKER_CELL_HEIGHT : TABLE_CELL_HEIGHT
    }

    //MARK: Private Methods
    
    func tableViewHasInlinePickerForSection (section : NSInteger) -> Bool {
        
        return (self.inlinePickerIndexPath != nil && section == self.inlinePickerIndexPath?.section)
    }
    
    func collapseOpenedPickerCell () {
        
        if (self.inlinePickerIndexPath != nil) {
            let previousPickerIndexPath = NSIndexPath(forItem: inlinePickerIndexPath!.row - 1, inSection: inlinePickerIndexPath!.section)
            self.displayInlinePickerForRowAtIndexPath(previousPickerIndexPath)
        }
    }
    
    func displayInlinePickerForRowAtIndexPath(indexPath : NSIndexPath) {
        
        administerOptionsTableView.beginUpdates()
        var pickerBeforeSelectedIndexPath = false
        var sameCellClicked = false
        if (self.inlinePickerIndexPath != nil) {
            pickerBeforeSelectedIndexPath = self.inlinePickerIndexPath!.row < indexPath.row
            if (tableViewHasInlinePickerForSection(indexPath.section)) {
                sameCellClicked = (self.inlinePickerIndexPath!.row - 1 == indexPath.row);
            }
            let pickerIndexPath : NSIndexPath = self.inlinePickerIndexPath!
            self.inlinePickerIndexPath = nil
            administerOptionsTableView.deleteRowsAtIndexPaths([pickerIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        // remove any picker cell if it exists
        if (!sameCellClicked) {
            // hide the date picker and display the new one
            let rowToReveal : NSInteger = (pickerBeforeSelectedIndexPath ? indexPath.row - 1 : indexPath.row);
            let indexPathToReveal : NSIndexPath = NSIndexPath(forItem: rowToReveal, inSection: indexPath.section)
            togglePickerForSelectedIndexPath(indexPathToReveal)
            self.inlinePickerIndexPath = NSIndexPath(forItem: indexPathToReveal.row + 1, inSection: indexPath.section)
        }
        administerOptionsTableView.deselectRowAtIndexPath(indexPath, animated: true)
        administerOptionsTableView.endUpdates()
    }
    
    func togglePickerForSelectedIndexPath(indexPath : NSIndexPath) {
        
        let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
        if (tableViewHasInlinePickerForSection(indexPath.section)) {
            administerOptionsTableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            // didn't find a picker below it, so we should insert it
            administerOptionsTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func slowBolusCellIndexPath(indexPath : NSIndexPath) -> DCSlowBolusCell {
        
        //configure slow bolus cell
        let bolusCell = administerOptionsTableView.dequeueReusableCellWithIdentifier(SLOW_BOLUS_CELL_ID) as? DCSlowBolusCell
        if let switchState = self.infusion?.bolusInjection?.slowBolus {
            bolusCell?.bolusSwitch.on = switchState
        }
        bolusCell?.switchState = { state in
            let switchValue : Bool = state!
            self.infusion?.bolusInjection?.slowBolus = switchValue
//            if let infusionDelegate = self.administerDelegate {
//                infusionDelegate.newInfusionObject(self.infusion!)
//            }
        }
        return bolusCell!
    }
    
    func infusionSolutionInfoCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        if (self.inlinePickerIndexPath?.row == indexPath.row) {
            let infusionPickerCell = administerOptionsTableView.dequeueReusableCellWithIdentifier(INFUSION_PICKER_CELL_ID) as? DCInfusionPickerCell
            infusionPickerCell?.previousValue = self.infusion?.bolusInjection?.quantity
            infusionPickerCell?.unitCompletion = { unit in
                self.infusion?.bolusInjection?.quantity = unit! as String
                self.performSelector(Selector("reloadCellAfterDelayAtIndexPath:"), withObject: NSIndexPath(forRow: 2, inSection: indexPath.section), afterDelay: 0.04)
            }
            infusionPickerCell?.configurePickerView()
            return infusionPickerCell!
        } else {
            let infusionCell = self.configureInfusionCellAtIndexPath(indexPath) as? DCInfusionCell
            return infusionCell!
        }
    }
    
    func configureInfusionCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell? {
        
        //configure infusions cell
        let infusionCell = administerOptionsTableView.dequeueReusableCellWithIdentifier(INFUSIONS_CELL_ID) as? DCInfusionCell
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
        return infusionCell!
    }
    
    func updateViewOnTableViewZerothSectionSelectionAtIndexPath(indexPath : NSIndexPath) {
        
        //zeroth section selection
        previousAdministerOption = optionsArray![indexPath.row]
        if (previousAdministerOptionIndexPath != nil) {
            administerOptionsTableView.reloadRowsAtIndexPaths([previousAdministerOptionIndexPath!], withRowAnimation: .Fade)
        }
        administerOptionsTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        infusion?.administerAsOption = previousAdministerOption
        if (infusion?.administerAsOption == BOLUS_INJECTION) {
            self.infusion?.bolusInjection = DCBolusInjection.init()
        } else if (infusion?.administerAsOption == DURATION_BASED_INFUSION) {
            self.infusion?.durationInfusion = DCDurationInfusion.init()
        } else {
            //rate based infusion
            self.infusion?.rateInfusion = DCRateInfusion.init()
        }
        let sectionCount = administerOptionsTableView.numberOfSections
        if (infusion?.administerAsOption == BOLUS_INJECTION) {
            if sectionCount == SectionCount.eFirstSection.rawValue {
                //if section count is zero insert new section with animation
                administerOptionsTableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
            }
        } else {
            administerOptionsTableView.reloadData()
        }
    }
    
    func displayInfusionSolventView() {
        
        //display infusion in view
        let addMedicationStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let infusionSolventViewController = addMedicationStoryboard.instantiateViewControllerWithIdentifier(MEDICATION_LIST_STORYBOARD_ID) as? DCMedicationListViewController
        infusionSolventViewController?.patientId = self.patientId
        infusionSolventViewController?.title = NSLocalizedString("IN", comment: "")
        infusionSolventViewController?.selectedMedication = { (medication, warnings) in
            self.infusion?.bolusInjection?.solvent = medication.name
            self.administerOptionsTableView.reloadData()
        }
        DCUtility.presentNavigationController(self.navigationController, withRootViewController: infusionSolventViewController);
    }
    
    func displayInjectionRegionView() {
        
        //injection region view
        let addMedicationStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let injectionRegionViewController = addMedicationStoryboard.instantiateViewControllerWithIdentifier(INJECTION_REGION_SB_ID) as? DCInjectionRegionViewController
        injectionRegionViewController?.previousRegion = infusion?.bolusInjection?.injectionRegion
        injectionRegionViewController?.injectionRegion = { region in
            self.infusion?.bolusInjection?.injectionRegion = region
            self.administerOptionsTableView.reloadData()
        }
        self.navigationController?.pushViewController(injectionRegionViewController!, animated: true)
    }
    
    func reloadCellAfterDelayAtIndexPath(indexPath : NSIndexPath) {
        
        //reload cell after delay
        administerOptionsTableView.beginUpdates()
        administerOptionsTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        administerOptionsTableView.endUpdates()
    }

}
