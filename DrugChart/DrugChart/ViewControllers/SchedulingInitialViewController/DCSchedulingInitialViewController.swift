//
//  DCSchedulingInitialViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 12/1/15.
//
//

import UIKit

let INITIAL_SECTION_COUNT : NSInteger = 1
let TOTAL_SECTION_COUNT : NSInteger = 2
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
    var validate : Bool = false
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
            if (self.scheduling?.repeatObject?.repeatType == nil) {
                self.scheduling?.repeatObject = DCRepeat.init()
                self.scheduling?.repeatObject.repeatType = DAILY
                self.scheduling?.repeatObject.frequency = "1 day"
                self.scheduling?.schedulingDescription = String(format: "%@ day.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""))
            }
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
        self.navigationController?.pushViewController(medicationDetailViewController!, animated: true)
    }
    
    func frequencyCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingCell {
        
        //configure scheduling table cell
        let schedulingCell : DCSchedulingCell? = schedulingTableView.dequeueReusableCellWithIdentifier(SCHEDULING_INITIAL_CELL_ID) as? DCSchedulingCell
        if (indexPath.section == 0) {
            //highlight field in red if scheduling type is nil when save button is pressed in add medication screen
            if (indexPath.row == 0) {
                schedulingCell!.titleLabel?.text = SPECIFIC_TIMES
                if (scheduling?.type == SPECIFIC_TIMES) {
                    schedulingCell?.accessoryType = UITableViewCellAccessoryType.Checkmark
                } else {
                    schedulingCell?.accessoryType = UITableViewCellAccessoryType.None
                }
            } else {
                schedulingCell!.titleLabel?.text = INTERVAL
                if (scheduling?.type == INTERVAL) {
                    schedulingCell?.accessoryType = UITableViewCellAccessoryType.Checkmark
                } else {
                    schedulingCell?.accessoryType = UITableViewCellAccessoryType.None
                }
            }
        } else {
            schedulingCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            if (indexPath.row == 0) {
                //highlight field in red if time array is empty when save button is pressed in add medication screen
                schedulingCell!.titleLabel.textColor = (validate &&  (timeArray == nil || timeArray?.count == 0)) ? UIColor.redColor() : UIColor.blackColor()
                schedulingCell!.titleLabel?.text = NSLocalizedString("ADMINISTRATION_TIMES", comment: "")
                if (timeArray?.count > 0) {
                    let timeString = DCSchedulingHelper.administratingTimesStringFromTimeArray(timeArray!)
                    schedulingCell!.descriptionLabel.text = timeString as String
                }
            } else if (indexPath.row == 1) {
                schedulingCell!.titleLabel?.text = NSLocalizedString("REPEAT", comment: "")
                schedulingCell!.descriptionLabel.text = scheduling?.repeatObject?.repeatType
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
        
        if (self.scheduling?.type == nil) {
            return INITIAL_SECTION_COUNT
        } else {
            return TOTAL_SECTION_COUNT
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 2
        } else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (self.scheduling?.type == nil) {
            let schedulingCell : DCSchedulingCell? = frequencyCellAtIndexPath(indexPath)
            return schedulingCell!
        } else {
            if (indexPath.row == DESCRIPTION_CELL_INDEX) {
                // display description field for specific times scheduling
                let descriptionCell : DCSchedulingDescriptionTableCell? = descriptionCellAtIndexPath(indexPath)
                return descriptionCell!
            } else {
                let schedulingCell : DCSchedulingCell? = frequencyCellAtIndexPath(indexPath)
                return schedulingCell!
            }
        }
     }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (indexPath.row == DESCRIPTION_CELL_INDEX) {
            return INSTRUCTIONS_ROW_HEIGHT
        } else {
            return TABLE_VIEW_ROW_HEIGHT
        }
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            self.scheduling?.type = (indexPath.row == 0) ? SPECIFIC_TIMES : INTERVAL
            if (self.scheduling?.repeatObject?.repeatType == nil) {
                self.scheduling?.repeatObject = DCRepeat.init()
                self.scheduling?.repeatObject.repeatType = DAILY
                self.scheduling?.repeatObject.frequency = "1 day"
                self.scheduling?.schedulingDescription = String(format: "%@ day.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""))
            }
            tableView.beginUpdates()
            let sectionCount = tableView.numberOfSections
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            if (sectionCount == INITIAL_SECTION_COUNT) {
                //if section count is zero insert new section with animation
                tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
            } else {
                //other wise reload the same section
                tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
            }
            tableView.endUpdates()

        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                presentAdministrationTimeView()
            } else if (indexPath.row == 1) {
                displaySchedulingDetailViewControllerForSelectedIndexPath(indexPath)
            }
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
        
        schedulingTableView.setContentOffset(CGPointMake(0, 80), animated: true)
    }
    
    func updateTextViewText(instructions: String!, isInstruction: Bool) {
        
        self.scheduling?.schedulingDescription = instructions
    }
    
    //MARK: Add Medication Detail Delegate Methods
    
    func updatedAdministrationTimeArray(timeArray: [AnyObject]!) {
        
        //new administration time added
        self.timeArray = NSMutableArray(array: timeArray)
        self.updatedTimeArray(self.timeArray)
    }
}
