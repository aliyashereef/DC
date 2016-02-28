//
//  DCInfusionsAdministerAsViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/13/16.
//
//

import UIKit

let DESCRIPTION_LABEL_TRAILING_IN : CGFloat = 18.0
let DESCRIPTION_LABEL_TRAILING_DEFAULT : CGFloat = 3.0
let DESCRITION_LABEL_WIDTH_DEFAULT : CGFloat = 155.0
let DESCRIPTION_LABEL_WIDTH_IN : CGFloat = 225.0
let TABLE_CELL_HEIGHT : CGFloat = 44.0


protocol InfusionDelegate {
    
    func newInfusionObject(infusion : DCInfusion)
}

class DCInfusionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var administerOptionsTableView: UITableView!
    var optionsArray : [String]? = []
    var previousAdministerOption : String? = EMPTY_STRING
    var administerDelegate : InfusionDelegate?
    var previousAdministerOptionIndexPath : NSIndexPath?
    var infusion : DCInfusion?
    var dosage : DCDosage?
    var inlinePickerIndexPath : NSIndexPath? = nil
    var patientId : String?
    var unitArrayForOver = [HOURS,MINUTES]
    var unitArrayForStartingAt = [MG_PER_HOUR,MG_PER_MINUTE]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = NSLocalizedString("ADMINISTER_AS", comment: "screen title")
        optionsArray = [BOLUS_INJECTION, DURATION_BASED_INFUSION, RATE_BASED_INFUSION] // administer as options
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if let delegate = administerDelegate {
            if let updatedInfusion = self.infusion {
                delegate.newInfusionObject(updatedInfusion)
            }
        }
        self.title = NSLocalizedString("ADMINISTER_AS", comment: "screen title")
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
            } else if (infusion?.administerAsOption == BOLUS_INJECTION) {
                rowCount = RowCount.eFourthRow.rawValue
            } else if (infusion?.administerAsOption == RATE_BASED_INFUSION) {
                rowCount = RowCount.eThirdRow.rawValue
            }
            if (tableViewHasInlinePickerForSection(section)) {
                rowCount++
            }
            return rowCount
        case SectionCount.eSecondSection.rawValue,
             SectionCount.eThirdSection.rawValue :
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
                let optionsCell = administerOptionsTableCellAtIndexPath(indexPath)
                return optionsCell
            case SectionCount.eFirstSection.rawValue :
                if (infusion?.administerAsOption == BOLUS_INJECTION) {
                    let bolusInjectionCell = self.tableCellForBolusInjectionAtIndexPath(indexPath)
                    return bolusInjectionCell
                } else if (infusion?.administerAsOption == DURATION_BASED_INFUSION) {
                    let durationInfusionCell = self.tableCellForDurationBasedInfusionAtIndexPath(indexPath)
                    return durationInfusionCell
                } else {
                    //rate based infusion cell
                    if (self.inlinePickerIndexPath == indexPath) {
                        let pickerCell = self.rateInfoPickerCellAtIndexPath(indexPath)
                        return pickerCell
                    } else {
                        let tableCell = self.infusionRateInfoCellAtIndexPath(indexPath)
                        return tableCell
                    }
                }
            case SectionCount.eSecondSection.rawValue :
                let tableCell = self.infusionSolutionInfoCellAtIndexPath(indexPath)
                return tableCell
            case SectionCount.eThirdSection.rawValue :
                let tableCell = self.infusionSolutionInfoCellAtIndexPath(indexPath)
                return tableCell
            default :
                let optionsCell = tableView.dequeueReusableCellWithIdentifier(INFUSIONS_ADMINISTER_AS_CELL_ID) as? DCInfusionsAdministerAsCell
                return optionsCell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let pickerIndexpath = self.inlinePickerIndexPath {
            let hideInlinePicker = DCInfusionsHelper.hideInlinePickerViewAtIndexIndexPath(pickerIndexpath, forSelectedCellAtIndexPath: indexPath, withAdministerOption: (self.infusion?.administerAsOption)!)
            if hideInlinePicker == true {
                collapseOpenedPickerCell()
            }
        }
        switch indexPath.section {
            case SectionCount.eZerothSection.rawValue :
                self.updateViewOnTableViewZerothSectionSelectionAtIndexPath(indexPath)
            case SectionCount.eFirstSection.rawValue :
                if (infusion?.administerAsOption == BOLUS_INJECTION) {
                    self.updateViewOnTableViewFirstSectionSelectionForBolusInjectionAtIndexPath(indexPath)
                } else {
                    self.transitToAddNewValueScreen(indexPath)
                }
            case SectionCount.eSecondSection.rawValue :
                self.updateViewOnSolutionInfoCellSelectionAtIndexPath(indexPath)
            default :
                break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return (indexPath == self.inlinePickerIndexPath) ? PICKER_CELL_HEIGHT : TABLE_CELL_HEIGHT
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        //Set the header as PREVIEW
        if (section == SectionCount.eFirstSection.rawValue && infusion?.administerAsOption == DURATION_BASED_INFUSION) {
            var footerText = EMPTY_STRING
            if (self.infusion?.durationInfusion?.flowDuration != nil && self.dosage != nil) {
                footerText = DCInfusionsHelper.durationBasedInfusionFooterTextForDosage(self.dosage, flowDuration: infusion?.durationInfusion?.flowDuration) as String
                return footerText
            }
        }
        return nil
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel!.textColor = UIColor(forHexString: "#686868")
        }
    }
    
    //MARK: Private Methods
    
    func tableViewHasInlinePickerForSection (section : NSInteger) -> Bool {
        
        return (self.inlinePickerIndexPath != nil && section == self.inlinePickerIndexPath?.section)
    }
    
    func collapseOpenedPickerCell () {
        
        if (self.inlinePickerIndexPath != nil) {
            administerOptionsTableView.beginUpdates()
            let pickerIndexPath : NSIndexPath = self.inlinePickerIndexPath!
            inlinePickerIndexPath = nil
            administerOptionsTableView.deleteRowsAtIndexPaths([pickerIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            administerOptionsTableView.endUpdates()
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
    
    func tableCellForBolusInjectionAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        //bolus injection first section
        if (indexPath.row == RowCount.eZerothRow.rawValue) {
            let bolusCell = self.slowBolusCellIndexPath(indexPath)
            return bolusCell
        } else {
            let tableCell = self.infusionSolutionInfoCellAtIndexPath(indexPath)
            return tableCell
        }
    }
    
    func tableCellForDurationBasedInfusionAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        //duration based infusion
        if (indexPath.row == RowCount.eZerothRow.rawValue) {
            var infusionCell = administerOptionsTableView.dequeueReusableCellWithIdentifier(INFUSIONS_CELL_ID) as? DCInfusionCell
            infusionCell = self.populateInfusionCell(infusionCell!, accessoryType: .DisclosureIndicator, titleValue: NSLocalizedString("OVER", comment: ""), descriptionValue: self.infusion?.durationInfusion?.flowDuration, descriptionTrailing: DESCRIPTION_LABEL_TRAILING_DEFAULT, descriptionWidth: DESCRITION_LABEL_WIDTH_DEFAULT)
            return infusionCell!
        } else {
            let infusionPickerCell = administerOptionsTableView.dequeueReusableCellWithIdentifier(INFUSION_PICKER_CELL_ID) as? DCInfusionPickerCell
            infusionPickerCell?.infusionPickerType = eFlowDuration
            infusionPickerCell?.previousValue = self.infusion?.durationInfusion?.flowDuration
            infusionPickerCell?.selectionCompletion = { unit in
                self.infusion?.durationInfusion?.flowDuration = unit! as String
                self.performSelector(Selector("reloadCellAfterDelayAtIndexPath:"), withObject: NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section), afterDelay: 0.04)
               self.administerOptionsTableView.footerViewForSection(1)?.textLabel?.text = self.tableView(self.administerOptionsTableView, titleForFooterInSection: 1)
               self.administerOptionsTableView.footerViewForSection(1)?.textLabel?.sizeToFit()
            }
            infusionPickerCell?.configurePickerView()
            return infusionPickerCell!
        }
    }
    
    func reloadTableViewSectionWithIndexSet(indexSet : NSIndexSet) {
        
        self.administerOptionsTableView.beginUpdates()
        self.administerOptionsTableView.reloadSections(indexSet, withRowAnimation: .None)
        self.administerOptionsTableView.endUpdates()
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
        }
        return bolusCell!
    }
    
    func infusionRateInfoCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        var rateCell = administerOptionsTableView.dequeueReusableCellWithIdentifier(INFUSIONS_CELL_ID) as? DCInfusionCell
        switch indexPath.row {
            case RowCount.eZerothRow.rawValue :
                rateCell = self.populateInfusionCell(rateCell!, accessoryType: .DisclosureIndicator, titleValue: NSLocalizedString("STARTING_AT", comment: ""), descriptionValue: self.infusion?.rateInfusion?.startingRate, descriptionTrailing: DESCRIPTION_LABEL_TRAILING_DEFAULT, descriptionWidth: DESCRITION_LABEL_WIDTH_DEFAULT)
            case RowCount.eFirstRow.rawValue :
                rateCell = self.populateInfusionCell(rateCell!, accessoryType: .DisclosureIndicator, titleValue: NSLocalizedString("VARY_BETWEEN", comment: ""), descriptionValue: self.infusion?.rateInfusion?.minimumRate, descriptionTrailing: DESCRIPTION_LABEL_TRAILING_DEFAULT, descriptionWidth: DESCRITION_LABEL_WIDTH_DEFAULT)
            case RowCount.eSecondRow.rawValue :
                rateCell = self.populateInfusionCell(rateCell!, accessoryType: .DisclosureIndicator, titleValue: NSLocalizedString("AND", comment: ""), descriptionValue: self.infusion?.rateInfusion?.maximumRate, descriptionTrailing: DESCRIPTION_LABEL_TRAILING_DEFAULT, descriptionWidth: DESCRITION_LABEL_WIDTH_DEFAULT)
            default :
                break
        }
        return rateCell!
    }
    
    func rateInfoPickerCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        //display rate info picker cell
        let pickerCell = administerOptionsTableView.dequeueReusableCellWithIdentifier(INFUSION_PICKER_CELL_ID) as? DCInfusionPickerCell
        switch indexPath.row {
        case RowCount.eFirstRow.rawValue :
            pickerCell?.previousValue = self.infusion?.rateInfusion?.startingRate
            pickerCell?.infusionPickerType = eRateStarting
            pickerCell?.selectionCompletion = { value in
                self.infusion?.rateInfusion?.startingRate = value
                self.performSelector(Selector("reloadCellAfterDelayAtIndexPath:"), withObject: NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section), afterDelay: 0.04)
            }
        case RowCount.eSecondRow.rawValue :
            pickerCell?.previousValue = self.infusion?.rateInfusion?.minimumRate
            pickerCell?.infusionPickerType = eRateNormal
            pickerCell?.selectionCompletion = { value in
                self.infusion?.rateInfusion?.minimumRate = value
                self.performSelector(Selector("reloadCellAfterDelayAtIndexPath:"), withObject: NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section), afterDelay: 0.04)
            }
        case RowCount.eThirdRow.rawValue :
            pickerCell?.previousValue = self.infusion?.rateInfusion?.maximumRate
            pickerCell?.infusionPickerType = eRateNormal
            pickerCell?.selectionCompletion = { value in
                self.infusion?.rateInfusion?.maximumRate = value
                self.performSelector(Selector("reloadCellAfterDelayAtIndexPath:"), withObject: NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section), afterDelay: 0.04)
            }
        default :
            break
        }
        pickerCell?.configurePickerView()
        return pickerCell!
    }
    
    func infusionSolutionInfoCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        if (self.inlinePickerIndexPath?.section == indexPath.section && self.inlinePickerIndexPath?.row == indexPath.row) {
            let infusionPickerCell = administerOptionsTableView.dequeueReusableCellWithIdentifier(INFUSION_PICKER_CELL_ID) as? DCInfusionPickerCell
            if (self.infusion?.administerAsOption == BOLUS_INJECTION) {
                infusionPickerCell?.previousValue = self.infusion?.bolusInjection?.quantity
            } else if (self.infusion?.administerAsOption == DURATION_BASED_INFUSION) {
                infusionPickerCell?.previousValue = self.infusion?.durationInfusion?.quantity
            } else if (self.infusion?.administerAsOption == RATE_BASED_INFUSION) {
                infusionPickerCell?.previousValue = self.infusion?.rateInfusion?.quantity
            }
            infusionPickerCell?.infusionPickerType = eUnit
            infusionPickerCell?.selectionCompletion = { unit in
                if (self.infusion?.administerAsOption == BOLUS_INJECTION) {
                    self.infusion?.bolusInjection?.quantity = unit! as String
                } else if (self.infusion?.administerAsOption == DURATION_BASED_INFUSION) {
                    self.infusion?.durationInfusion?.quantity = unit! as String
                } else if (self.infusion?.administerAsOption == RATE_BASED_INFUSION) {
                    self.infusion?.rateInfusion?.quantity = unit! as String
                }
                self.performSelector(Selector("reloadCellAfterDelayAtIndexPath:"), withObject: NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section), afterDelay: 0.04)
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
        var infusionCell = administerOptionsTableView.dequeueReusableCellWithIdentifier(INFUSIONS_CELL_ID) as? DCInfusionCell
        if (self.infusion?.administerAsOption == DURATION_BASED_INFUSION && indexPath.section == SectionCount.eFirstSection.rawValue) {
            infusionCell = self.populateInfusionCell(infusionCell!, accessoryType: .DisclosureIndicator, titleValue: NSLocalizedString("OVER", comment: ""), descriptionValue: "1 hr", descriptionTrailing: DESCRIPTION_LABEL_TRAILING_DEFAULT, descriptionWidth: DESCRITION_LABEL_WIDTH_DEFAULT)
        } else {
            switch indexPath.row {
                case RowCount.eZerothRow.rawValue :
                    if (self.infusion?.administerAsOption != BOLUS_INJECTION) {
                        let solvent = (self.infusion?.administerAsOption == DURATION_BASED_INFUSION) ? infusion?.durationInfusion?.solvent : infusion?.rateInfusion?.solvent
                        infusionCell = self.populateInfusionCell(infusionCell!, accessoryType: .None, titleValue: NSLocalizedString("IN", comment: ""), descriptionValue: solvent, descriptionTrailing: DESCRIPTION_LABEL_TRAILING_IN, descriptionWidth: DESCRIPTION_LABEL_WIDTH_IN)
                    }
                case RowCount.eFirstRow.rawValue :
                    if (self.infusion?.administerAsOption == BOLUS_INJECTION) {
                        infusionCell = self.populateInfusionCell(infusionCell!, accessoryType: .None, titleValue: NSLocalizedString("IN", comment: ""), descriptionValue: infusion?.bolusInjection?.solvent, descriptionTrailing: DESCRIPTION_LABEL_TRAILING_IN, descriptionWidth: DESCRIPTION_LABEL_WIDTH_IN)
                    } else {
                        let quantity = (self.infusion?.administerAsOption == DURATION_BASED_INFUSION) ? infusion?.durationInfusion?.quantity : infusion?.rateInfusion?.quantity
                        infusionCell = self.populateInfusionCell(infusionCell!, accessoryType: .DisclosureIndicator, titleValue: NSLocalizedString("ML", comment: ""), descriptionValue: quantity, descriptionTrailing: DESCRIPTION_LABEL_TRAILING_DEFAULT, descriptionWidth: DESCRITION_LABEL_WIDTH_DEFAULT)
                    }
                case RowCount.eSecondRow.rawValue :
                    if (self.infusion?.administerAsOption == BOLUS_INJECTION) {
                        infusionCell = self.populateInfusionCell(infusionCell!, accessoryType: .DisclosureIndicator, titleValue: NSLocalizedString("ML", comment: ""), descriptionValue: infusion?.bolusInjection?.quantity, descriptionTrailing: DESCRIPTION_LABEL_TRAILING_DEFAULT, descriptionWidth: DESCRITION_LABEL_WIDTH_DEFAULT)
                    } else {
                        let injectionRegion = (self.infusion?.administerAsOption == DURATION_BASED_INFUSION) ? infusion?.durationInfusion?.injectionRegion : infusion?.rateInfusion?.injectionRegion
                        infusionCell = self.populateInfusionCell(infusionCell!, accessoryType: .DisclosureIndicator, titleValue: NSLocalizedString("INTO", comment: ""), descriptionValue: injectionRegion, descriptionTrailing: DESCRIPTION_LABEL_TRAILING_DEFAULT, descriptionWidth: DESCRITION_LABEL_WIDTH_DEFAULT)
                    }
                case RowCount.eThirdRow.rawValue :
                    infusionCell = self.populateInfusionCell(infusionCell!, accessoryType: .DisclosureIndicator, titleValue: NSLocalizedString("INTO", comment: ""), descriptionValue: infusion?.bolusInjection?.injectionRegion, descriptionTrailing: DESCRIPTION_LABEL_TRAILING_DEFAULT, descriptionWidth: DESCRITION_LABEL_WIDTH_DEFAULT)
                default :
                    break
            }
        }
        return infusionCell!
    }
    
    func populateInfusionCell(infusionCell : DCInfusionCell, accessoryType type : UITableViewCellAccessoryType, titleValue title : String, descriptionValue description : String?, descriptionTrailing trailing : CGFloat, descriptionWidth width : CGFloat) -> DCInfusionCell {
        
        infusionCell.accessoryType = type
        infusionCell.titleLabel.text = title
        infusionCell.descriptionLabel.text = description
        infusionCell.descriptionTrailingConstraint.constant = trailing
        infusionCell.descriptionLabelWidthConstraint.constant = width
        return infusionCell
    }
    
    func administerOptionsTableCellAtIndexPath(indexPath : NSIndexPath) -> DCInfusionsAdministerAsCell {
        
        let optionsCell = administerOptionsTableView.dequeueReusableCellWithIdentifier(INFUSIONS_ADMINISTER_AS_CELL_ID) as? DCInfusionsAdministerAsCell
        let option = optionsArray![indexPath.item]
        optionsCell?.titleLabel.text = option
        if (option == previousAdministerOption) {
            optionsCell?.accessoryType = .Checkmark
            previousAdministerOptionIndexPath = indexPath
        } else {
            optionsCell?.accessoryType = .None
        }
        return optionsCell!
    }
    
    func initialiseAdministerOptions() {
        
        if (infusion?.administerAsOption == BOLUS_INJECTION) {
            self.infusion?.bolusInjection = DCBolusInjection.init()
        } else if (infusion?.administerAsOption == DURATION_BASED_INFUSION) {
            self.infusion?.durationInfusion = DCDurationInfusion.init()
        } else {
            //rate based infusion
            self.infusion?.rateInfusion = DCRateInfusion.init()
        }
    }
    
    func updateViewOnTableViewZerothSectionSelectionAtIndexPath(indexPath : NSIndexPath) {
        
        //zeroth section selection
        if (self.infusion == nil) {
            self.infusion = DCInfusion.init()
        }
        if (previousAdministerOption != optionsArray![indexPath.row]) {
            previousAdministerOption = optionsArray![indexPath.row]
            if (previousAdministerOptionIndexPath != nil) {
                administerOptionsTableView.reloadRowsAtIndexPaths([previousAdministerOptionIndexPath!], withRowAnimation: .Fade)
            }
            administerOptionsTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            infusion?.administerAsOption = previousAdministerOption
            self.initialiseAdministerOptions()
            administerOptionsTableView.beginUpdates()
            let sectionCount = administerOptionsTableView.numberOfSections
            switch sectionCount {
                case SectionCount.eFirstSection.rawValue :
                    if (infusion?.administerAsOption == BOLUS_INJECTION) {
                        administerOptionsTableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
                    } else {
                        administerOptionsTableView.insertSections(NSIndexSet(indexesInRange: NSMakeRange(1, 2)), withRowAnimation: .Middle)
                    }
                case SectionCount.eSecondSection.rawValue :
                    if (infusion?.administerAsOption == BOLUS_INJECTION) {
                        administerOptionsTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
                        if (sectionCount == SectionCount.eSecondSection.rawValue) {
                            administerOptionsTableView.deleteSections(NSIndexSet(index: 2), withRowAnimation: .Fade)
                        }
                    } else if (infusion?.administerAsOption == DURATION_BASED_INFUSION) {
                        administerOptionsTableView.insertSections(NSIndexSet(index: 2), withRowAnimation: .Middle)
                        administerOptionsTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
                    } else if (infusion?.administerAsOption == RATE_BASED_INFUSION) {
                        if (sectionCount == SectionCount.eSecondSection.rawValue) {
                            administerOptionsTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
                            administerOptionsTableView.insertSections(NSIndexSet(index: 2), withRowAnimation: .Middle)
                        } else {
                            administerOptionsTableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(1, 2)), withRowAnimation: .Middle)
                        }
                    }
                case SectionCount.eThirdSection.rawValue :
                    if (infusion?.administerAsOption == BOLUS_INJECTION) {
                        administerOptionsTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                        if (sectionCount == SectionCount.eThirdSection.rawValue) {
                            administerOptionsTableView.deleteSections(NSIndexSet(index: 2), withRowAnimation: .Fade)
                        }
                    } else {
                        administerOptionsTableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(1, 2)), withRowAnimation: .Middle)
                    }
                default :
                    break
                }
        administerOptionsTableView.endUpdates()
        }
    }
    
    func updateViewOnTableViewFirstSectionSelectionForBolusInjectionAtIndexPath(indexPath : NSIndexPath) {
        
        //bolus injection solution info cell selection
        switch indexPath.row {
            case RowCount.eFirstRow.rawValue :
                self.displayInfusionSolventView()
            case RowCount.eSecondRow.rawValue :
                let addMedicationStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
                let addNewValueViewController = addMedicationStoryboard.instantiateViewControllerWithIdentifier(ADD_NEW_VALUE_SBID) as? DCAddNewValueViewController
                addNewValueViewController?.backButtonTitle = NSLocalizedString("ADMINISTER_AS", comment: "screen title")
                addNewValueViewController?.placeHolderString = "ml"
                addNewValueViewController?.titleString = "ml"
                if (self.infusion?.administerAsOption == BOLUS_INJECTION) {
                    if self.infusion?.bolusInjection?.quantity != nil {
                        addNewValueViewController?.previousValue = (self.infusion?.bolusInjection?.quantity)!
                    }
                } else if (self.infusion?.administerAsOption == DURATION_BASED_INFUSION) {
                    if self.infusion?.durationInfusion?.quantity != nil {
                        addNewValueViewController?.previousValue = (self.infusion?.durationInfusion?.quantity)!
                    }
                } else if (self.infusion?.administerAsOption == RATE_BASED_INFUSION) {
                    if self.infusion?.rateInfusion?.quantity != nil {
                        addNewValueViewController?.previousValue = (self.infusion?.rateInfusion?.quantity)!
                    }
                }
                addNewValueViewController!.newValueEntered = { value in
                    if (self.infusion?.administerAsOption == BOLUS_INJECTION) {
                        self.infusion?.bolusInjection?.quantity = value
                    } else if (self.infusion?.administerAsOption == DURATION_BASED_INFUSION) {
                        self.infusion?.durationInfusion?.quantity = value
                    } else if (self.infusion?.administerAsOption == RATE_BASED_INFUSION) {
                        self.infusion?.rateInfusion?.quantity = value
                    }
                    self.administerOptionsTableView.reloadData()
                }
                self.navigationController?.pushViewController(addNewValueViewController!, animated: true)
                //self.displayInlinePickerForRowAtIndexPath(indexPath)
            case RowCount.eThirdRow.rawValue ,
                RowCount.eFourthRow.rawValue :
                self.displayInjectionRegionView()
            default :
                break
        }
    }
    
    func updateViewOnSolutionInfoCellSelectionAtIndexPath(indexPath : NSIndexPath) {
        
        //duration based infusion cell selection
        switch indexPath.row {
            case RowCount.eZerothRow.rawValue :
                self.displayInfusionSolventView()
            case RowCount.eFirstRow.rawValue :
                let addMedicationStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
                let addNewValueViewController = addMedicationStoryboard.instantiateViewControllerWithIdentifier(ADD_NEW_VALUE_SBID) as? DCAddNewValueViewController
                addNewValueViewController?.backButtonTitle = NSLocalizedString("ADMINISTER_AS", comment: "screen title")
                addNewValueViewController?.placeHolderString = "ml"
                addNewValueViewController?.titleString = "ml"
                if (self.infusion?.administerAsOption == BOLUS_INJECTION) {
                    if self.infusion?.bolusInjection?.quantity != nil {
                        addNewValueViewController?.previousValue = (self.infusion?.bolusInjection?.quantity)!
                    }
                } else if (self.infusion?.administerAsOption == DURATION_BASED_INFUSION) {
                    if self.infusion?.durationInfusion?.quantity != nil {
                        addNewValueViewController?.previousValue = (self.infusion?.durationInfusion?.quantity)!
                    }
                } else if (self.infusion?.administerAsOption == RATE_BASED_INFUSION) {
                    if self.infusion?.rateInfusion?.quantity != nil {
                        addNewValueViewController?.previousValue = (self.infusion?.rateInfusion?.quantity)!
                    }
                }
                addNewValueViewController!.newValueEntered = { value in
                    if (self.infusion?.administerAsOption == BOLUS_INJECTION) {
                        self.infusion?.bolusInjection?.quantity = value
                    } else if (self.infusion?.administerAsOption == DURATION_BASED_INFUSION) {
                        self.infusion?.durationInfusion?.quantity = value
                    } else if (self.infusion?.administerAsOption == RATE_BASED_INFUSION) {
                        self.infusion?.rateInfusion?.quantity = value
                    }
                    self.administerOptionsTableView.reloadData()
                }
                self.navigationController?.pushViewController(addNewValueViewController!, animated: true)
                //self.displayInlinePickerForRowAtIndexPath(indexPath)
            case RowCount.eSecondRow.rawValue ,
                 RowCount.eThirdRow.rawValue :
                self.displayInjectionRegionView()
            default :
                break
        }
    }
    
    func displayInfusionSolventView() {
        
        //display infusion in view
        let addMedicationStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let infusionSolventViewController = addMedicationStoryboard.instantiateViewControllerWithIdentifier(MEDICATION_LIST_STORYBOARD_ID) as? DCMedicationListViewController
        infusionSolventViewController?.patientId = self.patientId
        infusionSolventViewController?.title = NSLocalizedString("IN", comment: "")
        infusionSolventViewController?.selectedMedication = { (medication, warnings) in
            if(self.infusion?.administerAsOption == BOLUS_INJECTION) {
                self.infusion?.bolusInjection?.solvent = medication.name
            } else if (self.infusion?.administerAsOption == DURATION_BASED_INFUSION) {
                self.infusion?.durationInfusion?.solvent = medication.name
            } else if (self.infusion?.administerAsOption == RATE_BASED_INFUSION) {
                self.infusion?.rateInfusion?.solvent = medication.name
            }
            self.administerOptionsTableView.reloadData()
        }
        DCUtility.presentNavigationController(self.navigationController, withRootViewController: infusionSolventViewController);
    }
    
    func displayInjectionRegionView() {
        
        //injection region view
        let addMedicationStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let injectionRegionViewController = addMedicationStoryboard.instantiateViewControllerWithIdentifier(INJECTION_REGION_SB_ID) as? DCInjectionRegionViewController
        if (self.infusion?.administerAsOption == BOLUS_INJECTION) {
            injectionRegionViewController?.previousRegion = infusion?.bolusInjection?.injectionRegion
        } else if (self.infusion?.administerAsOption == DURATION_BASED_INFUSION) {
            injectionRegionViewController?.previousRegion = infusion?.durationInfusion?.injectionRegion
        } else if (self.infusion?.administerAsOption == RATE_BASED_INFUSION) {
            injectionRegionViewController?.previousRegion = infusion?.rateInfusion?.injectionRegion
        }
        injectionRegionViewController?.injectionRegion = { region in
            if (self.infusion?.administerAsOption == BOLUS_INJECTION) {
                self.infusion?.bolusInjection?.injectionRegion = region
            } else if (self.infusion?.administerAsOption == DURATION_BASED_INFUSION) {
                self.infusion?.durationInfusion?.injectionRegion =  region
            } else if (self.infusion?.administerAsOption == RATE_BASED_INFUSION) {
                self.infusion?.rateInfusion?.injectionRegion = region
            }
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
    
    func transitToAddNewValueScreen(indexPath: NSIndexPath) {
        
        let addMedicationStoryboard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let addNewValueViewController = addMedicationStoryboard.instantiateViewControllerWithIdentifier(ADD_NEW_VALUE_SBID) as? DCAddNewValueViewController
        addNewValueViewController?.backButtonTitle = NSLocalizedString("ADMINISTER_AS", comment: "screen title")
        if infusion?.administerAsOption == DURATION_BASED_INFUSION {
            addNewValueViewController?.detailType = eAddValueWithUnit
            addNewValueViewController?.unitArray = unitArrayForOver
            addNewValueViewController?.titleString = "Over"
            addNewValueViewController?.placeHolderString = "Over"
            if self.infusion?.durationInfusion?.flowDuration != nil {
                addNewValueViewController?.previousValue = (self.infusion?.durationInfusion.flowDuration)!
            }
        } else if infusion?.administerAsOption == RATE_BASED_INFUSION {
            if indexPath.row == 0 {
                addNewValueViewController?.detailType = eAddValueWithUnit
                addNewValueViewController?.unitArray = unitArrayForStartingAt
                addNewValueViewController?.titleString = "Starting At"
                addNewValueViewController?.placeHolderString = "Starting At"
                if self.infusion?.rateInfusion.startingRate != nil {
                   addNewValueViewController?.previousValue = (self.infusion?.rateInfusion.startingRate)!
                }
            } else if indexPath.row == 1{
                addNewValueViewController?.detailType = eAddIntegerValue
                addNewValueViewController?.titleString = "Vary Between"
                addNewValueViewController?.placeHolderString = "Vary Between"
                if self.infusion?.rateInfusion.minimumRate != nil {
                    addNewValueViewController?.previousValue = (self.infusion?.rateInfusion.minimumRate)!
                }
            } else {
                addNewValueViewController?.detailType = eAddIntegerValue
                addNewValueViewController?.titleString = "And"
                addNewValueViewController?.placeHolderString = "And"
                if self.infusion?.rateInfusion.maximumRate != nil {
                    addNewValueViewController?.previousValue = (self.infusion?.rateInfusion.maximumRate)!
                }
            }
        }
        addNewValueViewController?.newValueEntered = { value in

            if self.infusion?.administerAsOption == DURATION_BASED_INFUSION {
                self.infusion?.durationInfusion.flowDuration = value
            } else if self.infusion?.administerAsOption == RATE_BASED_INFUSION {
                if indexPath.row == 0 {
                    self.infusion?.rateInfusion.startingRate = value
                } else if indexPath.row == 1 {
                    self.infusion?.rateInfusion.minimumRate = value
                } else {
                    self.infusion?.rateInfusion.maximumRate = value 
                }
            }
            self.administerOptionsTableView.reloadData()
        }
        self.navigationController?.pushViewController(addNewValueViewController!, animated: true)
    }

}
