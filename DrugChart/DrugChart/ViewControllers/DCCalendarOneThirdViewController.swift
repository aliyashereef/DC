//
//  CalendarOneThirdViewController.swift
//  DrugChart
//
//  Created by aliya on 17/11/15.
//
//

import Foundation

class DCCalendarOneThirdViewController: DCBaseViewController,UITableViewDataSource, UITableViewDelegate, DCMedicationAdministrationStatusProtocol , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var calendarStripCollectionView: UICollectionView!
    @IBOutlet var medicationTableView: UITableView?
    var displayMedicationListArray : NSMutableArray = []
    let existingStatusViews : NSMutableArray = []
    var centerDate : NSDate?
    var currentWeekDatesArray : NSMutableArray = []
    let collectionViewReuseIdentifier = "CalendarStripCellIdentifier"
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

    // MARK: - View Management Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        medicationTableView!.tableFooterView = UIView(frame: CGRectZero)
        medicationTableView!.delaysContentTouches = false
        if currentWeekDatesArray.count > 0 {
            let centerDisplayDate = self.currentWeekDatesArray.count == 15 ? 7 : 4
            centerDate = self.currentWeekDatesArray.objectAtIndex(centerDisplayDate) as? NSDate
        } else {
            generateCurrentWeekDatesArray()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        if let _ = centerDate {
            
        } else {
            centerDate = NSDate.init()
        }
        calendarStripCollectionView.reloadData()
        self.adjustContentOffsetToShowCenterDayInCollectionView()
        self.view.layoutIfNeeded()
    }
    
    //MARK: - Collection View Delegate Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return currentWeekDatesArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionViewReuseIdentifier, forIndexPath: indexPath) as! DCOneThirdCalendarStripCollectionCell
        
        cell.indicatorLabel.removeFromSuperview()
        let date = self.currentWeekDatesArray.objectAtIndex(indexPath.row) as! NSDate
        cell.displayDate = date
        cell.dateLabel.textColor = UIColor.blackColor()
        cell.dateLabel.text = DCDateUtility.dateStringFromDate(date, inFormat:DAY_DATE_FORMAT)
        cell.weekdayLabel.text = DCDateUtility.dateStringFromDate(date, inFormat:WEEK_DAY_FORMAT).uppercaseString
        let today : NSDate = NSDate()
        let order = NSCalendar.currentCalendar().compareDate(date , toDate:today,
            toUnitGranularity: .Day)
        if (order == NSComparisonResult.OrderedSame){
            cell.addTodayIndicationForCellWithoutSelection()
        }
        if date.compare(centerDate!) == NSComparisonResult.OrderedSame {
            cell.showSelection()
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        return 1
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = calendarStripCollectionView.cellForItemAtIndexPath(indexPath) as! DCOneThirdCalendarStripCollectionCell
        centerDate = cell.displayDate!
        medicationTableView?.reloadData()
        self.calendarStripCollectionView.reloadData()
        let parentView : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        parentView.loadCurrentDayDisplayForOneThirdWithDate(centerDate)
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
    }
    
    //MARK: Collection view flow layout methods
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let windowWidth : CGFloat = DCUtility.mainWindowSize().width
        let cellSize = CGSizeMake((windowWidth/5) - 1, 54)
        return cellSize
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        let edgeInsets : UIEdgeInsets = UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5)
        return edgeInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
   
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.5
    }
    
    //MARK: - Table View Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return displayMedicationListArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell = medicationTableView!.dequeueReusableCellWithIdentifier("MedicationCell" as String) as? DCOneThirdCalendarScreenMedicationCell
        if cell == nil {
            cell = DCOneThirdCalendarScreenMedicationCell(style: UITableViewCellStyle.Value1, reuseIdentifier:
                "MedicationCell")
        }
        let medicationScheduleDetails: DCMedicationScheduleDetails = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
        cell!.isMedicationActive = medicationScheduleDetails.isActive

        let rowDisplayMedicationSlotsArray = self.prepareMedicationSlotsForDisplayInCellFromScheduleDetailsForDate(medicationScheduleDetails,date:centerDate!)
        
        var index : NSInteger = 0
        for ( index = 0; index < rowDisplayMedicationSlotsArray.count; index++) {
            
            self.configureMedicationCell(cell!,withMedicationSlotsArray: rowDisplayMedicationSlotsArray,atIndexPath: indexPath,andSlotIndex: index)
        }
        
        self.fillInMedicationDetailsInTableCell(cell!, atIndexPath: indexPath)
        if (cell!.inEditMode == true) {
            UIView.animateWithDuration(0.05, animations: { () -> Void in
                cell!.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET;
            })
        }
        cell!.layoutMargins = UIEdgeInsetsZero
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let tableCell: DCOneThirdCalendarScreenMedicationCell = tableView.cellForRowAtIndexPath(indexPath) as! DCOneThirdCalendarScreenMedicationCell
        let subViewArray = tableCell.contentView.subviews[1].subviews[2].subviews
        
        for subVeiw in subViewArray {
            if subVeiw .isKindOfClass(DCMedicationAdministrationStatusView){
                (subVeiw as! DCMedicationAdministrationStatusView).administerMedicationWithMedicationSlot()
                break
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let firstDate : NSDate = currentWeekDatesArray.objectAtIndex(0) as! NSDate
        let lastDate : NSDate = currentWeekDatesArray.lastObject as! NSDate
        let visibleCells : NSArray = calendarStripCollectionView.visibleCells()
        if visibleCells.count > 0 {
            let cell : DCOneThirdCalendarStripCollectionCell = visibleCells.lastObject as! DCOneThirdCalendarStripCollectionCell
            print(cell.displayDate)
            for obj : AnyObject in visibleCells  {
                if let cell = obj as? DCOneThirdCalendarStripCollectionCell{
                    if cell.displayDate?.compare(lastDate) == NSComparisonResult.OrderedSame {
                        self.modifyStartDateAndWeekDatesArray(true, adderValue: 5)
                        self.calendarStripCollectionView.reloadData()
                    } else if cell.displayDate?.compare(firstDate) == NSComparisonResult.OrderedSame {
                        self.modifyStartDateAndWeekDatesArray(false, adderValue: 5)
                        self.calendarStripCollectionView.reloadData()
                    }
                }
            }

        }
    }
    // MARK: - Data display methods in table view
    
    func fillInMedicationDetailsInTableCell(cell: DCOneThirdCalendarScreenMedicationCell,
        atIndexPath indexPath:NSIndexPath) {
            let medicationCell = cell
            if (displayMedicationListArray.count >= indexPath.item) {
                
                let medicationSchedules = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
                medicationCell.medicineName.text = medicationSchedules.name;
                let routeString : String = medicationSchedules.route.stringByReplacingOccurrencesOfString(" ", withString: EMPTY_STRING)
                let attributedRouteString : NSMutableAttributedString = NSMutableAttributedString(string: routeString, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(16.0)])
                let attributedInstructionsString : NSMutableAttributedString
                let instructionString : String
                if ( medicationSchedules.instruction != EMPTY_STRING &&  medicationSchedules.instruction  != nil) {
                    instructionString = String(format: " (%@)", ( medicationSchedules.instruction )!)
                } else {
                    instructionString = EMPTY_STRING
                }
                attributedInstructionsString  = NSMutableAttributedString(string: instructionString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12.0)])
                attributedRouteString.appendAttributedString(attributedInstructionsString)
                medicationCell.route.attributedText = attributedRouteString;
            }
    }
        
    func reloadMedicationListWithDisplayArray (displayArray: NSMutableArray) {
        
        displayMedicationListArray =  displayArray as NSMutableArray
        adjustContentOffsetToShowCenterDayInCollectionView()
        medicationTableView?.reloadData()
    }
    
    func prepareMedicationSlotsForDisplayInCellFromScheduleDetailsForDate (medicationScheduleDetails: DCMedicationScheduleDetails, date : NSDate ) -> NSMutableArray {
            
        var count = 0
        let medicationSlotsArray: NSMutableArray = []
        let slotsDictionary = NSMutableDictionary()
        if count < 1{
            if(self.currentWeekDatesArray.count > 0) {
                
                let formattedDateString = DCDateUtility.dateStringFromDate(date, inFormat: SHORT_DATE_FORMAT)
                let predicateString = NSString(format: "medDate contains[cd] '%@'",formattedDateString)
                let predicate = NSPredicate(format: predicateString as String)
                //TODO: check if this is right practise. If not change this checks accordingly.
                if let scheduleArray = medicationScheduleDetails.timeChart {
                   if let slotDetailsArray : NSArray = scheduleArray.filteredArrayUsingPredicate(predicate) {
                       if slotDetailsArray.count != 0 {
                            if let medicationSlotArray = slotDetailsArray.objectAtIndex(0).valueForKey(MED_DETAILS) {
                                    slotsDictionary.setObject(medicationSlotArray, forKey: PRESCRIBER_TIME_SLOTS)
                            }
                    }
                    }
                }
                slotsDictionary.setObject(NSNumber (integer: count + 1), forKey: PRESCRIBER_SLOT_VIEW_TAG)
                medicationSlotsArray.addObject(slotsDictionary)
                count++
            }
        }
    return medicationSlotsArray
    }
    
    func addAdministerStatusViewsToTableCell(medicationCell:DCOneThirdCalendarScreenMedicationCell , toContainerSubview containerView: UIView,  forMedicationSlotDictionary slotDictionary:NSDictionary,
        atIndexPath indexPath:NSIndexPath,
        atSlotIndex tag:NSInteger) -> DCMedicationAdministrationStatusView {
            
            for subView : UIView in containerView.subviews {
                if (subView.tag == tag) {
                    existingStatusViews.addObject(subView)
                }
            }
            let viewFrame = CGRectMake(0, 0, 115, 35.0)
            let statusView : DCMedicationAdministrationStatusView = DCMedicationAdministrationStatusView(frame: viewFrame)
            let medicationSchedules = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
            statusView.tag = tag
            statusView.delegate = self
            statusView.currentIndexPath = indexPath
            statusView.medicationCategory = medicationSchedules.medicineCategory
            statusView.backgroundColor = UIColor.whiteColor()
            statusView.isOneThirdScreen = true
            statusView.updateAdministrationStatusViewWithMedicationSlotDictionary(slotDictionary)
            return statusView
    }
    
    func configureMedicationCell(medicationCell:DCOneThirdCalendarScreenMedicationCell, withMedicationSlotsArray
        rowDisplayMedicationSlotsArray:NSMutableArray,
        atIndexPath indexPath:NSIndexPath,
        andSlotIndex index:NSInteger) {
            if (index == 0) {
                let statusView : DCMedicationAdministrationStatusView = self.addAdministerStatusViewsToTableCell(medicationCell, toContainerSubview: medicationCell.adminstrationStatusView, forMedicationSlotDictionary: rowDisplayMedicationSlotsArray.objectAtIndex(0) as! NSDictionary,
                    atIndexPath: indexPath,
                    atSlotIndex:0)
                statusView.isOneThirdScreen = true
                let weekdate = currentWeekDatesArray.objectAtIndex(index) as? NSDate
                medicationCell.adminstrationStatusView.addSubview(statusView)
                statusView.configureStatusViewForWeekDate(weekdate!)
            }
            for subView in existingStatusViews {
                subView.removeFromSuperview()
            }
    }
    
    func adjustContentOffsetToShowCenterDayInCollectionView() {
        
        let index = currentWeekDatesArray.indexOfObject(centerDate!)
        let indexPath : NSIndexPath = NSIndexPath(forRow:index , inSection: 0)
        calendarStripCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        self.view .layoutIfNeeded()
    }
    
    func modifyStartDateAndWeekDatesArray(isNextWeek : Bool,adderValue : NSInteger) {
        
        let daysCount : NSInteger = 15
        var firstDate : NSDate = currentWeekDatesArray.objectAtIndex(0) as! NSDate
        if isNextWeek {
            firstDate = DCDateUtility.initialDateForCalendarDisplay(firstDate, withAdderValue: adderValue)
        } else {
            firstDate = DCDateUtility.initialDateForCalendarDisplay(firstDate, withAdderValue: -adderValue)
        }
        currentWeekDatesArray = DCDateUtility.nextAndPreviousDays(daysCount, withReferenceToDate: firstDate)
    }
    
    func todayButtonClicked() {
        let today : NSDate = NSDate()
        var isCurrentWeekArray : Bool = false
        for date in self.currentWeekDatesArray {
            let order = NSCalendar.currentCalendar().compareDate(date as! NSDate, toDate:today,
                toUnitGranularity: .Day)
            if (order == NSComparisonResult.OrderedSame){
                isCurrentWeekArray = true
                let index = currentWeekDatesArray.indexOfObject(date)
                let indexPath : NSIndexPath = NSIndexPath(forRow:index , inSection: 0)
                centerDate = date as? NSDate
                calendarStripCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
                calendarStripCollectionView.reloadData()
                medicationTableView?.reloadData()
                break
            }
        }
        if !isCurrentWeekArray {
            generateCurrentWeekDatesArray()
            let centerDisplayDate = self.currentWeekDatesArray.count == 15 ? 7 : 4
            let indexPath : NSIndexPath = NSIndexPath(forRow:centerDisplayDate, inSection: 0)
            calendarStripCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
            calendarStripCollectionView.reloadData()
            medicationTableView?.reloadData()
        }
    }
    
    func generateCurrentWeekDatesArray () {
        
        let daysCount : NSInteger = 15
        var  firstDate = NSDate.init()
        firstDate = DCDateUtility.initialDateForCalendarDisplay(firstDate, withAdderValue: -7)
        currentWeekDatesArray = DCDateUtility.nextAndPreviousDays(daysCount, withReferenceToDate:firstDate)
        let centerDisplayDate = self.currentWeekDatesArray.count == 15 ? 7 : 4
        centerDate = self.currentWeekDatesArray.objectAtIndex(centerDisplayDate) as? NSDate
    }
    
    //MARK - DCMedicationAdministrationStatusProtocol delegate implementation
    
    func administerMedicationWithMedicationSlots (medicationSLotDictionary: NSDictionary, atIndexPath indexPath: NSIndexPath ,withWeekDate date : NSDate) {
        let parentView : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        parentView.displayAdministrationViewForMedicationSlot(medicationSLotDictionary as [NSObject : AnyObject], atIndexPath: indexPath, withWeekDate: date)
    }
}
