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
let INTERVAL_SECTION_INITIAL_COUNT : NSInteger = 2
let INTERVAL_SECTION_PREVIEW_COUNT : NSInteger = 3
let SPECIFIC_TIMES_SECTION_COUNT : NSInteger = 2
let FREQUENCY_TYPES_COUNT : NSInteger = 2
let SPECIFIC_TIMES_ROW_COUNT : NSInteger = 2
let TIME_PICKER_CELL_HEIGHT : CGFloat = 216.0
let START_TIME_PICKER_ROW_INDEX : NSInteger = 3
let PREVIEW_SECTION_INDEX : NSInteger = 2

typealias SelectedScheduling = DCScheduling? -> Void

class DCSchedulingInitialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SchedulingTimeCellDelegate, SchedulingDetailDelegate, AdministrationTimesDelegate {

    @IBOutlet weak var schedulingTableView: UITableView!
    
    var scheduling : DCScheduling?
    var previewArray : NSMutableArray? = []
    var isEditMedication : Bool?
    var validate : Bool = false
    var selectedSchedulingValue : SelectedScheduling = {value in }
    var inlinePickerIndexPath : NSIndexPath?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if (scheduling?.type == INTERVAL && scheduling?.interval?.administratingTimes.count > 0) {
            //if scheduling type is interval, form preview array
            previewArray = DCSchedulingHelper.intervalPreviewArrayFromAdministrationTimeDetails((scheduling?.interval?.administratingTimes!)!)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        configureNavigationBarItems()
        schedulingTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        schedulingTableView.reloadData()
        schedulingTableView.layoutIfNeeded()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.selectedSchedulingValue(scheduling)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Private Methods
    
    func configureNavigationBarItems() {
        
        self.navigationItem.title = NSLocalizedString("FREQUENCY", comment: "")
        self.title = NSLocalizedString("FREQUENCY", comment: "")
    }

    func displaySchedulingDetailViewControllerForSelectedIndexPath(indexPath : NSIndexPath) {
        
        let storyBoard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let schedulingDetailViewController = storyBoard.instantiateViewControllerWithIdentifier(SCHEDULING_DETAIL_STORYBOARD_ID) as? DCSchedulingDetailViewController
        schedulingDetailViewController?.scheduling = self.scheduling
        if (self.scheduling?.type == SPECIFIC_TIMES) {
            schedulingDetailViewController?.administratingTimes = self.scheduling?.specificTimes?.administratingTimesArray
        } else if (self.scheduling?.type == INTERVAL) {
            schedulingDetailViewController?.administratingTimes = self.scheduling?.interval?.administratingTimes
        }
        schedulingDetailViewController?.detailDelegate = self
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
                self.scheduling?.specificTimes?.specificTimesDescription = String(format: "%@ day.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""))
            }
            self.schedulingTableView.reloadData()
        }
        schedulingDetailViewController?.schedulingCompletion = { schedule in
            self.scheduling = schedule
            self.schedulingTableView.reloadData()
        }
        self.configureNavigationBackButtonTitle()
        self.navigationController?.pushViewController(schedulingDetailViewController!, animated: true)
    }
    
    func configureNavigationBackButtonTitle () {
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: self.title, style: .Plain, target: nil, action: nil)
    }

    func presentAdministrationTimeView() {
        
        let storyBoard = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil)
        let administrationTimesViewController = storyBoard.instantiateViewControllerWithIdentifier(ADMINISTRATION_TIMES_SB_ID) as? DCAdministrationTimesViewController
        administrationTimesViewController!.delegate = self
        if (self.scheduling?.type == SPECIFIC_TIMES) {
            if let adminArray = self.scheduling?.specificTimes?.administratingTimesArray {
                administrationTimesViewController!.timeArray = adminArray
            }
        } else {
            if let administrationTimeArray = self.scheduling?.interval.administratingTimes {
                administrationTimesViewController!.timeArray = administrationTimeArray
            }
        }
        self.configureNavigationBackButtonTitle()
        self.navigationController?.pushViewController(administrationTimesViewController!, animated: true)
    }
    
    func frequencyCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingCell {
        
        //configure scheduling table cell
        let schedulingCell : DCSchedulingCell? = schedulingTableView.dequeueReusableCellWithIdentifier(SCHEDULING_INITIAL_CELL_ID) as? DCSchedulingCell
        schedulingCell?.selectionStyle = .Default
        schedulingCell?.descriptionLabel.hidden = false
        schedulingCell!.titleLabel.textColor = UIColor.blackColor()
        if (indexPath.section == 1) {
            schedulingCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            if (scheduling?.type == SPECIFIC_TIMES) {
                if (indexPath.row == 0) {
                    //highlight field in red if time array is empty when save button is pressed in add medication screen
                    schedulingCell!.titleLabel.textColor = (validate &&  (scheduling?.specificTimes?.administratingTimesArray == nil || scheduling?.specificTimes?.administratingTimesArray.count == 0)) ? UIColor.redColor() : UIColor.blackColor()
                    schedulingCell!.titleLabel?.text = NSLocalizedString("ADMINISTRATION_TIMES", comment: "")
                    if (scheduling?.specificTimes?.administratingTimesArray?.count > 0) {
                        let timeString = DCSchedulingHelper.administratingTimesStringFromTimeArray((scheduling?.specificTimes?.administratingTimesArray!)!)
                        schedulingCell!.descriptionLabel.text = timeString as String
                    } else {
                        schedulingCell!.descriptionLabel.text = EMPTY_STRING
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
                    schedulingCell!.titleLabel?.text = NSLocalizedString("REPEAT", comment: "")
                    var repeatFrequency : NSString = EMPTY_STRING
                    var unit : NSString = EMPTY_STRING
                    if (scheduling?.interval?.repeatFrequencyType == DAYS_TITLE) {
                        if (scheduling?.interval?.daysCount != nil) {
                            unit = ((scheduling?.interval?.daysCount)! == ONE) ? DAY : DAYS
                            repeatFrequency = NSString(format: "%@ %@", (scheduling?.interval?.daysCount)!, unit)
                        }
                    } else if (scheduling?.interval?.repeatFrequencyType == HOURS_TITLE) {
                        if (scheduling?.interval?.hoursCount != nil) {
                            unit = ((scheduling?.interval?.hoursCount)! == ONE) ? HOUR : HOURS
                            repeatFrequency = NSString(format: "%@ %@", (scheduling?.interval?.hoursCount)!, unit)
                        }
                    } else if (scheduling?.interval?.repeatFrequencyType == MINUTES_TITLE) {
                        if (scheduling?.interval?.minutesCount != nil) {
                            unit = ((scheduling?.interval?.minutesCount)! == ONE) ? MINUTE : MINUTES
                            repeatFrequency = NSString(format: "%@ %@", (scheduling?.interval?.minutesCount)!, unit)
                        }
                    }
                    schedulingCell!.descriptionLabel.text = repeatFrequency as String
                default :
                    break
                }
            }
        }
        return schedulingCell!
    }
    
    func previewCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingCell {
        
        //configure scheduling table cell
        let previewCell : DCSchedulingCell? = schedulingTableView.dequeueReusableCellWithIdentifier(SCHEDULING_INITIAL_CELL_ID) as? DCSchedulingCell
        previewCell?.descriptionLabel.hidden = true
        previewCell?.accessoryType = .None
        previewCell?.titleLabel.textColor = UIColor.blackColor()
        previewCell?.titleLabel.text = previewArray![indexPath.item] as? String
        previewCell?.selectionStyle = .None
        return previewCell!
    }
    
    func timeCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingTimeCell {
        
        // scheduling time cell
        let timeCell = schedulingTableView.dequeueReusableCellWithIdentifier(SCHEDULING_TIME_CELL_ID) as? DCSchedulingTimeCell
        timeCell!.schedulingCellDelegate = self
        if (indexPath.row == 1) {
            let switchState = (self.scheduling?.interval?.hasStartAndEndDate == nil) ? false : self.scheduling?.interval?.hasStartAndEndDate
            timeCell?.selectionStyle = .None
            timeCell?.configureSetStartAndEndTimeCellForSwitchState(switchState!)
        } else if (indexPath.row == 2) {
            let startTime = self.scheduling?.interval?.startTime == nil ? EMPTY_STRING : self.scheduling?.interval?.startTime
            timeCell?.configureTimeCellForTimeType(NSLocalizedString("START_TIME", comment: "start time title"), withSelectedValue:startTime!)
        } else if (indexPath.row == 3 || indexPath.row == 4) {
            let endTime = self.scheduling?.interval?.endTime == nil ? EMPTY_STRING : self.scheduling?.interval?.endTime
            timeCell?.configureTimeCellForTimeType(NSLocalizedString("END_TIME", comment: "end time title"), withSelectedValue: endTime!)
        }
        return timeCell!
    }
    
    func specificTimescellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        let schedulingCell : DCSchedulingCell? = frequencyCellAtIndexPath(indexPath)
        return schedulingCell!
    }
    
    func intervalCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            //repeat frequency cell
            let repeatFrequencyCell : DCSchedulingCell? = frequencyCellAtIndexPath(indexPath)
            return repeatFrequencyCell!
        }
        
        if (self.scheduling?.interval.hasStartAndEndDate == false) {
            let timeCell = timeCellAtIndexPath(indexPath)
            return timeCell
        } else {
            if (self.inlinePickerIndexPath == nil) {
                let timeCell = timeCellAtIndexPath(indexPath)
                return timeCell
            } else {
                if (indexPath.row == self.inlinePickerIndexPath?.row) {
                    let pickerCell = intervalTimePickerCell(indexPath)
                    return pickerCell
                } else {
                    let timeCell = timeCellAtIndexPath(indexPath)
                    return timeCell
                }
            }
        }
     }
    
    func intervalTimePickerCell(indexPath : NSIndexPath) -> DCSChedulingTimePickerCell {
        
        //configure scheduling table cell
        let timePickerCell : DCSChedulingTimePickerCell? = schedulingTableView.dequeueReusableCellWithIdentifier(SCHEDULING_DATE_PICKER_CELL_ID) as? DCSChedulingTimePickerCell
        let currentDateString = DCDateUtility.dateStringFromDate(NSDate(), inFormat: SHORT_DATE_FORMAT)
        let startTimeString = String(format: "%@ %@", currentDateString, (self.scheduling?.interval?.startTime)!)
        if (indexPath.row == START_TIME_PICKER_ROW_INDEX) {
            timePickerCell!.isStartTimePicker = true
            timePickerCell?.previousSelectedTime = DCDateUtility.dateFromSourceString(startTimeString)
            timePickerCell!.schedulingTimePickerView?.minimumDate = .None
        } else {
            timePickerCell!.isStartTimePicker = false
            let endTimeString = String(format: "%@ %@", currentDateString, (self.scheduling?.interval?.endTime)!)
            timePickerCell!.schedulingTimePickerView?.minimumDate = DCDateUtility.dateFromSourceString(startTimeString)
            timePickerCell?.previousSelectedTime = DCDateUtility.dateFromSourceString(endTimeString)
        }
        timePickerCell!.timePickerCompletion = { time in
            if (timePickerCell!.isStartTimePicker == true) {
                self.scheduling?.interval?.startTime = time as? String
            } else {
                self.scheduling?.interval?.endTime = time as? String
            }
            if (self.scheduling?.type == INTERVAL) {
                self.scheduling?.interval?.intervalDescription = DCSchedulingHelper.scheduleDescriptionForIntervalValue((self.scheduling?.interval)!) as String
            }
            UIView.setAnimationsEnabled(false)
            self.schedulingTableView.beginUpdates()
            self.schedulingTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)], withRowAnimation: .Fade)
            if let footerView = self.schedulingTableView.footerViewForSection(1) {
                footerView.textLabel!.text = self.scheduling?.interval?.intervalDescription
                footerView.sizeToFit()
            }
            self.populatePreviewArray()
            self.reloadIntervalPreviewSection()
            self.schedulingTableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        timePickerCell?.populatePickerWithPreviousSelectedTime()
        return timePickerCell!
    }
    
    func populatePreviewArray() {
        
        //populate preview array & reload the corresponding section
        
         self.previewArray?.removeAllObjects()
        if (self.scheduling?.interval?.repeatFrequencyType == DAYS_TITLE) {
            if (self.scheduling?.interval?.startTime != nil) {
                self.previewArray?.addObject((self.scheduling?.interval?.startTime)!)
                let administrationTimeArray = createAdministrationTimesArrayFromPreview()
                self.scheduling?.interval?.administratingTimes = administrationTimeArray
            }
        } else if (self.scheduling?.interval?.repeatFrequencyType == HOURS_TITLE || self.scheduling?.interval?.repeatFrequencyType == MINUTES_TITLE) {
            
            let pickerType = self.scheduling?.interval?.repeatFrequencyType == HOURS_TITLE ? eHoursCount : eMinutesCount
            var timeGap : Int = 0
            if (self.scheduling?.interval?.repeatFrequencyType == HOURS_TITLE) {
                timeGap = Int((self.scheduling?.interval?.hoursCount)!)!
            } else {
                timeGap = Int((self.scheduling?.interval?.minutesCount)!)!
            }
            self.previewArray = DCSchedulingHelper.administrationTimesForIntervalSchedulingWithRepeatFrequencyType(pickerType, timeGap: timeGap, WithStartDateString: (self.scheduling?.interval?.startTime)!, WithendDateString: (self.scheduling?.interval?.endTime)!)
            let administrationTimeArray = createAdministrationTimesArrayFromPreview()
            self.scheduling?.interval?.administratingTimes = administrationTimeArray
        }
    }
    
    func reloadIntervalPreviewSection() {
        
        if (self.scheduling?.interval?.hasStartAndEndDate == true && self.previewArray?.count > 0) {
            self.schedulingTableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Middle)
        }
    }
    
    func createAdministrationTimesArrayFromPreview () -> NSMutableArray {
        
        let administrationTimeArray : NSMutableArray? = []
        for time in self.previewArray! {
            let timesDictionary : NSMutableDictionary = [:]
            timesDictionary["time"] = time
            timesDictionary["selected"] = 1
            administrationTimeArray!.addObject(timesDictionary)
        }
        return administrationTimeArray!
    }
    
    func initialiseSpecificTimesObjectInFrequency() {
        
        // initialise specific times object
        self.scheduling?.specificTimes = DCSpecificTimes.init()
        self.scheduling?.specificTimes?.repeatObject = DCRepeat.init()
        self.scheduling?.specificTimes?.repeatObject.repeatType = DAILY
        self.scheduling?.specificTimes?.repeatObject.frequency = "1 day"
        if (scheduling?.specificTimes?.administratingTimesArray == nil) {
            scheduling?.specificTimes?.administratingTimesArray = []
        }
        self.scheduling?.specificTimes?.specificTimesDescription =  DCSchedulingHelper.scheduleDescriptionForSpecificTimesRepeatValue((self.scheduling?.specificTimes?.repeatObject)!, administratingTimes: (scheduling?.specificTimes?.administratingTimesArray!)!) as String
        self.scheduling?.specificTimes?.administratingTimesArray = []
    }
    
    func initialiseIntervalObjectInFrequency() {
        
        //initialise interval object in scheduling
        self.scheduling?.interval = DCInterval.init()
        //initial SetStartAndEndDate switch should be false
        self.scheduling?.interval?.hasStartAndEndDate = false
        self.scheduling?.interval?.repeatFrequencyType = HOURS_TITLE
        self.scheduling?.interval.hoursCount = ONE
        self.scheduling?.interval?.intervalDescription = String(format: "%@ hour.", NSLocalizedString("DAILY_DESCRIPTION", comment: ""))
        if (self.scheduling?.interval?.startTime == nil) {
            let startTimeInCurrentZone  = DCDateUtility.dateInCurrentTimeZone(NSDate())
            let startTime = DCDateUtility.timeStringInTwentyFourHourFormat(startTimeInCurrentZone)
            self.scheduling?.interval?.startTime = startTime
            self.scheduling?.interval?.endTime = "23:00"
            populatePreviewArray()
            reloadIntervalPreviewSection()
        }
    }
    
    func configureFrequencyTableForFrequencyTypeSelectionAtindexPath(indexPath : NSIndexPath) {
        
        //check which frequenct type is selected and animate table sections based on that
        self.scheduling?.type = (indexPath.row == 0) ? SPECIFIC_TIMES : INTERVAL
        if (self.scheduling?.type == SPECIFIC_TIMES) {
            //initialise specific times object if specific times object is nil
            if (self.scheduling?.specificTimes == nil) {
                initialiseSpecificTimesObjectInFrequency()
             }
        } else {
            if (self.scheduling?.interval == nil) {
                //initialise interval if interval object in scheduling is nil
                initialiseIntervalObjectInFrequency()
            }
        }
        dispatch_async(dispatch_get_main_queue(), {
            let sectionCount = self.schedulingTableView.numberOfSections
            self.schedulingTableView.beginUpdates()
            if (sectionCount == INITIAL_SECTION_COUNT) {
                //if section count is zero insert new section with animation
                self.schedulingTableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
                if (self.scheduling?.type == INTERVAL && self.scheduling?.interval?.hasStartAndEndDate == true && self.previewArray?.count > 0) {
                    self.schedulingTableView.insertSections(NSIndexSet(index: 2), withRowAnimation: .Middle)
                }
            } else {
                //other wise reload the same section
                if (self.scheduling?.type == SPECIFIC_TIMES) {
                    self.schedulingTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
                    if (sectionCount == INTERVAL_SECTION_PREVIEW_COUNT) {
                        self.schedulingTableView.deleteSections(NSIndexSet(index: 2), withRowAnimation: .Middle)
                    }
                } else {
                    self.schedulingTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
                    if (sectionCount == INTERVAL_SECTION_INITIAL_COUNT && self.scheduling?.interval?.hasStartAndEndDate == true) {
                        if (self.previewArray?.count == 0) {
                            self.populatePreviewArray()
                        }
                        self.schedulingTableView.insertSections(NSIndexSet(index: 2), withRowAnimation: .Middle)
                    } else {
                        if (self.scheduling?.interval?.hasStartAndEndDate == true && self.previewArray?.count > 0) {
                            self.schedulingTableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Middle)
                        }
                    }
                }
            }
            self.schedulingTableView.endUpdates()
            self.schedulingTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        })
    }
    
    func tableViewHasInlinePickerForSection (section : NSInteger) -> Bool {
        
        return (self.inlinePickerIndexPath != nil && section == self.inlinePickerIndexPath?.section)
    }
    
    func indexPathHasPicker(indexPath : NSIndexPath) -> Bool {
        
        return (tableViewHasInlinePickerForSection(indexPath.section) && self.inlinePickerIndexPath!.row == indexPath.row);
    }
    
    func displayInlinePickerForRowAtIndexPath(indexPath : NSIndexPath) {
        
        schedulingTableView.beginUpdates()
        var pickerBeforeSelectedIndexPath = false
        var sameCellClicked = false
        if (self.inlinePickerIndexPath != nil) {
            pickerBeforeSelectedIndexPath = self.inlinePickerIndexPath!.row < indexPath.row
            if (tableViewHasInlinePickerForSection(indexPath.section)) {
                sameCellClicked = (self.inlinePickerIndexPath!.row - 1 == indexPath.row);
            }
            let pickerIndexPath : NSIndexPath = self.inlinePickerIndexPath!
            self.inlinePickerIndexPath = nil
            schedulingTableView.deleteRowsAtIndexPaths([pickerIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        // remove any picker cell if it exists
        if (!sameCellClicked) {
            // hide the date picker and display the new one
            let rowToReveal : NSInteger = (pickerBeforeSelectedIndexPath ? indexPath.row - 1 : indexPath.row);
            let indexPathToReveal : NSIndexPath = NSIndexPath(forItem: rowToReveal, inSection: indexPath.section)
            togglePickerForSelectedIndexPath(indexPathToReveal)
            self.inlinePickerIndexPath = NSIndexPath(forItem: indexPathToReveal.row + 1, inSection: indexPath.section)
        }
        schedulingTableView.deselectRowAtIndexPath(indexPath, animated: true)
        schedulingTableView.endUpdates()
    }
    
    func togglePickerForSelectedIndexPath(indexPath : NSIndexPath) {
        
        let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
        if (tableViewHasInlinePickerForSection(indexPath.section)) {
            schedulingTableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            // didn't find a picker below it, so we should insert it
            schedulingTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func schedulingDescriptionFooterText() -> String {
        
        var schedulingDescription : NSString = EMPTY_STRING
        if (scheduling?.type == INTERVAL) {
            schedulingDescription = (scheduling?.interval?.intervalDescription)!
        } else {
            if (scheduling?.specificTimes?.repeatObject != nil && scheduling?.specificTimes?.administratingTimesArray?.count > 0) {
                schedulingDescription = DCSchedulingHelper.scheduleDescriptionForSpecificTimesRepeatValue((scheduling?.specificTimes?.repeatObject)!, administratingTimes: (scheduling?.specificTimes?.administratingTimesArray!)!)
                scheduling?.specificTimes?.specificTimesDescription = schedulingDescription as String
            } else {
                if let description = scheduling?.specificTimes?.specificTimesDescription {
                    schedulingDescription = description
                }
            }
        }
        return String(format: "%@", schedulingDescription)
    }
    // MARK: TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (self.scheduling?.type == nil) {
            return INITIAL_SECTION_COUNT
        } else if (self.scheduling?.type == SPECIFIC_TIMES) {
            return SPECIFIC_TIMES_SECTION_COUNT
        } else {
            if (self.scheduling?.interval.hasStartAndEndDate == true && previewArray?.count > 0) {
                return INTERVAL_SECTION_PREVIEW_COUNT
            } else {
                return INTERVAL_SECTION_INITIAL_COUNT
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return FREQUENCY_TYPES_COUNT
        } else if (section == 1) {
            if (self.scheduling?.type == SPECIFIC_TIMES) {
                return SPECIFIC_TIMES_ROW_COUNT
            } else {
                var rowCount : NSInteger = 2
                if (self.scheduling?.interval?.hasStartAndEndDate == true) {
                    rowCount = 4
                }
                if (tableViewHasInlinePickerForSection(section)) {
                    rowCount++
                }
                return rowCount
            }
        } else {
            return (previewArray?.count)!
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
        } else if (indexPath.section == 1) {
            if (self.scheduling?.type == SPECIFIC_TIMES) {
                let specificTimesCell = specificTimescellAtIndexPath(indexPath)
                return specificTimesCell
            } else {
                let intervalCell = intervalCellAtIndexPath(indexPath)
                return intervalCell
            }
        } else {
            //section 3 is for interval when any time is selcetd
            let previewCell : DCSchedulingCell? = previewCellAtIndexPath(indexPath)
            return previewCell!
        }
     }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if (self.scheduling?.type == INTERVAL && section == PREVIEW_SECTION_INDEX) {
            //display preview text for
            return PREVIEW
        }
        return nil
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        //Set the header as PREVIEW
        if section == 1 {
            let schedulingDescription : NSString = schedulingDescriptionFooterText()
            return schedulingDescription as String
        }
        return nil
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        //Change text color to red and change text from full upper case to desired sentence.
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel!.font = UIFont.systemFontOfSize(14.0)
        }
    }

    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 1 {
            let schedulingDescription : NSString = schedulingDescriptionFooterText()
            let headerHeight : CGFloat = DCUtility.textViewSizeWithText(String(format: "%@", schedulingDescription), maxWidth: 280, font: UIFont.systemFontOfSize(14.0)).height + 20
            return headerHeight
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (self.scheduling?.type == INTERVAL) {
            if (self.scheduling?.interval?.hasStartAndEndDate == true) {
                if (indexPathHasPicker(indexPath)) {
                    return TIME_PICKER_CELL_HEIGHT
                }
            }
        }
        return TABLE_VIEW_ROW_HEIGHT
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0) {
            configureFrequencyTableForFrequencyTypeSelectionAtindexPath(indexPath)
        } else if (indexPath.section != 2) {
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
                } else {
                    if (self.scheduling?.interval?.hasStartAndEndDate == true) {
                        if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4) {
                            displayInlinePickerForRowAtIndexPath (indexPath)
                        }
                    }
                }
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: Add Medication Detail Delegate Methods
    
    func updatedAdministrationTimeArray(timeArray : NSArray) {
        
        //new administration time added
        let newTimeArray = NSMutableArray(array: timeArray)
        if (self.scheduling?.type == SPECIFIC_TIMES) {
            self.scheduling?.specificTimes?.administratingTimesArray = newTimeArray
        } else {
            self.scheduling?.interval?.administratingTimes = newTimeArray
        }
       // self.updatedTimeArray(newTimeArray)
    }
    
    //MARK: SchedulingTimeCell Delegate Methods
    
    func setStartEndTimeSwitchValueChanged(state : Bool) {
        
        //configure table based on the switch state
        if (state != self.scheduling?.interval?.hasStartAndEndDate) {
            populatePreviewArray()
            let timeCell = schedulingTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as? DCSchedulingTimeCell
            timeCell?.timeSwitch.userInteractionEnabled = false
            self.scheduling?.interval?.hasStartAndEndDate = state
            self.scheduling?.interval?.intervalDescription = DCSchedulingHelper.scheduleDescriptionForIntervalValue((self.scheduling?.interval)!) as String
            let sectionCount = self.schedulingTableView.numberOfSections
            schedulingTableView.beginUpdates()
            let indexPathsArray : NSMutableArray = [NSIndexPath(forRow: 2, inSection: 1), NSIndexPath(forRow: 3, inSection: 1)]
            if (state == false) {
                //delete start time, end time table cells
                if(self.inlinePickerIndexPath != nil) {
                    indexPathsArray.addObject(self.inlinePickerIndexPath!)
                    self.inlinePickerIndexPath = nil
                }
                schedulingTableView.deleteRowsAtIndexPaths(indexPathsArray as NSArray as! [NSIndexPath], withRowAnimation: .Fade)
                if sectionCount == INTERVAL_SECTION_PREVIEW_COUNT {
                    schedulingTableView.deleteSections(NSIndexSet(index: 2), withRowAnimation: .Fade)
                }
            } else {
                schedulingTableView.insertRowsAtIndexPaths(indexPathsArray as NSArray as! [NSIndexPath], withRowAnimation: .Fade)
                if (previewArray?.count > 0) {
                    schedulingTableView.insertSections(NSIndexSet(index: 2), withRowAnimation: .Fade)
                }
            }
            schedulingTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
            schedulingTableView.endUpdates()
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                timeCell?.timeSwitch.userInteractionEnabled = true
            }
        }
    }
    
    //MARK: SCheduling Detail Delegate Methods
    
    func updatedIntervalPreviewArray(timesArray : NSMutableArray) {
        
        self.previewArray = NSMutableArray(array: timesArray)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // get administartion times
            if (self.previewArray?.count > 0) {
                let administrationTimeArray = self.createAdministrationTimesArrayFromPreview()
                self.scheduling?.interval?.administratingTimes = administrationTimeArray
            }
            dispatch_async(dispatch_get_main_queue()) {
                // reload table
                if (self.scheduling?.interval.hasStartAndEndDate == true) {
                    self.schedulingTableView.reloadData()
                }
            }
        }
    }
}
