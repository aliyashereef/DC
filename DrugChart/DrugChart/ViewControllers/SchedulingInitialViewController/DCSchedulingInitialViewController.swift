//
//  DCSchedulingInitialViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 12/1/15.
//
//

import UIKit
import CocoaLumberjack

let INITIAL_SECTION_COUNT : NSInteger = 1
let TOTAL_SECTION_COUNT : NSInteger = 2
let TABLE_SECTION_HEIGHT : CGFloat = 10.0
let DESCRIPTION_CELL_INDEX : NSInteger = 2
let INSTRUCTIONS_ROW_HEIGHT : CGFloat = 78
let FREQUENCY_TYPES_COUNT : NSInteger = 2
let SPECIFIC_TIMES_ROW_COUNT : NSInteger = 3
let INTERVAL_ROW_COUNT : NSInteger = 5


typealias SelectedScheduling = DCScheduling? -> Void
typealias UpdatedTimeArray = NSMutableArray? -> Void

class DCSchedulingInitialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, InstructionCellDelegate, AddMedicationDetailDelegate, SchedulingTimeCellDelegate {

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
        schedulingDetailViewController?.detailType = DCSchedulingHelper.schedulingDetailTypeAtIndexPath(indexPath, forFrequencyType: (self.scheduling?.type)!)
        if indexPath.section == 0 {
            if (self.scheduling?.type != nil) {
                schedulingDetailViewController?.previousFilledValue = (self.scheduling?.type)!
            }
        }
        schedulingDetailViewController?.frequencyValue = { value in
            //inside our closure
            DDLogDebug("Frequency value is \(value)")
            self.scheduling?.type = String(value!)
            if (self.scheduling?.specificTimes?.repeatObject?.repeatType == nil) {
                self.scheduling?.specificTimes?.repeatObject = DCRepeat.init()
                self.scheduling?.specificTimes?.repeatObject.repeatType = DAILY
                self.scheduling?.specificTimes?.repeatObject.frequency = "1 day"
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
            DDLogDebug("Value is \(value)")
        }
        medicationDetailViewController!.detailType = eDetailAdministrationTime
        medicationDetailViewController!.contentArray = timeArray
        self.navigationController?.pushViewController(medicationDetailViewController!, animated: true)
    }
    
    func frequencyCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingCell {
        
        //configure scheduling table cell
        let schedulingCell : DCSchedulingCell? = schedulingTableView.dequeueReusableCellWithIdentifier(SCHEDULING_INITIAL_CELL_ID) as? DCSchedulingCell
        if (indexPath.section == 1) {
            schedulingCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            if (scheduling?.type == SPECIFIC_TIMES) {
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
                    schedulingCell!.descriptionLabel.text = scheduling?.specificTimes?.repeatObject?.repeatType
                } else {
                    schedulingCell!.titleLabel?.text = NSLocalizedString("DESCRIPTION", comment: "")
                }
            } else {
                //configure section 1 for scheduling type interval
                switch indexPath.row {
                case 0 :
                    schedulingCell!.titleLabel?.text = NSLocalizedString("REPEAT_FREQUENCY", comment: "")
                    var repeatFrequency : NSString = EMPTY_STRING
                    var unit : NSString = EMPTY_STRING
                    if (scheduling?.interval?.repeatFrequencyType == DAYS_TITLE) {
                        if (scheduling?.interval?.daysCount != nil) {
                            unit = ((scheduling?.interval?.daysCount)! == "1") ? DAY : DAYS
                            repeatFrequency = NSString(format: "%@ %@", (scheduling?.interval?.daysCount)!, unit)
                        }
                    } else if (scheduling?.interval?.repeatFrequencyType == HOURS_TITLE) {
                        if (scheduling?.interval?.hoursCount != nil) {
                            unit = ((scheduling?.interval?.hoursCount)! == "1") ? HOUR : HOURS
                            repeatFrequency = NSString(format: "%@ %@", (scheduling?.interval?.hoursCount)!, unit)
                        }
                    } else if (scheduling?.interval?.repeatFrequencyType == MINUTES_TITLE) {
                        if (scheduling?.interval?.minutesCount != nil) {
                            unit = ((scheduling?.interval?.minutesCount)! == "1") ? MINUTE : MINUTES
                            repeatFrequency = NSString(format: "%@ %@", (scheduling?.interval?.minutesCount)!, unit)
                        }
                    }
                    schedulingCell!.descriptionLabel.text = repeatFrequency as String
                    break
                default :
                    break
                }
            }
        }
        return schedulingCell!
    }
    
    func timeCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingTimeCell {
        
        // scheduling time cell
        let timeCell = schedulingTableView.dequeueReusableCellWithIdentifier(SCHEDULING_TIME_CELL_ID) as? DCSchedulingTimeCell
        timeCell!.schedulingCellDelegate = self
        if (indexPath.row == 1) {
            timeCell?.selectionStyle = .None
            timeCell?.configureSetStartAndEndTimeCell()
        } else if (indexPath.row == 2) {
            let startTime = self.scheduling?.interval?.startTime == nil ? EMPTY_STRING : self.scheduling?.interval?.startTime
            timeCell?.configureTimeCellForTimeType(NSLocalizedString("START_TIME", comment: "start time title"), withSelectedValue:startTime!)
        } else if (indexPath.row == 3) {
            let endTime = self.scheduling?.interval?.endTime == nil ? EMPTY_STRING : self.scheduling?.interval?.endTime
            timeCell?.configureTimeCellForTimeType(NSLocalizedString("END_TIME", comment: "end time title"), withSelectedValue: endTime!)
        }
        return timeCell!
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
    
    func specificTimescellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == DESCRIPTION_CELL_INDEX) {
            // display description field for specific times scheduling
            let descriptionCell : DCSchedulingDescriptionTableCell? = descriptionCellAtIndexPath(indexPath)
            return descriptionCell!
        } else {
            let schedulingCell : DCSchedulingCell? = frequencyCellAtIndexPath(indexPath)
            return schedulingCell!
        }
    }
    
    func intervalCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            //repeat frequency cell
            let repeatFrequencyCell : DCSchedulingCell? = frequencyCellAtIndexPath(indexPath)
            return repeatFrequencyCell!
        } else if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3) {
            let timeCell = timeCellAtIndexPath(indexPath)
            return timeCell
        } else {
            let descriptionCell : DCSchedulingDescriptionTableCell? = descriptionCellAtIndexPath(indexPath)
            return descriptionCell!
        }
    }
    
    func configureFrequencyTableForFrequencyTypeSelectionAtindexPath(indexPath : NSIndexPath) {
        
        //check which frequenct type is selected and animate table sections based on that
        self.scheduling?.type = (indexPath.row == 0) ? SPECIFIC_TIMES : INTERVAL
        if (self.scheduling?.type == SPECIFIC_TIMES) {
            if (self.scheduling?.specificTimes == nil) {
                self.scheduling?.specificTimes = DCSpecificTimes.init()
                self.scheduling?.specificTimes?.repeatObject = DCRepeat.init()
                self.scheduling?.specificTimes?.repeatObject.repeatType = DAILY
                self.scheduling?.specificTimes?.repeatObject.frequency = "1 day"
                self.scheduling?.schedulingDescription = String(format: "%@ day.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""))
            }
        } else {
            if (self.scheduling?.interval == nil) {
                //initialise interval
                self.scheduling?.interval = DCInterval.init()
                //initial SetStartAndEndDate switch should be true
                self.scheduling?.interval?.hasStartAndEndDate = true
            }
        }
        schedulingTableView.beginUpdates()
        let sectionCount = schedulingTableView.numberOfSections
        schedulingTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        if (sectionCount == INITIAL_SECTION_COUNT) {
            //if section count is zero insert new section with animation
            schedulingTableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
        } else {
            //other wise reload the same section
            schedulingTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
        }
        schedulingTableView.endUpdates()
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
            return FREQUENCY_TYPES_COUNT
        } else {
            if (self.scheduling?.type == SPECIFIC_TIMES) {
                return SPECIFIC_TIMES_ROW_COUNT
            } else {
                if (self.scheduling?.interval?.hasStartAndEndDate == true) {
                    return 5
                } else {
                    return 3
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            //highlight field in red if scheduling type is nil when save button is pressed in add medication screen
            let schedulingCell : DCSchedulingCell? = frequencyCellAtIndexPath(indexPath)
            if (indexPath.row == 0) {
                schedulingCell!.titleLabel?.text = SPECIFIC_TIMES
                schedulingCell?.accessoryType = scheduling?.type == SPECIFIC_TIMES ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            } else {
                schedulingCell!.titleLabel?.text = INTERVAL
                schedulingCell?.accessoryType = scheduling?.type == INTERVAL ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            }
            schedulingCell?.descriptionLabel.hidden = true
            return schedulingCell!
        } else {
            if (self.scheduling?.type == SPECIFIC_TIMES) {
                let specificTimesCell = specificTimescellAtIndexPath(indexPath)
                return specificTimesCell
            } else {
                let intervalCell = intervalCellAtIndexPath(indexPath)
                return intervalCell
            }
        }
     }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (self.scheduling?.type == SPECIFIC_TIMES) {
            return indexPath.row == DESCRIPTION_CELL_INDEX ? INSTRUCTIONS_ROW_HEIGHT : TABLE_VIEW_ROW_HEIGHT
        } else {
            if (self.scheduling?.interval?.hasStartAndEndDate == true) {
                return indexPath.row == 4 ? INSTRUCTIONS_ROW_HEIGHT : TABLE_VIEW_ROW_HEIGHT
            } else {
                return indexPath.row == 2 ? INSTRUCTIONS_ROW_HEIGHT : TABLE_VIEW_ROW_HEIGHT
            }
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0) {
            configureFrequencyTableForFrequencyTypeSelectionAtindexPath(indexPath)
        } else {
            if (self.scheduling?.type == SPECIFIC_TIMES) {
                if (indexPath.row == 0) {
                    presentAdministrationTimeView()
                } else if (indexPath.row == 1) {
                    displaySchedulingDetailViewControllerForSelectedIndexPath(indexPath)
                }
            } else {
                //cell selection for interval table cells
                if (indexPath.row == 0) {
                    displaySchedulingDetailViewControllerForSelectedIndexPath(indexPath)
                }
                
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
        
        schedulingTableView.setContentOffset(CGPointMake(0, 90), animated: true)
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
    
    //MARK: SchedulingTimeCell Delegate Methods
    
    func setStartEndTimeSwitchValueChanged(state : Bool) {
        
        //configure table based on the switch state
        let timeCell = schedulingTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as? DCSchedulingTimeCell
        timeCell?.timeSwitch.userInteractionEnabled = false
        self.scheduling?.interval?.hasStartAndEndDate = state
         schedulingTableView.beginUpdates()
        let indexPathsArray = [NSIndexPath(forRow: 2, inSection: 1), NSIndexPath(forRow: 3, inSection: 1)]
        if (state == false) {
            //delete start time, end time table cells
            schedulingTableView.deleteRowsAtIndexPaths(indexPathsArray, withRowAnimation: .Fade)
        } else {
            schedulingTableView.insertRowsAtIndexPaths(indexPathsArray, withRowAnimation: .Fade)
        }
        schedulingTableView.endUpdates()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            timeCell?.timeSwitch.userInteractionEnabled = true
        }
    }
}
