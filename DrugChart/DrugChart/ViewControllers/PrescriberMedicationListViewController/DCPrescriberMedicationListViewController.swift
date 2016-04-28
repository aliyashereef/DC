//
//  DCPrescriberMedicationListViewController.swift
//  DrugChart
//
//  Created by Muhammed Shaheer on 06/10/15.
//
//

import UIKit
import CocoaLumberjack

let CELL_IDENTIFIER = "prescriberIdentifier"

@objc protocol PrescriberListDelegate {
    
    func prescriberTableViewPannedWithTranslationParameters(xPoint : CGFloat, xVelocity : CGFloat, panEnded : Bool)
    func todayActionForCalendarTop ()
    func refreshMedicationList()
}

@objc class DCPrescriberMedicationListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, DCMedicationAdministrationStatusProtocol, EditAndDeleteActionDelegate, DCAddMedicationViewControllerDelegate {

    enum PanDirection {
        case panLeft
        case atCenter
        case panRight
    }

    @IBOutlet var medicationTableView: UITableView?
    var displayMedicationListArray : NSMutableArray = []
    var currentWeekDatesArray : NSMutableArray = []
    var currentWeekDatesStrings:NSMutableArray = []
    var delegate : PrescriberListDelegate?
    var patientId : NSString = EMPTY_STRING
    var panGestureDirection : PanDirection = PanDirection.atCenter
    let existingStatusViews : NSMutableArray = []
    var isEditMode : Bool = false
    var webRequestCancelled = false
    var calendarCellIsMoving = true
    var selectedIndexPath : NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
    var medicationTimeChartData: NSMutableDictionary = NSMutableDictionary()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    // MARK: - View Management Methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        medicationTableView!.tableFooterView = UIView(frame: CGRectZero)
        medicationTableView!.delaysContentTouches = false;
        addPanGestureToPrescriberTableView()
        medicationTableView!.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        let parentViewController : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        parentViewController.reloadCalendarTopPortion()
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Pull to refresh methods

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DCPrescriberMedicationListViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        let parentViewController : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        refreshControl.endRefreshing()
        parentViewController.showActivityIndicationOnViewRefresh(true)
        parentViewController.fetchMedicationListForPatientWithCompletionHandler { (Bool) -> Void in
            parentViewController.showActivityIndicationOnViewRefresh(false)
        }
    }

    // MARK: - UITableView DataSource Methods

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return displayMedicationListArray.count
    }
    
    func tableView(_tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            var medicationCell = _tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as? PrescriberMedicationTableViewCell
            if medicationCell == nil {
                medicationCell = PrescriberMedicationTableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: CELL_IDENTIFIER)
            }
            self.resetStatusViewsIfNeededInTableViewCell(medicationCell!)
            let medicationScheduleDetails: DCMedicationScheduleDetails = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
            //medication administration slots have to be made constant width , medication details flexible width
            let parentViewController : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
            medicationCell?.medicationDetailHolderViewWidthConstraint.constant = DCUtility.mainWindowSize().width - parentViewController.calendarViewWidth
            medicationCell?.calendarWidth = parentViewController.calendarViewWidth
            medicationCell?.editAndDeleteDelegate = self
            medicationCell?.indexPath = indexPath
            medicationCell?.isMedicationActive = medicationScheduleDetails.isActive
            self.fillInMedicationDetailsInTableCell(medicationCell!, atIndexPath: indexPath)
            if (medicationCell?.inEditMode == true) {
                UIView.animateWithDuration(0.05, animations: { () -> Void in
                    medicationCell!.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET;
                })
            }
            
            let rowDisplayMedicationSlotsArray = self.prepareMedicationSlotsForDisplayInCellFromScheduleDetails(medicationScheduleDetails)
            var index = 0
            let noOfSlots = rowDisplayMedicationSlotsArray.count
            for _ in 0..<noOfSlots {
                self.configureMedicationCell(medicationCell!,
                    withMedicationSlotsArray: rowDisplayMedicationSlotsArray,
                    atIndexPath: indexPath,
                    andSlotIndex: index)
                index += 1
            }
            return medicationCell!
    }
    
    // MARK: - Public methods
    func reloadMedicationListWithDisplayArray (displayArray: NSMutableArray) {

        var addedNewMedication : Bool!
        if (displayMedicationListArray.count != 0 && displayMedicationListArray.count < displayArray.count) {
            addedNewMedication = true
        }
        else {
            addedNewMedication = false
        }
        
        displayMedicationListArray = NSMutableArray.init(array: displayArray)
        // Store current week dates as string values
        // This eliminates the need to create date string values for each status view
        currentWeekDatesStrings = []
        for weekDate in currentWeekDatesArray {
            let date = weekDate as! NSDate
            let formattedDateString = DCDateUtility.dateStringFromDate(date, inFormat: SHORT_DATE_FORMAT)
            currentWeekDatesStrings.addObject(formattedDateString)
        }
        // Flatten the timechart data for each DCMedicationScheduleDetails instance
        self.flattenMedicationTimeChartData()
        medicationTableView?.reloadData()
        medicationTableView?.layoutIfNeeded()
        self.scrollToLatestMedication(shouldScroll: addedNewMedication)
        
    }
    
    func animatePrescriberCellToOriginalStateAtIndexPath(indexPath : NSIndexPath) {
        
        let prescriberCell = medicationTableView?.cellForRowAtIndexPath(indexPath) as? PrescriberMedicationTableViewCell
        prescriberCell!.swipeMedicationDetailViewToRight()
    }

    
    func todayButtonClicked () {
        
        let index = (appDelegate.windowState == DCWindowState.fullWindow) ? 7 : 4
        let weekDate = currentWeekDatesArray.objectAtIndex(index) // extracting the middle date - todays date
        let centerDate = DCDateUtility.shortDateFromDate(weekDate as! NSDate)
        let todayDate = DCDateUtility.shortDateFromDate(NSDate()) as NSDate
        if centerDate != todayDate {
            self.hideAdministrationDetailsInCellsOnQuickSwipe()
            if (appDelegate.windowState == DCWindowState.fullWindow ||
                appDelegate.windowState == DCWindowState.twoThirdWindow) {
                    let calendar : NSCalendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)!
                    let todaysDate : NSDate = calendar.startOfDayForDate(NSDate())
                    let order = NSCalendar.currentCalendar().compareDate(weekDate as! NSDate, toDate:todaysDate,
                        toUnitGranularity: .Day)
                    if order == NSComparisonResult.OrderedSame {
                        // Do Nothing
                    } else if order == NSComparisonResult.OrderedAscending {
                        self.animateAdministratorDetailsView(false)
                    } else if order == NSComparisonResult.OrderedDescending {
                        self.animateAdministratorDetailsView(true)
                    }
            }
        }
    }

    func addPanGestureToPrescriberTableView () {
        
        // add pan gesture to table view
        let panGesture : UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("manageActionForPanGesture:"))
        medicationTableView?.addGestureRecognizer(panGesture)
        panGesture.delegate = self
    }
    
    func manageActionForPanGesture (panGestureRecognizer : UIPanGestureRecognizer) {
        
        // translate table view
        let translation : CGPoint = panGestureRecognizer.translationInView(self.view.superview)
        let velocity : CGPoint = panGestureRecognizer.velocityInView(self.view)
        let indexPathArray : [NSIndexPath] = medicationTableView!.indexPathsForVisibleRows!
        var panEnded = false
        if (panGestureRecognizer.state == UIGestureRecognizerState.Ended) {
            panEnded = true
        }
        // translate week view
        for var count = 0; count < indexPathArray.count; count++ {
            let indexPath = indexPathArray[count]
            let medicationCell = medicationTableView?.cellForRowAtIndexPath(indexPath) as? PrescriberMedicationTableViewCell
            var isLastCell : Bool = false
            if (count == indexPathArray.count - 1) {
                isLastCell = true
            }
            self.movePrescriberCell(medicationCell!, xTranslation: translation.x, xVelocity: velocity.x, panEnded: panEnded, isLastCell:isLastCell)
        }
        if let parentDelegate = self.delegate {
            if (calendarCellIsMoving) {
                parentDelegate.prescriberTableViewPannedWithTranslationParameters(translation.x, xVelocity : velocity.x, panEnded: panEnded)
            }
        }
        
        panGestureRecognizer.setTranslation(CGPointMake(0, 0), inView: panGestureRecognizer.view)
    }
    
    func movePrescriberCell(medicationCell : PrescriberMedicationTableViewCell,
        xTranslation: CGFloat,
        xVelocity : CGFloat,
        panEnded : Bool,
        isLastCell:Bool) {
            //medication administration slots have to be made constant width , medication details flexible width
            let parentViewController : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
            let calendarWidth : CGFloat = parentViewController.calendarViewWidth;
            let valueToTranslate = medicationCell.leadingSpaceMasterToContainerView.constant + xTranslation;
            if (valueToTranslate >= -calendarWidth && valueToTranslate <= calendarWidth) {
                medicationCell.leadingSpaceMasterToContainerView.constant = medicationCell.leadingSpaceMasterToContainerView.constant + xTranslation;
                calendarCellIsMoving = true
            }
            else {
                calendarCellIsMoving = false
            }
            if (panEnded == true) {
                if (xVelocity > 0) {
                    // animate to left. show previous week
                    self.displayPreviousWeekAdministrationDetailsInTableView(medicationCell, isLastCell: isLastCell)
                } else {
                    //show next week
                    self.displayNextWeekAdministrationDetailsInTableView(medicationCell, isLastCell: isLastCell)
                }
            }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer : UIGestureRecognizer) -> Bool {
        
        //to restrict pan gesture in vertical direction
        if (gestureRecognizer.isKindOfClass(UIPanGestureRecognizer)) {
            let panGesture = gestureRecognizer as? UIPanGestureRecognizer
            let translation : CGPoint = panGesture!.translationInView(panGesture?.view);
            if (fabs(translation.x) > fabs(translation.y)) {
                return true;
            }
        }
        return false
    }
    
    func allIndexPaths() -> [AnyObject] {
        
        var indexes = [AnyObject]()
        for j in 0...medicationTableView!.numberOfRowsInSection(0)-1
        {
            let index = NSIndexPath(forRow: j, inSection: 0)
            indexes.append(index)
        }
        return indexes
        
    }
    // MARK : Next and previous and today actions
    
    func displayPreviousWeekAdministrationDetailsInTableView(medicationCell : PrescriberMedicationTableViewCell, isLastCell:Bool) {
        
        //medication administration slots have to be made constant width , medication details flexible width
        let parentViewController : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        var weekViewAnimated : Bool = false
        UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
            
            // Reason for the first and second check (>= 100 & <0) is explained in the method
            // displayNextWeekAdministrationDetailsInTableView. Read for clarification.
            if (medicationCell.leadingSpaceMasterToContainerView.constant >= 100 ||
                medicationCell.leadingSpaceMasterToContainerView.constant < 0) {
                // animate to right , load previous week
                medicationCell.leadingSpaceMasterToContainerView.constant = parentViewController.calendarViewWidth
                parentViewController.showActivityIndicationOnViewRefresh(true)
            } else {
                medicationCell.leadingSpaceMasterToContainerView.constant = 0.0
            }
            if (weekViewAnimated == false) {
                parentViewController.modifyWeekDatesViewConstraint(medicationCell.leadingSpaceMasterToContainerView.constant)
                weekViewAnimated = true
            }
            medicationCell.layoutIfNeeded()
            }) { (Bool) -> Void in
                if isLastCell {
                    if ( medicationCell.leadingSpaceMasterToContainerView.constant == parentViewController.calendarViewWidth) {
                        autoreleasepool({ () -> () in
                            parentViewController.modifyStartDayAndWeekDates(false)
                            self.displayNextSetOfAdministrationDetails(false)
                        })
                    } else {
                        medicationCell.leadingSpaceMasterToContainerView.constant = 0.0
                        medicationCell.layoutIfNeeded()
                    }
                }
        }
    }
    
    func displayNextWeekAdministrationDetailsInTableView(medicationCell : PrescriberMedicationTableViewCell, isLastCell:Bool) {
        //medication administration slots have to be made constant width , medication details flexible width
        let parentViewController : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        var weekViewAnimated : Bool = false
        UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
            
            // The check <= -100 is to make sure that the next set of data is shown only after the
            // user has panned a reasonable distance. Otherwise for even a slight movement next set is loaded.
            // The second check > 0 is added as a workaround to fix the issue when user pan to the opposite
            // direction immediatly after panning to one direction. In that case the constant value will be positive.
            if (medicationCell.leadingSpaceMasterToContainerView.constant <= -100 || medicationCell.leadingSpaceMasterToContainerView.constant > 0) {
                //load next week details
                medicationCell.leadingSpaceMasterToContainerView.constant = -parentViewController.calendarViewWidth
                parentViewController.showActivityIndicationOnViewRefresh(true)
            } else {
                medicationCell.leadingSpaceMasterToContainerView.constant = 0.0
            }
            if (weekViewAnimated == false) {
                parentViewController.modifyWeekDatesViewConstraint(medicationCell.leadingSpaceMasterToContainerView.constant)
                weekViewAnimated = true
            }
            medicationCell.layoutIfNeeded()
            }) { (Bool) -> Void in
                if isLastCell {
                    if (medicationCell.leadingSpaceMasterToContainerView.constant == -parentViewController.calendarViewWidth) {
                        
                        autoreleasepool({ () -> () in
                            parentViewController.modifyStartDayAndWeekDates(true)
                            self.displayNextSetOfAdministrationDetails(true)
                            print("The constraint on future : %f", medicationCell.leadingSpaceMasterToContainerView.constant)
                        })
                    } else {
                        medicationCell.leadingSpaceMasterToContainerView.constant = 0.0
                        medicationCell.layoutIfNeeded()
                    }
                }
        }
    }
    
    func displayNextSetOfAdministrationDetails (isNextSet: Bool) {
        
        let parentViewController : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        if (DCHTTPRequestOperationManager.sharedOperationManager().operationQueue.operations.count > 0) {
            // checks if any operations are in the queue.
            webRequestCancelled = true
            self.hideAdministrationDetailsInCellsOnQuickSwipe()
            parentViewController.cancelPreviousMedicationListFetchRequest()
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                parentViewController.showActivityIndicationOnViewRefresh(true)
            })
        }
        else {
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                parentViewController.showActivityIndicationOnViewRefresh(false)
            })
        }
        self.modifyParentViewOnSwipeEnd(parentViewController)
    }
    
    func resetMedicationListCellsToOriginalPositionAfterCalendarSwipe() {
        
        if (displayMedicationListArray.count > 0) {
            let indexPathArray : [AnyObject] = medicationTableView!.indexPathsForVisibleRows!
            for var count = 0; count < indexPathArray.count; count++ {
                let indexPath = indexPathArray[count]
                let medicationCell = medicationTableView?.cellForRowAtIndexPath(indexPath as! NSIndexPath) as? PrescriberMedicationTableViewCell
                medicationCell!.leadingSpaceMasterToContainerView.constant = 0.0
                medicationCell!.layoutIfNeeded()
            }
        }
    }

    func modifyParentViewOnSwipeEnd (parentViewController : DCPrescriberMedicationViewController) {
        
        parentViewController.modifyWeekDatesInCalendarTopPortion()
        parentViewController.reloadCalendarTopPortion()
        parentViewController.fetchMedicationListForPatientWithCompletionHandler { (Bool) -> Void in
            self.webRequestCancelled = false
            self.resetMedicationListCellsToOriginalPositionAfterCalendarSwipe()
        }
    }
    
    func hideAdministrationDetailsInCellsOnQuickSwipe () {
        
        let visibleCellsArray = medicationTableView?.visibleCells
        if visibleCellsArray?.count > 0 {
            var index : NSInteger = 0
            while index < visibleCellsArray?.count {
                let cellsArray = visibleCellsArray! as NSArray
                let medicationCell : PrescriberMedicationTableViewCell = cellsArray.objectAtIndex(index) as! PrescriberMedicationTableViewCell
                let leftDetailView = medicationCell.leftMedicationAdministerDetailsView
                let masterDetailView = medicationCell.masterMedicationAdministerDetailsView
                let rightDetailView = medicationCell.rightMedicationAdministerDetailsView
                self.hideAdministrationStatusViewOnSwipe(leftDetailView)
                self.hideAdministrationStatusViewOnSwipe(masterDetailView)
                self.hideAdministrationStatusViewOnSwipe(rightDetailView)
                index++
            }
        }
    }
    
    func hideAdministrationStatusViewOnSwipe (holderView: UIView) {
     
        for cellSubView in holderView.subviews {
            if cellSubView.isKindOfClass(DCMedicationAdministrationStatusView) {
                let statusView = cellSubView as! DCMedicationAdministrationStatusView
                statusView.statusLabel?.hidden = true
                statusView.statusIcon?.hidden = true
            }
        }
    }
    
    // MARK: - Data processing
    /**
    Flattens the time chart data in the following format
    {
    "medicationId": {
    "date": [DCMedicationSlot]
    }
    }
    */
    func flattenMedicationTimeChartData() {
        medicationTimeChartData = NSMutableDictionary()
        for medicationScheduleDetails in displayMedicationListArray {
            let scheduleDetails = medicationScheduleDetails as! DCMedicationScheduleDetails
            let medicationId = scheduleDetails.medicationId
            
            //Iterate over timeChart array
            let flattenedData = NSMutableDictionary()
            if let timeChart = scheduleDetails.timeChart {
                for timeChartData in timeChart {
                    let timeData = timeChartData as! NSDictionary
                    let medDate = timeData[MED_DATE] as! NSString
                    let medDetails = timeData[MED_DETAILS] as! [DCMedicationSlot]
                    
                    flattenedData[medDate] = medDetails
                }
            }
            
            medicationTimeChartData[medicationId] = flattenedData
            
        }
    }
    
    // MARK: - Data display methods in table view
    
    func resetStatusViewsIfNeededInTableViewCell(cell: PrescriberMedicationTableViewCell) {
        let calendarStripDaysCount = (appDelegate.windowState == DCWindowState.fullWindow) ? 5:3
        let statusViewsCount = cell.masterMedicationAdministerDetailsView.subviews.count
        
        if calendarStripDaysCount != statusViewsCount {
            cell.removeAllStatusViews()
            // Add new status views
            cell.createAdministerStatusViews()
        }
        
    }
    
    func fillInMedicationDetailsInTableCell(cell: PrescriberMedicationTableViewCell,
        atIndexPath indexPath:NSIndexPath) {
            let medicationCell = cell
            if (displayMedicationListArray.count >= indexPath.item) {
                let medicationSchedules = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
                medicationCell.medicineName.text = medicationSchedules.name
                let instructionString : String
                if (medicationSchedules.instruction != EMPTY_STRING && medicationSchedules.instruction != nil) {
                    instructionString = String(format: " (%@)", (medicationSchedules.instruction)!)
                } else {
                    instructionString = EMPTY_STRING
                }
                medicationCell.instructions.text = instructionString
                let routeString : String = medicationSchedules.route.stringByReplacingOccurrencesOfString(" ", withString: EMPTY_STRING)
                medicationCell.route.text = routeString;
                var typeString : String = DCCalendarHelper.typeDescriptionForMedication(medicationSchedules)
                if medicationSchedules.isActive == true {
                    medicationCell.medicationTypeLabel.text = typeString
                } else {
                    typeString = "\(typeString) - \(DISCONTINUED_STRING)"
                    let range = (typeString as NSString).rangeOfString(DISCONTINUED_STRING)
                    let attributedTypeString  = NSMutableAttributedString(string: typeString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12.0)])
                    attributedTypeString.addAttribute(NSForegroundColorAttributeName, value: UIColor(forHexString: "#e87b7b") , range: range)
                    medicationCell.medicationTypeLabel.attributedText = attributedTypeString
                }
            }
    }
    
    func configureMedicationCell(medicationCell:PrescriberMedicationTableViewCell, withMedicationSlotsArray
        rowDisplayMedicationSlotsArray:NSMutableArray,
        atIndexPath indexPath:NSIndexPath,
        andSlotIndex index:NSInteger) {
            
            let calendarStripDaysCount = (appDelegate.windowState == DCWindowState.fullWindow) ? 5:3
            
            var statusView: DCMedicationAdministrationStatusView! = nil
            
            switch (index) {
            case 0..<calendarStripDaysCount:
                statusView = medicationCell.leftMedicationAdministerDetailsView.viewWithTag(index+1) as? DCMedicationAdministrationStatusView
            case calendarStripDaysCount..<2*calendarStripDaysCount:
                statusView = medicationCell.masterMedicationAdministerDetailsView.viewWithTag((index+1) - calendarStripDaysCount) as? DCMedicationAdministrationStatusView
            case 2*calendarStripDaysCount..<3*calendarStripDaysCount:
                statusView = medicationCell.rightMedicationAdministerDetailsView.viewWithTag((index+1) - 2 * calendarStripDaysCount) as? DCMedicationAdministrationStatusView
            default:
                break;
            }
            
            if let statusView = statusView {
                statusView.resetViewElements()
                
                statusView.delegate = self
                statusView.currentIndexPath = indexPath
                let medicationSchedules = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
                statusView.medicationCategory = medicationSchedules.medicineCategory
                let slotDictionary:NSDictionary = rowDisplayMedicationSlotsArray.objectAtIndex(index) as! NSDictionary
                
                statusView.updateAdministrationStatusViewWithMedicationSlotDictionary(slotDictionary)
                
                let weekDate = currentWeekDatesArray.objectAtIndex(index) as? NSDate
                statusView.configureStatusViewForWeekDate(weekDate!)
            }
            
    }
    
    func addAdministerStatusViewsToTableCell(medicationCell: PrescriberMedicationTableViewCell, toContainerSubview containerView: UIView,  forMedicationSlotDictionary slotDictionary:NSDictionary,
        atIndexPath indexPath:NSIndexPath,
        atSlotIndex tag:NSInteger) -> DCMedicationAdministrationStatusView {
            
            for subView : UIView in containerView.subviews {
                if (subView.tag == tag) {
                    existingStatusViews.addObject(subView)
                }
            }
            let slotWidth = DCUtility.mainWindowSize().width
            // medication administration slots have to be made constant width , medication details flexible width
            let parentViewController : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
            var viewWidth = (slotWidth - parentViewController.calendarViewWidth)/3
            if (appDelegate.windowState == DCWindowState.fullWindow) {
                viewWidth = (slotWidth - parentViewController.calendarViewWidth)/5
            }
            let xValue : CGFloat = CGFloat(tag) * viewWidth + CGFloat(tag) + 1;
            let viewFrame = CGRectMake(xValue, 0, viewWidth, 78.0)
            let statusView : DCMedicationAdministrationStatusView = DCMedicationAdministrationStatusView(frame: viewFrame)
            let medicationSchedules = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
            statusView.delegate = self
            statusView.tag = tag
            statusView.currentIndexPath = indexPath
            statusView.isOneThirdScreen = false
            statusView.medicationCategory = medicationSchedules.medicineCategory
            statusView.startDate = DCDateUtility.dateFromSourceString(medicationSchedules.startDate)
            statusView.backgroundColor = UIColor.whiteColor()
            statusView.updateAdministrationStatusViewWithMedicationSlotDictionary(slotDictionary)
            return statusView
    }
    
    func prepareMedicationSlotsForDisplayInCellFromScheduleDetails (medicationScheduleDetails: DCMedicationScheduleDetails) -> NSMutableArray {
        
        let medicationSlotsArray: NSMutableArray = []
        
        var count = 0
        for weekDate in currentWeekDatesStrings {
            let slotsDictionary = NSMutableDictionary()
            let date = weekDate as! String
            if let medicationId = medicationScheduleDetails.medicationId {
                if let administrationData = medicationTimeChartData.valueForKey(medicationId) {
                    if let medDetails = administrationData.valueForKey(date) {
                        slotsDictionary.setObject(medDetails, forKey: PRESCRIBER_TIME_SLOTS)
                    }
                }
            }
            slotsDictionary.setObject(NSNumber (integer: count + 1), forKey: PRESCRIBER_SLOT_VIEW_TAG)
            medicationSlotsArray.addObject(slotsDictionary)
            count++
        }
        
        return medicationSlotsArray
    }
    
    func swipeBackMedicationCellsInTableView() {
        
        for (index,_) in displayMedicationListArray.enumerate(){
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if indexPath == selectedIndexPath {
                continue
            }
            let medicationCell = medicationTableView?.cellForRowAtIndexPath(indexPath)
                as? PrescriberMedicationTableViewCell
            medicationCell?.swipeMedicationDetailViewToRight()
        }
    }
    
    //MARK - DCMedicationAdministrationStatusProtocol delegate implementation
    
    func administerMedicationWithMedicationSlots (medicationSLotDictionary: NSDictionary, atIndexPath indexPath: NSIndexPath ,withWeekDate date : NSDate) {
        let parentView : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        parentView.displayAdministrationViewForMedicationSlot(medicationSLotDictionary as [NSObject : AnyObject], atIndexPath: indexPath, withWeekDate: date)
    }
    
    //MARK - EditAndDeleteActionDelegate methods
    
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
        addMedicationViewController?.patientId = self.patientId as String
        //TODO: Remove shedule details when scheduling is available from api
        if (medicationScheduleDetails.scheduling == nil) {
            medicationScheduleDetails.scheduling = DCScheduling.init();
            medicationScheduleDetails.scheduling.type = SPECIFIC_TIMES;
            medicationScheduleDetails.scheduling.specificTimes = DCSpecificTimes.init()
            medicationScheduleDetails.scheduling.specificTimes.repeatObject = DCRepeat.init()
            medicationScheduleDetails.scheduling.specificTimes.repeatObject.repeatType = DAILY
            medicationScheduleDetails.scheduling.specificTimes.repeatObject.frequency = "1 day"
        }
        if (medicationScheduleDetails.infusion == nil) {
            medicationScheduleDetails.infusion = DCInfusion.init()
        }
        addMedicationViewController?.selectedMedication = medicationScheduleDetails
        addMedicationViewController?.isEditMedication = true
        addMedicationViewController?.delegate = self
        addMedicationViewController?.medicationEditIndexPath = indexPath
        let navigationController : UINavigationController? = UINavigationController(rootViewController: addMedicationViewController!)
        navigationController?.modalPresentationStyle = UIModalPresentationStyle.Popover
        self.presentViewController(navigationController!, animated: true, completion: nil)
        let popover = navigationController?.popoverPresentationController
        popover?.delegate = addMedicationViewController
        popover?.permittedArrowDirections = .Left
        let cell = medicationTableView!.cellForRowAtIndexPath(indexPath) as! PrescriberMedicationTableViewCell?
        popover?.sourceRect = CGRectMake(cell!.editButton.bounds.origin.x - (205 + cell!.editButton.bounds.size.width),cell!.editButton.bounds.origin.y - 300,310,690);
        popover!.sourceView = cell?.editButton
    }
    
    func transitToSummaryScreenForMedication(indexpath : NSIndexPath) {
        
        let summaryStoryboard : UIStoryboard? = UIStoryboard(name:SUMMARY_STORYBOARD, bundle: nil)
        let medicationSummaryViewController = summaryStoryboard!.instantiateViewControllerWithIdentifier("MedicationSummary") as? DCMedicationSummaryDisplayViewController
        medicationSummaryViewController!.summaryType = eDrugChart
        let medicationList: DCMedicationScheduleDetails = displayMedicationListArray[indexpath.item] as! DCMedicationScheduleDetails
        medicationSummaryViewController!.scheduleId = medicationList.scheduleId
        medicationSummaryViewController!.medicationDetails = medicationList
        let rowDisplayMedicationSlotsArray = self.prepareMedicationSlotsForDisplayInCellFromScheduleDetails(medicationList)
        medicationSummaryViewController!.medicationSlotsArray = rowDisplayMedicationSlotsArray as! [DCMedicationSlot]
        medicationSummaryViewController!.patientId = self.patientId

        let navigationController: UINavigationController = UINavigationController(rootViewController: medicationSummaryViewController!)
        navigationController.modalPresentationStyle = .FormSheet
        self.presentViewController(navigationController, animated: true, completion: { _ in })

    }
    
    func deleteMedicationAtIndexPath(indexPath : NSIndexPath) {
        
        let medicationScheduleDetails: DCMedicationScheduleDetails = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
        let webService : DCStopMedicationWebService = DCStopMedicationWebService.init()
        webService.stopMedicationForPatientWithId(patientId as String, drugWithScheduleId: medicationScheduleDetails.scheduleId) { (array, error) -> Void in
            if error == nil {
                self.medicationTableView!.beginUpdates()
                if let medicationArray = self.displayMedicationListArray.mutableCopy() as? NSMutableArray {
                    medicationArray.removeObjectAtIndex(indexPath.row)
                    self.displayMedicationListArray = medicationArray
                }
                self.medicationTableView!.deleteRowsAtIndexPaths([indexPath as NSIndexPath], withRowAnimation: .Fade)
                self.medicationTableView!.endUpdates()
                self.medicationTableView?.reloadData()
                if let delegate = self.delegate {
                    delegate.refreshMedicationList()
                }
            } else {
                // TO DO: handle the case for already deleted medication.
                if (error.code == NETWORK_NOT_REACHABLE || error.code == NOT_CONNECTED_TO_INTERNET) {
                    DCUtility.displayAlertWithTitle(NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("INTERNET_CONNECTION_ERROR", comment: ""))
                } else if (error.code == WEBSERVICE_UNAVAILABLE) {
                    DCUtility.displayAlertWithTitle(NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("WEBSERVICE_UNAVAILABLE", comment: ""))
                }
            }
        }
    }
    
    func animateAdministratorDetailsView (isRight : Bool) {
        let parentViewController : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        parentViewController.showActivityIndicationOnViewRefresh(true)
        let indexPathArray : [NSIndexPath] = medicationTableView!.indexPathsForVisibleRows!
        //medication administration slots have to be made constant width , medication details flexible width
        var calendarWidthConstraint = parentViewController.calendarViewWidth
        if (!isRight) {
            calendarWidthConstraint = -parentViewController.calendarViewWidth
        }
        for var count = 0; count < indexPathArray.count; count++ {
            let indexPath = indexPathArray[count]
            let medicationCell = medicationTableView?.cellForRowAtIndexPath(indexPath) as? PrescriberMedicationTableViewCell
            var isLastCell : Bool = false
            var weekViewAnimated : Bool = false
            if (count == indexPathArray.count - 1) {
                isLastCell = true
                parentViewController.loadCurrentWeekDate()
                parentViewController.modifyWeekDatesInCalendarTopPortion()
                parentViewController.reloadCalendarTopPortion()
            }
            
            UIView.animateWithDuration(0.6, animations: { () -> Void in
                if (medicationCell!.leadingSpaceMasterToContainerView.constant == 0) {
                    medicationCell!.leadingSpaceMasterToContainerView.constant = calendarWidthConstraint
                } else {
                    medicationCell!.leadingSpaceMasterToContainerView.constant = 0.0
                }
                if (weekViewAnimated == false) {
                    parentViewController.modifyWeekDatesViewConstraint(0.0)
                    weekViewAnimated = true
                }
                medicationCell!.layoutIfNeeded()
                }) { (Bool) -> Void in
                if isLastCell {
                        if ( medicationCell!.leadingSpaceMasterToContainerView.constant == calendarWidthConstraint) {
                            autoreleasepool({ () -> () in
                                //parentViewController.updatePrescriberMedicationListDetails()
//                                parentViewController.cancelPreviousMedicationListFetchRequest()
//                                parentViewController.fetchMedicationListForPatientWithCompletionHandler({ (Bool) -> Void in
//                                    
//                                })
                                self.modifyParentViewOnSwipeEnd(parentViewController)
                            })
                        }
                    }
                    medicationCell!.leadingSpaceMasterToContainerView.constant = 0.0
                    medicationCell!.layoutIfNeeded()
            }
        }
    }
    
    func medicationEditCancelledForIndexPath(editIndexPath: NSIndexPath!) {
        
        self.animatePrescriberCellToOriginalStateAtIndexPath(editIndexPath);
    }
    
    func indexPathForLastRowWith(numberOfRows rows : Int, numberOfSection sections : Int) -> NSIndexPath {
        
    return NSIndexPath(forRow: rows - 1, inSection: sections)
    }
    
    func scrollToLatestMedication(shouldScroll scroll:Bool) {
        
        if scroll {
            let numberOfRows : Int! = self.medicationTableView?.numberOfRowsInSection(0)
            if numberOfRows > 0 {
                print(numberOfRows)
                let indexPath = self.indexPathForLastRowWith(numberOfRows: numberOfRows-1, numberOfSection: 0)
                print(indexPath)
                self.medicationTableView?.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            }
        }else {
            
        }
    }
}

