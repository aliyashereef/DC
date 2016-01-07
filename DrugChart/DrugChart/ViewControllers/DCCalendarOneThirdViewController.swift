//
//  CalendarOneThirdViewController.swift
//  DrugChart
//
//  Created by aliya on 17/11/15.
//
//

import Foundation
import CocoaLumberjack

enum Direction  {
    case ScrollDirectionNone
    case ScrollDirectionRight
    case ScrollDirectionLeft
}

class DCCalendarOneThirdViewController: DCBaseViewController,UITableViewDataSource, UITableViewDelegate, DCMedicationAdministrationStatusProtocol , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EditDeleteActionDelegate {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var calendarStripCollectionView: UICollectionView!
    @IBOutlet var medicationTableView: UITableView?
    var displayMedicationListArray : NSMutableArray = []
    let existingStatusViews : NSMutableArray = []
    var centerDate : NSDate = NSDate.init()
    var scrollIndex : NSInteger = 2
    var currentWeekDatesArray : NSMutableArray = []
    var scrolledProgramatically : Bool = false
    let collectionViewReuseIdentifier = "CalendarStripCellIdentifier"
    var scrollDirection : Direction = .ScrollDirectionNone
    var scrollingLocked : Bool = false
    var selectedIndexPath : NSIndexPath!
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
        generateCurrentWeekDatesArray()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        setParentViewWithCurrentWeekDateArray()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            setParentViewWithCurrentWeekDateArray()
        }
        calendarStripCollectionView.reloadData()
        self.adjustContentOffsetToShowCenterDayInCollectionView()
        medicationTableView?.reloadData()
        self.view.layoutIfNeeded()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        let orientation = UIDevice.currentDevice().orientation
        if  orientation == UIDeviceOrientation.LandscapeLeft ||  orientation == UIDeviceOrientation.LandscapeRight {
            scrollingLocked = true
        }
    }
    
    //MARK: - Collection View Delegate Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return currentWeekDatesArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionViewReuseIdentifier, forIndexPath: indexPath) as! DCOneThirdCalendarStripCollectionCell
        
        let date = self.currentWeekDatesArray.objectAtIndex(indexPath.row) as! NSDate
        cell.indicatorLabel.removeFromSuperview()
        cell.displayDate = date
        cell.dateLabel.textColor = UIColor.blackColor()
        cell.dateLabel.text = DCDateUtility.dateStringFromDate(date, inFormat:DAY_DATE_FORMAT)
        cell.dateLabel.backgroundColor = UIColor.clearColor()
        cell.weekdayLabel.text = DCDateUtility.dateStringFromDate(date, inFormat:WEEK_DAY_FORMAT).uppercaseString
        displayDateFromScrollIndexForIndexPath(cell, indexPath: indexPath)
        let today : NSDate = NSDate()
        let order = NSCalendar.currentCalendar().compareDate(date , toDate:today,
            toUnitGranularity: .Day)
        if order == NSComparisonResult.OrderedSame {
            cell.addTodayIndicationForCellWithoutSelection()
        }
        if date.compare(centerDate) == NSComparisonResult.OrderedSame {
            cell.showCurrentCalendarSelection()
        }
        self.displayDateInParentView()
        cell.layoutIfNeeded()
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        return 1
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = calendarStripCollectionView.cellForItemAtIndexPath(indexPath) as! DCOneThirdCalendarStripCollectionCell
        centerDate = cell.displayDate!
        scrollIndex = self.scrollIndexFromIndexPath(indexPath)
        medicationTableView?.reloadData()
        self.calendarStripCollectionView.reloadData()
        self.displayDateInParentView()
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
        cell!.indexPath = indexPath
        cell!.editAndDeleteDelegate = self
        cell!.isMedicationActive = medicationScheduleDetails.isActive
        let rowDisplayMedicationSlotsArray = self.prepareMedicationSlotsForDisplayInCellFromScheduleDetailsForDate(medicationScheduleDetails,date:centerDate)
        
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
    
    //MARK: Scroll View methods
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let scrollVelocity : CGPoint = calendarStripCollectionView.panGestureRecognizer.velocityInView(calendarStripCollectionView.superview)
        if scrollVelocity.x > 0.0 {
            scrollDirection = .ScrollDirectionLeft
        } else if scrollVelocity.x < 0.0 {
            scrollDirection = .ScrollDirectionRight
        }
        if scrollingLocked {
            return
        }
        if (scrolledProgramatically) {
            scrolledProgramatically = false
        } else {
            if scrollView == calendarStripCollectionView {
                let firstDate : NSDate = currentWeekDatesArray.objectAtIndex(0) as! NSDate
                let lastDate : NSDate = currentWeekDatesArray.lastObject as! NSDate
                let visibleCells : NSArray = calendarStripCollectionView.visibleCells()
                if visibleCells.count > 0 {
                    
                    for obj : AnyObject in visibleCells  {
                        
                        if let cell = obj as? DCOneThirdCalendarStripCollectionCell{
                            
                            if cell.displayDate?.compare(firstDate) == NSComparisonResult.OrderedSame  && scrollDirection == .ScrollDirectionLeft {
                                self.modifyStartDateAndWeekDatesArray(false, adderValue:5)
                                self.fetchAdministrationDetailsAndScrollToCenterDatePosition()
                            }
                            else if cell.displayDate?.compare(lastDate) == NSComparisonResult.OrderedSame && scrollDirection == .ScrollDirectionRight  {
                                self.modifyStartDateAndWeekDatesArray(true, adderValue:5)
                                self.fetchAdministrationDetailsAndScrollToCenterDatePosition()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollingLocked {
            scrollingLocked = false
        }
    }
    
    //MARK: Private functions
    
    func fetchAdministrationDetailsAndScrollToCenterDatePosition () {
        calendarStripCollectionView.reloadData()
        self.fetchPatientListAndReloadMedicationList()
        let indexPath : NSIndexPath = NSIndexPath.init(forItem: 5, inSection: 0)
        calendarStripCollectionView .scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
        scrolledProgramatically = true
    }
    
    
    func assignCenterDisplayDateWithCellIndexAndReloadTableView ( date:NSDate ) {
        centerDate = date
        medicationTableView?.reloadData()
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
        medicationTableView?.reloadData()
    }
    
    func fetchPatientListAndReloadMedicationList () {
        
        let parentView : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        parentView.cancelPreviousMedicationListFetchRequest()
        parentView.fetchMedicationListForPatientWithCompletionHandler { (success :Bool) -> Void in
             if success {
                self.medicationTableView?.reloadData()
            }
        }
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
                let weekdate = centerDate
                medicationCell.adminstrationStatusView.addSubview(statusView)
                statusView.configureStatusViewForWeekDate(weekdate)
            }
            for subView in existingStatusViews {
                subView.removeFromSuperview()
            }
    }
    
    func adjustContentOffsetToShowCenterDayInCollectionView() {
        
        let indexPath : NSIndexPath = NSIndexPath(forRow:7 , inSection: 0)
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
        setParentViewWithCurrentWeekDateArray()
    }
       
    func todayButtonClicked() {

        let today : NSDate = NSDate()
        let order = NSCalendar.currentCalendar().compareDate(centerDate , toDate:today,
            toUnitGranularity: .Day)
        if order != NSComparisonResult.OrderedSame {
            generateCurrentWeekDatesArray()
            self.setParentViewWithCurrentWeekDateArray()
            self.fetchPatientListAndReloadMedicationList()
            scrollIndex = 2 // The scroll index is set to sustain the selection of the cell at that particular index even when the user scrolls the cells to the next page of collection view.
            let centerDisplayDate = self.currentWeekDatesArray.count == 15 ? 7 : 4
            let indexPath : NSIndexPath = NSIndexPath(forRow:centerDisplayDate, inSection: 0)
            calendarStripCollectionView.reloadData()
            calendarStripCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
            medicationTableView?.reloadData()
        }
    }
    
    func generateCurrentWeekDatesArray () {
        
        let daysCount : NSInteger = 15
        var  firstDate = NSDate.init()
        firstDate = DCDateUtility.initialDateForCalendarDisplay(firstDate, withAdderValue: -7)
        currentWeekDatesArray = DCDateUtility.nextAndPreviousDays(daysCount, withReferenceToDate:firstDate)
        let centerDisplayDate = self.currentWeekDatesArray.count == 15 ? 7 : 4
        centerDate = self.currentWeekDatesArray.objectAtIndex(centerDisplayDate) as! NSDate
    }
    
    func setParentViewWithCurrentWeekDateArray() {
        
        let parentView : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        parentView.centerDisplayDate = centerDate
        parentView.currentWeeksDateArrayFromCenterDate(centerDate)
    }
    
    func displayDateInParentView() {
        
        let parentView : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        parentView.loadCurrentDayDisplayForOneThirdWithDate(centerDate)
    }
    
    //MARK: - Scroll index for maintaining selection helper methods
    
    func displayDateFromScrollIndexForIndexPath ( cell:DCOneThirdCalendarStripCollectionCell , indexPath : NSIndexPath){
        if scrollIndex == 0 {
            if [0,5,10].contains(indexPath.row) {
                assignCenterDisplayDateWithCellIndexAndReloadTableView(cell.displayDate!)
            }
        } else if scrollIndex == 1 {
            if [1,6,11].contains(indexPath.row) {
                assignCenterDisplayDateWithCellIndexAndReloadTableView(cell.displayDate!)
            }
        } else if scrollIndex == 2 {
            if [2,7,12].contains(indexPath.row) {
                assignCenterDisplayDateWithCellIndexAndReloadTableView(cell.displayDate!)
            }
        } else if scrollIndex == 3 {
            if [3,8,13].contains(indexPath.row) {
                assignCenterDisplayDateWithCellIndexAndReloadTableView(cell.displayDate!)
            }
        }  else if scrollIndex == 4 {
            if [4,9,14].contains(indexPath.row) {
                assignCenterDisplayDateWithCellIndexAndReloadTableView(cell.displayDate!)
            }
        }
    }
    
    func scrollIndexFromIndexPath (indexPath : NSIndexPath) -> NSInteger {
 
        switch (indexPath.section, indexPath.row) {
        case (0,0), (0,5), (0,10):
            scrollIndex = 0
            break
        case (0,1), (0,6), (0,11):
            scrollIndex = 1
            break
        case (0,2), (0,7), (0,12):
            scrollIndex = 2
            break
        case (0,3), (0,8), (0,13):
            scrollIndex = 3
            break
        case (0,4), (0,9), (0,14):
            scrollIndex = 4
            break
        default:
            break
        }
        return scrollIndex
    }
    
    func swipeBackMedicationCellsInTableView() {
        
        for (index,_) in displayMedicationListArray.enumerate(){
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if indexPath == selectedIndexPath {
                continue
            }
            let medicationCell = medicationTableView?.cellForRowAtIndexPath(indexPath)
                as? DCOneThirdCalendarScreenMedicationCell
            medicationCell?.swipeMedicationDetailViewToRight()
        }
    }

    
    //MARK - DCMedicationAdministrationStatusProtocol delegate implementation
    
    func administerMedicationWithMedicationSlots (medicationSLotDictionary: NSDictionary, atIndexPath indexPath: NSIndexPath ,withWeekDate date : NSDate) {
        let parentView : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        parentView.displayAdministrationViewForMedicationSlot(medicationSLotDictionary as [NSObject : AnyObject], atIndexPath: indexPath, withWeekDate: date)
    }
    //MARK - EditDeleteActionDelegate methods
    
    func stopMedicationForSelectedIndexPath(indexPath: NSIndexPath) {
        deleteMedicationAtIndexPath(indexPath)
    }
    
    func setIndexPathSelected(indexPath : NSIndexPath) {
        selectedIndexPath = indexPath
        swipeBackMedicationCellsInTableView()
    }
    
    func editMedicationForSelectedIndexPath(indexPath: NSIndexPath) {
        let medicationScheduleDetails: DCMedicationScheduleDetails = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
        let addMedicationViewController : DCAddMedicationInitialViewController? = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_MEDICATION_POPOVER_SB_ID) as? DCAddMedicationInitialViewController
        let parentView : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        addMedicationViewController?.patientId = parentView.patient.patientId as String
        
        //TODO: Remove shedule details when scheduling is available from api
        if (medicationScheduleDetails.scheduling == nil) {
            medicationScheduleDetails.scheduling = DCScheduling.init();
            medicationScheduleDetails.scheduling.type = SPECIFIC_TIMES;
            medicationScheduleDetails.scheduling.specificTimes = DCSpecificTimes.init()
            medicationScheduleDetails.scheduling.specificTimes.repeatObject = DCRepeat.init()
            medicationScheduleDetails.scheduling.specificTimes.repeatObject.repeatType = DAILY
            medicationScheduleDetails.scheduling.specificTimes.repeatObject.frequency = "1 day"
        }
        addMedicationViewController?.selectedMedication = medicationScheduleDetails
        addMedicationViewController?.isEditMedication = true
        addMedicationViewController?.medicationEditIndexPath = indexPath
        let navigationController : UINavigationController? = UINavigationController(rootViewController: addMedicationViewController!)
        navigationController?.modalPresentationStyle = UIModalPresentationStyle.Popover
        self.presentViewController(navigationController!, animated: true, completion: nil)
    }
    
    func deleteMedicationAtIndexPath(indexPath : NSIndexPath) {
        
        let medicationScheduleDetails: DCMedicationScheduleDetails = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
        let parentView : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        let webService : DCStopMedicationWebService = DCStopMedicationWebService.init()
        webService.stopMedicationForPatientWithId(parentView.patient.patientId as String, drugWithScheduleId: medicationScheduleDetails.scheduleId) { (array, error) -> Void in
            if error == nil {
                self.medicationTableView!.beginUpdates()
                if let medicationArray = self.displayMedicationListArray.mutableCopy() as? NSMutableArray {
                    medicationArray.removeObjectAtIndex(indexPath.row)
                    self.displayMedicationListArray = medicationArray
                }
                self.medicationTableView!.deleteRowsAtIndexPaths([indexPath as NSIndexPath], withRowAnimation: .Fade)
                self.medicationTableView!.endUpdates()
                self.medicationTableView?.reloadData()

            } else {
                // TO DO: handle the case for already deleted medication.
            }
        }
    }
}
