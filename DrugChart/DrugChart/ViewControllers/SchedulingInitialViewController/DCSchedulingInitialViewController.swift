//
//  DCSchedulingInitialViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 12/1/15.
//
//

import UIKit

let SECTION_COUNT : NSInteger = 2
let TABLE_SECTION_HEIGHT : CGFloat = 10.0
let DESCRIPTION_CELL_INDEX : NSInteger = 2
let INSTRUCTIONS_ROW_HEIGHT : CGFloat = 78

typealias SelectedScheduling = DCScheduling? -> Void
typealias UpdatedTimeArray = NSMutableArray? -> Void

class DCSchedulingInitialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, InstructionCellDelegate, AddMedicationDetailDelegate {

    @IBOutlet weak var schedulingTableView: UITableView!
    
    var scheduling : DCScheduling?
    var timeArray : NSMutableArray? = []
    var isEditMedication : Bool?
    var selectedSchedulingValue : SelectedScheduling = {value in }
    var updatedTimeArray : UpdatedTimeArray = {times in }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        configureNavigationBarItems()
        schedulingTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Private Methods
    
    func configureNavigationBarItems() {
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Default)
        self.navigationItem.title = NSLocalizedString("FREQUENCY", comment: "")
        self.title = NSLocalizedString("FREQUENCY", comment: "")
    }

    func displaySchedulingDetailViewControllerForSelectedIndexPath(indexPath : NSIndexPath) {
        
        let storyBoard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let schedulingDetailViewController = storyBoard.instantiateViewControllerWithIdentifier(SCHEDULING_DETAIL_STORYBOARD_ID) as? DCSchedulingDetailViewController
        schedulingDetailViewController!.scheduling = self.scheduling;
        schedulingDetailViewController?.detailType = DCSchedulingHelper.schedulingDetailTypeAtIndexPath(indexPath)
        if indexPath.section == 0 {
            if (self.scheduling?.type != nil) {
                schedulingDetailViewController?.previousFilledValue = (self.scheduling?.type)!
            }
        }
        schedulingDetailViewController?.frequencyValue = { value in
            //inside our closure
            print("Frequency value is %@", value)
            self.scheduling?.type = String(value!)
            self.schedulingTableView.reloadData()
        }
        self.navigationController?.pushViewController(schedulingDetailViewController!, animated: true)
    }
        
    func presentAdministrationTimeView() {
        
        let storyBoard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let medicationDetailViewController = storyBoard.instantiateViewControllerWithIdentifier(ADD_MEDICATION_DETAIL_STORYBOARD_ID) as? DCAddMedicationDetailViewController
        medicationDetailViewController!.delegate = self
        medicationDetailViewController?.selectedEntry = { value in
            print("Value is %@", value)
        }
        medicationDetailViewController!.detailType = eDetailAdministrationTime
        medicationDetailViewController!.contentArray = timeArray
        let navigationController = UINavigationController.init(rootViewController: medicationDetailViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func frequencyCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingCell {
        
        //configure scheduling table cell
        let schedulingCell : DCSchedulingCell? = schedulingTableView.dequeueReusableCellWithIdentifier(SCHEDULING_INITIAL_CELL_ID) as? DCSchedulingCell
        schedulingCell?.layoutMargins = UIEdgeInsetsZero
        schedulingCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        if (indexPath.section == 0) {
            schedulingCell!.titleLabel?.text = NSLocalizedString("BASE_FREQUENCY", comment: "")
            schedulingCell!.descriptionLabel.text = scheduling?.type
        } else {
            if (indexPath.row == 0) {
                schedulingCell!.titleLabel?.text = NSLocalizedString("ADMINISTRATION_TIMES", comment: "")
            } else if (indexPath.row == 1) {
                schedulingCell!.titleLabel?.text = NSLocalizedString("REPEAT", comment: "")
            } else {
                schedulingCell!.titleLabel?.text = NSLocalizedString("DESCRIPTION", comment: "")
            }
        }
        return schedulingCell!
    }
    
    func descriptionCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingDescriptionTableCell {

        // description cell
        
        let descriptionCell = schedulingTableView.dequeueReusableCellWithIdentifier(SCHEDULING_DESCRIPTION_CELL_ID) as? DCSchedulingDescriptionTableCell
        descriptionCell!.delegate = self;
        descriptionCell?.populatePlaceholderForFieldIsInstruction(false)
        if let description = scheduling?.schedulingDescription {
            descriptionCell?.descriptionTextView?.text = description
        } else {
            descriptionCell?.descriptionTextView?.textColor = UIColor(forHexString: "#8f8f95")
        }
        return descriptionCell!
    }
    
    // MARK: TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return SECTION_COUNT
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == DESCRIPTION_CELL_INDEX) {
            // display description field for specific times scheduling
            let descriptionCell : DCSchedulingDescriptionTableCell? = descriptionCellAtIndexPath(indexPath)
            return descriptionCell!
        } else {
            let schedulingCell : DCSchedulingCell? = frequencyCellAtIndexPath(indexPath)
            return schedulingCell!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        //return (indexPathHasPicker(indexPath)) ? PICKER_CELL_HEIGHT : TABLE_VIEW_ROW_HEIGHT
        if (indexPath.row == DESCRIPTION_CELL_INDEX) {
            return INSTRUCTIONS_ROW_HEIGHT
        } else {
            return TABLE_VIEW_ROW_HEIGHT
        }
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1 && indexPath.row == 0 {
            presentAdministrationTimeView()
        } else {
            displaySchedulingDetailViewControllerForSelectedIndexPath(indexPath)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return TABLE_SECTION_HEIGHT
    }
    
    //MARK: Description Delegate Methods
    
    func closeInlineDatePickers () {
        
    }
    
    func scrollTableViewToTextViewCellIfInstructionField(isInstruction: Bool) {
        
    }
    
    func updateTextViewText(instructions: String!, isInstruction: Bool) {
        
    }
    
    //MARK: Add Medication Detail Delegate Methods
    
    func updatedAdministrationTimeArray(timeArray: [AnyObject]!) {
        
        //new administration time added
        self.timeArray = NSMutableArray(array: timeArray)
        self.updatedTimeArray(self.timeArray)
    }
}
