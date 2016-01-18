//
//  DCSchedulingDetailViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 11/11/15.
//
//

import UIKit

let TABLE_VIEW_ROW_HEIGHT : CGFloat = 44.0
let PICKER_CELL_HEIGHT : CGFloat = 216.0
let WEEK_DAYS_COUNT : NSInteger = 7
let HEADER_VIEW_MIN_HEIGHT : CGFloat = 40
let HEADER_VIEW_LABEL_MAX_WIDTH : CGFloat = 265


typealias SchedulingCompletion = DCScheduling? -> Void
typealias SelectedFrequencyValue = NSString? -> Void

protocol SchedulingDetailDelegate {
    
    func updatedIntervalPreviewArray(timesArray : NSMutableArray)
}

class DCSchedulingDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var detailTableView: UITableView!
    
    var displayArray : NSMutableArray = []
    var weekDaysArray = NSMutableArray()
    var inlinePickerIndexPath : NSIndexPath?
    var scheduling : DCScheduling?
    var schedulingCompletion: SchedulingCompletion = { value in }
    var frequencyValue : SelectedFrequencyValue = {value in }
    var headerHeight : CGFloat = 0.0
    var detailType : SchedulingDetailType?
    var previousFilledValue : NSString = EMPTY_STRING
    var previewArray : NSMutableArray? = []
    var detailDelegate : SchedulingDetailDelegate?
    var administratingTimes : NSArray?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        prepareViewElements()
        populateDisplayArray()
        populateWeekDaysArray()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        detailTableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.schedulingCompletion(self.scheduling)
        super.viewWillDisappear(animated)
    }
    
    func configureNavigationView() {
        
        self.navigationController!.navigationBar.topItem!.title = "";
        if (detailType != nil) {
            self.title = DCSchedulingHelper.screenTitleForScreenType(detailType!)
        }
    }
    
    func prepareViewElements() {
        
        //set view properties and values
        //calculate header view height
        let schedulingDescription = (self.scheduling?.type == SPECIFIC_TIMES) ? self.scheduling?.specificTimes?.specificTimesDescription : self.scheduling?.interval?.intervalDescription
        headerHeight = DCUtility.textViewSizeWithText(schedulingDescription, maxWidth: HEADER_VIEW_LABEL_MAX_WIDTH, font: UIFont.systemFontOfSize(13.0)).height + 10
        detailTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        configureNavigationView()
    }
    
    func populateDisplayArray() {
        
        //populate display array
        if (self.detailType != nil) {
            displayArray = DCSchedulingHelper.scheduleDisplayArrayForScreenType(self.detailType!)
        }
    }
    
    
    func populateWeekDaysArray() {
        
        // week days array
        weekDaysArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    }
    
    func tableViewHasInlinePickerForSection (section : NSInteger) -> Bool {
        
        return (self.inlinePickerIndexPath != nil && section == self.inlinePickerIndexPath?.section)
    }

    func indexPathHasPicker(indexPath : NSIndexPath) -> Bool {
        
        return (tableViewHasInlinePickerForSection(indexPath.section) && self.inlinePickerIndexPath!.row == indexPath.row);
    }
    
    func inlinePickerCellAtIndexPath(indexPath : NSIndexPath, forPickerType pickerType : PickerType) -> DCSchedulingPickerCell {
        
        //display inline picker
        let pickerCell : DCSchedulingPickerCell? = detailTableView.dequeueReusableCellWithIdentifier(SCHEDULING_PICKER_CELL_ID) as? DCSchedulingPickerCell
        pickerCell?.weekDaysArray = weekDaysArray
        pickerCell?.repeatValue = scheduling?.specificTimes?.repeatObject
        pickerCell?.interval = scheduling?.interval
        pickerCell?.configurePickerCellForPickerType(pickerType)
        pickerCell?.pickerCompletion = { value in
            if (pickerType == eSchedulingFrequency) {
                self.scheduling?.specificTimes?.repeatObject?.repeatType = value as! String
                if (value == DAILY) {
                    self.displayArray = [FREQUENCY, EVERY]
                    self.scheduling?.specificTimes?.repeatObject?.frequency = DAY
                } else if (value == WEEKLY) {
                    self.scheduling?.specificTimes?.repeatObject.frequency = WEEK
                    self.displayArray = [FREQUENCY, EVERY]
                } else if (value == MONTHLY) {
                    self.scheduling?.specificTimes?.repeatObject?.frequency = MONTH
                    self.scheduling?.specificTimes?.repeatObject?.isEachValue = true
                    self.scheduling?.specificTimes?.repeatObject?.onTheValue = EMPTY_STRING
                    self.displayArray = [FREQUENCY, EVERY, EACH, ON_THE]
                } else if (value == YEARLY) {
                    self.scheduling?.specificTimes?.repeatObject?.frequency = YEAR
                    self.displayArray = [FREQUENCY, EVERY, EACH, ON_THE]
                    self.scheduling?.specificTimes?.repeatObject?.isEachValue = true
                    self.scheduling?.specificTimes?.repeatObject?.onTheValue = EMPTY_STRING
                }
                self.schedulingCompletion(self.scheduling)
                self.detailTableView.reloadData()
            } else {
                self.updateSchedulingDetailsForSelectedPickerType(pickerType, selectedValue: value!)
            }
        }
        return pickerCell!
    }
    
    func updateSchedulingDetailsForSelectedPickerType(pickerType : PickerType, selectedValue value : NSString) {
        
        //update scheduling details with selected picker values
        switch pickerType.rawValue {
            case eDailyCount.rawValue :
                let days = (value == ONE) ? DAY : DAYS
                self.scheduling?.specificTimes?.repeatObject?.frequency = NSString(format: "%@ %@", value, days) as String
            case eWeeklyCount.rawValue :
                let week = (value == ONE) ? WEEK : WEEKS
                self.scheduling?.specificTimes?.repeatObject?.frequency = NSString(format: "%@ %@", value, week) as String
            case eMonthlyCount.rawValue :
                let month = (value == ONE) ? MONTH : MONTHS
                self.scheduling?.specificTimes?.repeatObject?.frequency = NSString(format: "%@ %@", value, month) as String
            case eYearlyCount.rawValue :
                let year = (value == ONE) ? YEAR : YEARS
                self.scheduling?.specificTimes?.repeatObject?.frequency = NSString(format: "%@ %@", value, year) as String
            case eMonthEachCount.rawValue :
                self.scheduling?.specificTimes?.repeatObject?.isEachValue = true
                self.scheduling?.specificTimes?.repeatObject?.eachValue = value as String
            case eMonthOnTheCount.rawValue :
                self.scheduling?.specificTimes?.repeatObject?.isEachValue = false
                self.scheduling?.specificTimes?.repeatObject?.onTheValue = value as String
            case eYearEachCount.rawValue :
                self.scheduling?.specificTimes?.repeatObject?.isEachValue = true
                self.scheduling?.specificTimes?.repeatObject?.yearEachValue = String(value)
            case eYearOnTheCount.rawValue :
                self.scheduling?.specificTimes?.repeatObject?.isEachValue = false
                self.scheduling?.specificTimes?.repeatObject?.yearOnTheValue = value as String
            case eDayCount.rawValue :
                self.scheduling?.interval?.repeatFrequencyType = DAYS_TITLE
                self.scheduling?.interval?.daysCount = String(value)
                self.updateAdministrationTimesArrayForSelectedPickerType(pickerType)
                //interval repat type, calculate administration times
            case eHoursCount.rawValue :
                self.scheduling?.interval?.repeatFrequencyType = HOURS_TITLE
                self.scheduling?.interval?.hoursCount = String(value)
                self.updateAdministrationTimesArrayForSelectedPickerType(pickerType)
            case eMinutesCount.rawValue :
                self.scheduling?.interval?.repeatFrequencyType = MINUTES_TITLE
                self.scheduling?.interval?.minutesCount = String(value)
                self.updateAdministrationTimesArrayForSelectedPickerType(eMinutesCount)
            default :
                break
        }
        self.schedulingCompletion(self.scheduling)
        self.detailTableView.reloadData()
    }
    
    func updateAdministrationTimesArrayForSelectedPickerType(pickerType : PickerType) {
        
        //calculate adminstration times in bg
        //dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            if (pickerType == eDayCount) {
                if (self.scheduling?.interval?.startTime != nil) {
                    self.previewArray?.addObject((self.scheduling?.interval?.startTime)!)
                    if let delegate = self.detailDelegate {
                        delegate.updatedIntervalPreviewArray(self.previewArray!)
                    }
                }
            } else if (pickerType == eHoursCount || pickerType == eMinutesCount) {
                var timeGap : Int
                if (pickerType == eHoursCount) {
                    timeGap = Int((self.scheduling?.interval?.hoursCount)!)!
                } else {
                    timeGap = Int((self.scheduling?.interval?.minutesCount)!)!
                }
                let timesArray = DCSchedulingHelper.administrationTimesForIntervalSchedulingWithRepeatFrequencyType(pickerType, timeGap: timeGap, WithStartDateString: (self.scheduling?.interval?.startTime)!, WithendDateString: (self.scheduling?.interval?.endTime)!)
                if let delegate = self.detailDelegate {
                    delegate.updatedIntervalPreviewArray(timesArray)
                }
            }
       // }
    }
    
    func schedulingTypeCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingCell {
        
        let schedulingCell : DCSchedulingCell? = detailTableView.dequeueReusableCellWithIdentifier(SCHEDULING_CELL_ID) as? DCSchedulingCell
        var displayString = EMPTY_STRING
        if (indexPath.section == 1 && self.scheduling?.specificTimes?.repeatObject?.repeatType == WEEKLY) {
            displayString = weekDaysArray.objectAtIndex(indexPath.item) as! String
            if (self.scheduling?.specificTimes?.repeatObject?.weekDays == nil) {
                let currentDayIndex : NSInteger = DCDateUtility.currentWeekDayIndex()
                if (currentDayIndex-1 == indexPath.row) { // There was a mismatch in the week days displayed. have to correct that one
                    self.scheduling?.specificTimes?.repeatObject?.weekDays = NSMutableArray()
                    self.scheduling?.specificTimes?.repeatObject?.weekDays.addObject(displayString)
                    schedulingCell?.accessoryType = UITableViewCellAccessoryType.Checkmark
                } else {
                    schedulingCell?.accessoryType = UITableViewCellAccessoryType.None
                }
            } else {
                let valueExists : Bool = (self.scheduling?.specificTimes?.repeatObject?.weekDays.containsObject(displayString))!
                if (valueExists && weekDaysArray.indexOfObject(displayString) == indexPath.row) {
                    schedulingCell?.accessoryType = UITableViewCellAccessoryType.Checkmark
                } else {
                    schedulingCell?.accessoryType = UITableViewCellAccessoryType.None
                }
            }
        } else {
            displayString = (displayArray.objectAtIndex(indexPath.item) as? String)!
            schedulingCell!.accessoryType = (displayString == previousFilledValue) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        }
        if (indexPath.row == 1) {
            schedulingCell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        schedulingCell!.descriptionLabel.hidden = true
        schedulingCell!.titleLabel?.text = displayString
        return schedulingCell!
    }
    
    func repeatCellAtIndexPath(indexPath : NSIndexPath) -> DCSchedulingCell {
        
        let repeatCell : DCSchedulingCell? = detailTableView.dequeueReusableCellWithIdentifier(SCHEDULING_CELL_ID) as? DCSchedulingCell
        repeatCell!.accessoryType = UITableViewCellAccessoryType.None
        repeatCell!.descriptionLabel.hidden = false
        return repeatCell!
    }
    
    func displayInlinePickerForRowAtIndexPath(indexPath : NSIndexPath) {
        
        detailTableView.beginUpdates()
        var pickerBeforeSelectedIndexPath = false
        var sameCellClicked = false
        if (self.inlinePickerIndexPath != nil) {
            pickerBeforeSelectedIndexPath = self.inlinePickerIndexPath!.row < indexPath.row
            if (tableViewHasInlinePickerForSection(indexPath.section)) {
                sameCellClicked = (self.inlinePickerIndexPath!.row - 1 == indexPath.row);
            }
            let pickerIndexPath : NSIndexPath = self.inlinePickerIndexPath!
            self.inlinePickerIndexPath = nil
            detailTableView.deleteRowsAtIndexPaths([pickerIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        // remove any picker cell if it exists
        if (!sameCellClicked) {
            // hide the date picker and display the new one
            let rowToReveal : NSInteger = (pickerBeforeSelectedIndexPath ? indexPath.row - 1 : indexPath.row);
            let indexPathToReveal : NSIndexPath = NSIndexPath(forItem: rowToReveal, inSection: indexPath.section)
            togglePickerForSelectedIndexPath(indexPathToReveal)
            self.inlinePickerIndexPath = NSIndexPath(forItem: indexPathToReveal.row + 1, inSection: indexPath.section)
        }
        detailTableView.deselectRowAtIndexPath(indexPath, animated: true)
        detailTableView.endUpdates()
    }
    
    func togglePickerForSelectedIndexPath(indexPath : NSIndexPath) {
        
       // detailTableView.beginUpdates()
        let indexPaths = [NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)]
        if (tableViewHasInlinePickerForSection(indexPath.section)) {
            detailTableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            // didn't find a picker below it, so we should insert it
            detailTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func populatedIntervalCell(intervalCell : DCSchedulingCell, WithRepeatFrequencyType type : NSString) -> DCSchedulingCell {
        
        //populated interval cell
        intervalCell.titleLabel.text = type as String
        intervalCell.accessoryType = self.scheduling?.interval?.repeatFrequencyType == type ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        return intervalCell
    }
    
    func intervalRepeatFrequencyCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        var intervalCell : DCSchedulingCell? = detailTableView.dequeueReusableCellWithIdentifier(SCHEDULING_CELL_ID) as? DCSchedulingCell
        if (indexPath.row == 0) {
            intervalCell?.titleLabel.text = DAYS_TITLE
            intervalCell?.accessoryType = self.scheduling?.interval?.repeatFrequencyType == DAYS_TITLE ?
                UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        }
        if (self.inlinePickerIndexPath == nil) {
            switch indexPath.row {
            case 1 :
                intervalCell? = populatedIntervalCell(intervalCell!, WithRepeatFrequencyType: HOURS_TITLE)
            case 2 :
                intervalCell? = populatedIntervalCell(intervalCell!, WithRepeatFrequencyType: MINUTES_TITLE)
            default :
                break
            }
        } else if (self.inlinePickerIndexPath?.row == 1) { // picker for day
            switch indexPath.row {
            case 1:
                let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: eDayCount)
                return pickerCell
            case 2 :
                intervalCell? = populatedIntervalCell(intervalCell!, WithRepeatFrequencyType: HOURS_TITLE)
            case 3 :
                intervalCell? = populatedIntervalCell(intervalCell!, WithRepeatFrequencyType: MINUTES_TITLE)
            default :
                break
            }
        } else if (self.inlinePickerIndexPath?.row == 2) { // picker for hour
            switch indexPath.row {
            case 1 :
                intervalCell? = populatedIntervalCell(intervalCell!, WithRepeatFrequencyType: HOURS_TITLE)
            case 2:
                let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: eHoursCount)
                return pickerCell
            case 3 :
                intervalCell? = populatedIntervalCell(intervalCell!, WithRepeatFrequencyType: MINUTES_TITLE)
            default :
                break
            }
        } else {
            switch indexPath.row {
            case 1 :
                intervalCell? = populatedIntervalCell(intervalCell!, WithRepeatFrequencyType: HOURS_TITLE)
            case 2 :
                intervalCell? = populatedIntervalCell(intervalCell!, WithRepeatFrequencyType: MINUTES_TITLE)
                
            case 3:
                let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: eMinutesCount)
                return pickerCell
            default :
                break
            }
        }
        
        intervalCell?.descriptionLabel.hidden = true
        return intervalCell!
    }
    
    func specificTimesRepeatTypeAndFrequencyCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let repeatCell : DCSchedulingCell = repeatCellAtIndexPath(indexPath)
            repeatCell.titleLabel.text = FREQUENCY
            if let type = self.scheduling?.specificTimes?.repeatObject?.repeatType {
                repeatCell.descriptionLabel.text = type
            } else {
                self.scheduling?.specificTimes?.repeatObject = DCRepeat.init()
                self.scheduling?.specificTimes?.repeatObject?.repeatType = DAILY
                self.scheduling?.specificTimes?.repeatObject?.frequency = "1 day"
                repeatCell.descriptionLabel.text = DAILY
            }
            return repeatCell
        } else if (indexPath.row == 1) {
            if (tableViewHasInlinePickerForSection(indexPath.section) && self.inlinePickerIndexPath?.row == 1) {
                let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: eSchedulingFrequency)
                return pickerCell
            } else {
                let repeatCell : DCSchedulingCell =  repeatCellAtIndexPath(indexPath)
                repeatCell.titleLabel.text = EVERY
                repeatCell.descriptionLabel.text = DCSchedulingHelper.specificTimesDescriptionValueForRepeatFrequency((self.scheduling?.specificTimes?.repeatObject?.frequency)!) as String
                return repeatCell
            }
        } else {
            if (tableViewHasInlinePickerForSection(indexPath.section) && self.inlinePickerIndexPath == indexPath) {
                let pickerType = DCSchedulingHelper.specificTimesPickerTypeForRepeatType((self.scheduling?.specificTimes?.repeatObject?.repeatType)!)
                let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: pickerType)
                return pickerCell
            } else {
                let repeatCell : DCSchedulingCell =  repeatCellAtIndexPath(indexPath)
                repeatCell.titleLabel.text = EVERY
                repeatCell.descriptionLabel.text = self.scheduling?.specificTimes?.repeatObject?.frequency
                return repeatCell
            }
        }
    }
    
    func updateSchedulingDetailsForSelectedIntervalRepeatFrequencyAtIndexPath(indexPath : NSIndexPath) {
        
        // update scheduling details on selecting repeat frequency
        var pickerType : PickerType?
        if (indexPath.row == 0) {
            self.scheduling?.interval?.repeatFrequencyType = DAYS_TITLE
            if (self.scheduling?.interval?.daysCount == nil) {
                self.scheduling?.interval?.daysCount = ONE
            }
            pickerType = eDayCount
        } else if (indexPath.row == 1) {
            self.scheduling?.interval?.repeatFrequencyType = HOURS_TITLE
            if (self.scheduling?.interval?.hoursCount == nil) {
                self.scheduling?.interval?.hoursCount = ONE
            }
            pickerType = eHoursCount
        } else {
            if (self.inlinePickerIndexPath == nil) {
                self.scheduling?.interval?.repeatFrequencyType = MINUTES_TITLE
                if (self.scheduling?.interval?.minutesCount == nil) {
                    self.scheduling?.interval?.minutesCount = ONE
                }
                pickerType = eMinutesCount
            } else {
                if (self.inlinePickerIndexPath?.row < indexPath.row) {
                    if  (indexPath.row == 2) {
                        self.scheduling?.interval?.repeatFrequencyType = HOURS_TITLE
                        if (self.scheduling?.interval?.hoursCount == nil) {
                            self.scheduling?.interval?.hoursCount = ONE
                        }
                        pickerType = eHoursCount
                    } else {
                        self.scheduling?.interval?.repeatFrequencyType = MINUTES_TITLE
                        if (self.scheduling?.interval?.minutesCount == nil) {
                            self.scheduling?.interval?.minutesCount = ONE
                        }
                        pickerType = eMinutesCount
                    }
                } else {
                    self.scheduling?.interval?.repeatFrequencyType = MINUTES_TITLE
                    if (self.scheduling?.interval?.minutesCount == nil) {
                        self.scheduling?.interval?.minutesCount = ONE
                    }
                    pickerType = eMinutesCount
                }
            }
        }
        if (pickerType != nil) {
            self.updateAdministrationTimesArrayForSelectedPickerType(pickerType!)
        }
        self.schedulingCompletion(self.scheduling)
    }
    
    func specificTimesWeeklyOrYearlyDetailCellAtIndexPath(indexPath : NSIndexPath) -> UITableViewCell {
        
        //sepcific times weekly or yearly display in 1st section
        if (self.scheduling?.specificTimes?.repeatObject?.repeatType == WEEKLY) {
            let weekDaysCell : DCSchedulingCell = schedulingTypeCellAtIndexPath(indexPath)
            return weekDaysCell
        } else {
            let repeatCell : DCSchedulingCell =  repeatCellAtIndexPath(indexPath)
            if (indexPath.row == 0) {
                repeatCell.titleLabel.text = EACH
                repeatCell.descriptionLabel.hidden = true
                repeatCell.accessoryType = (self.scheduling?.specificTimes?.repeatObject?.isEachValue == true) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            } else if (indexPath.row == 1) {
                if (tableViewHasInlinePickerForSection(indexPath.section) && self.inlinePickerIndexPath == indexPath) {
                    let pickerType : PickerType = (self.scheduling?.specificTimes?.repeatObject?.repeatType == MONTHLY) ? eMonthEachCount : eYearEachCount
                    let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: pickerType)
                    return pickerCell
                } else {
                    repeatCell.titleLabel.text = ON_THE
                    repeatCell.descriptionLabel.hidden = true
                    repeatCell.accessoryType = (self.scheduling?.specificTimes?.repeatObject?.isEachValue == false) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
                }
            } else {
                if (tableViewHasInlinePickerForSection(indexPath.section) && self.inlinePickerIndexPath == indexPath) {
                    let pickerType : PickerType = (self.scheduling?.specificTimes?.repeatObject?.repeatType == MONTHLY) ? eMonthOnTheCount : eYearOnTheCount
                    let pickerCell : DCSchedulingPickerCell = inlinePickerCellAtIndexPath(indexPath, forPickerType: pickerType)
                    return pickerCell
                } else {
                    repeatCell.titleLabel.text = ON_THE
                    repeatCell.descriptionLabel.hidden = true
                    repeatCell.accessoryType = (self.scheduling?.specificTimes?.repeatObject?.isEachValue == false) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
                }
            }
            return repeatCell
        }
    }
    
    // MARK: TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            var rowCount = 2;
            if (self.detailType! == eDetailIntervalRepeatFrequency) {
                rowCount++
            }
            if (tableViewHasInlinePickerForSection(section)) {
                rowCount++
            }
            return rowCount
        } else {
            var rowCount : NSInteger = 0
            if (self.detailType! == eDetailSpecificTimesRepeatType) {
                if (self.scheduling?.type == SPECIFIC_TIMES) {
                    if (self.scheduling?.specificTimes?.repeatObject?.repeatType == WEEKLY) {
                        rowCount = WEEK_DAYS_COUNT
                    } else if (self.scheduling?.specificTimes?.repeatObject?.repeatType == MONTHLY || self.scheduling?.specificTimes?.repeatObject?.repeatType == YEARLY) {
                        rowCount = 2
                    }
                    if (tableViewHasInlinePickerForSection(section)) {
                        rowCount++
                    }
                } else {
                    //interval type
                    rowCount = 3
                }
            }
             return rowCount
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            if (self.detailType! == eDetailIntervalRepeatFrequency) {
                let repeatFrequencyCell = intervalRepeatFrequencyCellAtIndexPath(indexPath)
                return repeatFrequencyCell
            } else {
                let specificTimesCell = specificTimesRepeatTypeAndFrequencyCellAtIndexPath(indexPath)
                return specificTimesCell
            }
        } else {
            //weekly cell
            if (self.scheduling?.type == SPECIFIC_TIMES) {
                let weekOrYearCell = specificTimesWeeklyOrYearlyDetailCellAtIndexPath(indexPath)
                return weekOrYearCell
            } else {
                let weekDaysCell : DCSchedulingCell = schedulingTypeCellAtIndexPath(indexPath)
                return weekDaysCell
            }
         }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0) {
            if (self.detailType! == eDetailSchedulingType) {
                if (indexPath.row == 0) {
                    previousFilledValue = displayArray.objectAtIndex(indexPath.item) as! String
                    self.frequencyValue(previousFilledValue)
                    tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Fade)
                }
                self.navigationController?.popViewControllerAnimated(true)
            } else if (self.detailType! == eDetailSpecificTimesRepeatType) {
                // display picker here
                displayInlinePickerForRowAtIndexPath(indexPath)
            } else if (self.detailType! == eDetailIntervalRepeatFrequency) {
                updateSchedulingDetailsForSelectedIntervalRepeatFrequencyAtIndexPath(indexPath)
                self.detailTableView.reloadData()
                let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.14 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    // your function here
                    self.displayInlinePickerForRowAtIndexPath(indexPath)
                })
            }
        } else {
            //weekly schedule
            if (self.scheduling?.specificTimes?.repeatObject?.repeatType == WEEKLY) {
                let weekDay = weekDaysArray.objectAtIndex(indexPath.item)
                let index : NSInteger = (self.scheduling?.specificTimes?.repeatObject?.weekDays.indexOfObject(weekDay))!
                let valueExists : Bool = (self.scheduling?.specificTimes?.repeatObject?.weekDays.containsObject(weekDay))!
                if (valueExists == false) {
                    self.scheduling?.specificTimes?.repeatObject?.weekDays.addObject(weekDay)
                } else {
                    //remove the already existing object from array
                    self.scheduling?.specificTimes?.repeatObject?.weekDays.removeObjectAtIndex(index)
                 }
                self.schedulingCompletion(self.scheduling)
                tableView.beginUpdates()
                self.detailTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
                tableView.endUpdates()
            } else {
                
                if (indexPath.row == 0) {
                    self.scheduling?.specificTimes?.repeatObject?.isEachValue = true
                } else if (indexPath.row == 1 || indexPath.row == 2) {
                    self.scheduling?.specificTimes?.repeatObject?.isEachValue = false
                }
                self.detailTableView.beginUpdates()
                self.detailTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
                self.detailTableView.endUpdates()
                let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.14 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    // your function here
                    self.displayInlinePickerForRowAtIndexPath(indexPath)
                })
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 1) {
            return (headerHeight > HEADER_VIEW_MIN_HEIGHT) ? headerHeight : HEADER_VIEW_MIN_HEIGHT
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (section == 1) {
            let headerView = NSBundle.mainBundle().loadNibNamed(SCHEDULING_HEADER_VIEW_NIB, owner: self, options: nil)[0] as? DCSchedulingHeaderView
            if (self.detailType! == eDetailIntervalRepeatFrequency) {
                if let intervalObject = self.scheduling?.interval {
                    headerView?.populateMessageLabelForIntervalValue(intervalObject)
                    self.scheduling?.interval?.intervalDescription = headerView?.messageLabel.text;
                }
            } else {
                if let repeatObject = self.scheduling?.specificTimes?.repeatObject {
                    if administratingTimes == nil {
                        administratingTimes = []
                    }
                    headerView?.populateMessageLabelWithSpecificTimesRepeatValue(repeatObject, administratingTimes: administratingTimes!)
                    self.scheduling?.specificTimes?.specificTimesDescription = headerView?.messageLabel.text;
                }
            }
            self.schedulingCompletion(self.scheduling)
            headerHeight = DCUtility.textViewSizeWithText(headerView?.messageLabel.text, maxWidth: HEADER_VIEW_LABEL_MAX_WIDTH, font: UIFont.systemFontOfSize(13.0)).height + 10
            return headerView!
        }

        return nil
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return (indexPathHasPicker(indexPath)) ? PICKER_CELL_HEIGHT : TABLE_VIEW_ROW_HEIGHT
    }
    
}
