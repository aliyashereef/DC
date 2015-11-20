//
//  DCPrescriberMedicationListViewController.swift
//  DrugChart
//
//  Created by Muhammed Shaheer on 06/10/15.
//
//

import UIKit

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
    var delegate : PrescriberListDelegate?
    var patientId : NSString = EMPTY_STRING
    var panGestureDirection : PanDirection = PanDirection.atCenter
    let existingStatusViews : NSMutableArray = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    // MARK: - View Management Methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        medicationTableView!.tableFooterView = UIView(frame: CGRectZero)
        medicationTableView!.delaysContentTouches = false;
        addPanGestureToPrescriberTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            let medicationScheduleDetails: DCMedicationScheduleDetails = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
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
            var index : NSInteger = 0
            for ( index = 0; index < rowDisplayMedicationSlotsArray.count; index++) {
                
                self.configureMedicationCell(medicationCell!,
                    withMedicationSlotsArray: rowDisplayMedicationSlotsArray,
                    atIndexPath: indexPath,
                    andSlotIndex: index)
            }
            return medicationCell!
    }
    
    // MARK: - Public methods
    
    func reloadMedicationListWithDisplayArray (displayArray: NSMutableArray) {
        
        displayMedicationListArray =  displayArray as NSMutableArray
        medicationTableView?.reloadData()
    }
    
    func animatePrescriberCellToOriginalStateAtIndexPath(indexPath : NSIndexPath) {
        
        let prescriberCell = medicationTableView?.cellForRowAtIndexPath(indexPath) as? PrescriberMedicationTableViewCell
        prescriberCell!.swipeMedicationDetailViewToRight()
    }

    //TODO: temporary logic for today button action.
    
    func todayButtonClicked () {
        
        let weekdate = currentWeekDatesArray.objectAtIndex(7) // extracting the middle date - todays date
        let calendar : NSCalendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let todaysDate : NSDate = calendar.startOfDayForDate(NSDate())
        let order = NSCalendar.currentCalendar().compareDate(weekdate as! NSDate, toDate:todaysDate,
            toUnitGranularity: .Day)
        if order == NSComparisonResult.OrderedSame {
            // Do Nothing
        } else if order == NSComparisonResult.OrderedAscending {
            self.animateAdministratorDetailsView(false)
        } else if order == NSComparisonResult.OrderedDescending {
            self.animateAdministratorDetailsView(true)
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
       // let parentView : PrescriberMedicationViewController = self.parentViewController as! PrescriberMedicationViewController
        //if (parentView.isLoading == false) {
            let translation : CGPoint = panGestureRecognizer.translationInView(self.view.superview)
            let velocity : CGPoint = panGestureRecognizer.velocityInView(self.view)
            let indexPathArray : [NSIndexPath] = medicationTableView!.indexPathsForVisibleRows!
            var panEnded = false
            if (panGestureRecognizer.state == UIGestureRecognizerState.Ended) {
                panEnded = true
            }
            // translate week view
            if let parentDelegate = self.delegate {
                parentDelegate.prescriberTableViewPannedWithTranslationParameters(translation.x, xVelocity : velocity.x, panEnded: panEnded)
            }
            for var count = 0; count < indexPathArray.count; count++ {
                let indexPath = indexPathArray[count]
                let medicationCell = medicationTableView?.cellForRowAtIndexPath(indexPath) as? PrescriberMedicationTableViewCell
                var isLastCell : Bool = false
                if (count == indexPathArray.count - 1) {
                    isLastCell = true
                }
                self.movePrescriberCell(medicationCell!, xTranslation: translation.x, xVelocity: velocity.x, panEnded: panEnded, isLastCell:isLastCell)
            }
            panGestureRecognizer.setTranslation(CGPointMake(0, 0), inView: panGestureRecognizer.view)
      //  }
    }
    
    func movePrescriberCell(medicationCell : PrescriberMedicationTableViewCell,
        xTranslation: CGFloat,
        xVelocity : CGFloat,
        panEnded : Bool,
        isLastCell:Bool) {

        
        let calendarWidth : CGFloat = (DCUtility.mainWindowSize().width - MEDICATION_VIEW_WIDTH);
        let valueToTranslate = medicationCell.leadingSpaceMasterToContainerView.constant + xTranslation;
        if (valueToTranslate >= -calendarWidth && valueToTranslate <= calendarWidth) {
            medicationCell.leadingSpaceMasterToContainerView.constant = medicationCell.leadingSpaceMasterToContainerView.constant + xTranslation;
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
        
        let calendarWidth : CGFloat = (DCUtility.mainWindowSize().width - MEDICATION_VIEW_WIDTH);
        let parentViewController : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        var weekViewAnimated : Bool = false
        UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
            if (medicationCell.leadingSpaceMasterToContainerView.constant >= 100) {
                // animate to right , load previous week
                medicationCell.leadingSpaceMasterToContainerView.constant = calendarWidth
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
                    if ( medicationCell.leadingSpaceMasterToContainerView.constant == calendarWidth) {
                        autoreleasepool({ () -> () in
                            parentViewController.modifyStartDayAndWeekDates(false)
                            self.modifyParentViewOnSwipeEnd(parentViewController)
                        })
                    }
                }
                medicationCell.leadingSpaceMasterToContainerView.constant = 0.0
                medicationCell.layoutIfNeeded()
        }
    }
    
    func displayNextWeekAdministrationDetailsInTableView(medicationCell : PrescriberMedicationTableViewCell, isLastCell:Bool) {
        
        let calendarWidth : CGFloat = (DCUtility.mainWindowSize().width - MEDICATION_VIEW_WIDTH);
        let parentViewController : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        var weekViewAnimated : Bool = false
        UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
            
            if (medicationCell.leadingSpaceMasterToContainerView.constant <= -100) {
                //load next week details
                medicationCell.leadingSpaceMasterToContainerView.constant = -calendarWidth
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
                    if (medicationCell.leadingSpaceMasterToContainerView.constant == -calendarWidth) {
                        autoreleasepool({ () -> () in
                            parentViewController.modifyStartDayAndWeekDates(true)
                            self.modifyParentViewOnSwipeEnd(parentViewController)
                        })
                    }
                }
                medicationCell.leadingSpaceMasterToContainerView.constant = 0.0
                medicationCell.layoutIfNeeded()
        }
    }
    
    func modifyParentViewOnSwipeEnd (parentViewController : DCPrescriberMedicationViewController) {
        
        parentViewController.updatePrescriberMedicationListDetails()
        parentViewController.modifyWeekDatesInCalendarTopPortion()
        parentViewController.reloadCalendarTopPortion()
        parentViewController.cancelPreviousMedicationListFetchRequest()
        parentViewController.fetchMedicationListForPatient()
    }
    
    // MARK: - Data display methods in table view
    
    func fillInMedicationDetailsInTableCell(cell: PrescriberMedicationTableViewCell,
        atIndexPath indexPath:NSIndexPath) {
            let medicationCell = cell
            if (displayMedicationListArray.count >= indexPath.item) {
                
                let medicationSchedules = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
                medicationCell.medicineName.text = medicationSchedules.name;
                if let instructionString = medicationSchedules.instruction {
                    if (instructionString as NSString).length > 0 {
                        medicationCell.instructions.text = NSString(format: "(%@)", instructionString) as String ;
                    }
                }
                let routeString : String = medicationSchedules.route.stringByReplacingOccurrencesOfString(" ", withString: EMPTY_STRING)
                medicationCell.route.text = routeString;
            }
    }
    
    func configureMedicationCell(medicationCell:PrescriberMedicationTableViewCell, withMedicationSlotsArray
        rowDisplayMedicationSlotsArray:NSMutableArray,
        atIndexPath indexPath:NSIndexPath,
        andSlotIndex index:NSInteger) {
            if (index < 5) {
                let statusView : DCMedicationAdministrationStatusView = self.addAdministerStatusViewsToTableCell(medicationCell, toContainerSubview: medicationCell.leftMedicationAdministerDetailsView, forMedicationSlotDictionary: rowDisplayMedicationSlotsArray.objectAtIndex(index) as! NSDictionary, atIndexPath: indexPath, atSlotIndex: index);
                let weekdate = currentWeekDatesArray.objectAtIndex(index) as? NSDate
                medicationCell.leftMedicationAdministerDetailsView.addSubview(statusView)
                statusView.configureStatusViewForWeekDate(weekdate!)
            }
            else if (index >= 5 && index < 10) {
                let statusView : DCMedicationAdministrationStatusView = self.addAdministerStatusViewsToTableCell(medicationCell, toContainerSubview: medicationCell.masterMedicationAdministerDetailsView, forMedicationSlotDictionary: rowDisplayMedicationSlotsArray.objectAtIndex(index) as! NSDictionary,
                    atIndexPath: indexPath,
                    atSlotIndex: index - 5)
                let weekdate = currentWeekDatesArray.objectAtIndex(index) as? NSDate
                medicationCell.masterMedicationAdministerDetailsView.addSubview(statusView)
                statusView.configureStatusViewForWeekDate(weekdate!)
            }
            else if (index >= 10 && index < 15) {
                let statusView : DCMedicationAdministrationStatusView = self.addAdministerStatusViewsToTableCell(medicationCell, toContainerSubview: medicationCell.rightMedicationAdministerDetailsView, forMedicationSlotDictionary: rowDisplayMedicationSlotsArray.objectAtIndex(index) as! NSDictionary,
                    atIndexPath: indexPath,
                    atSlotIndex: index - 10)
                let weekdate = currentWeekDatesArray.objectAtIndex(index) as? NSDate
                medicationCell.rightMedicationAdministerDetailsView.addSubview(statusView)
                statusView.configureStatusViewForWeekDate(weekdate!)
            }
            for subView in existingStatusViews {
                subView.removeFromSuperview()
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
            let viewWidth = (slotWidth - 300)/5
            let xValue : CGFloat = CGFloat(tag) * viewWidth + CGFloat(tag) + 1;
            let viewFrame = CGRectMake(xValue, 0, viewWidth, 78.0)
            let statusView : DCMedicationAdministrationStatusView = DCMedicationAdministrationStatusView(frame: viewFrame)
            let medicationSchedules = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
            statusView.delegate = self
            statusView.tag = tag
            statusView.currentIndexPath = indexPath
            statusView.isOneThirdScreen = false
            statusView.medicationCategory = medicationSchedules.medicineCategory
            statusView.backgroundColor = UIColor.whiteColor()
            statusView.updateAdministrationStatusViewWithMedicationSlotDictionary(slotDictionary)
            return statusView
    }
    
    func prepareMedicationSlotsForDisplayInCellFromScheduleDetails (medicationScheduleDetails: DCMedicationScheduleDetails) -> NSMutableArray {
    
        //TODO: commented out for Oct 12 release. Logic to be corrected.
        var count = 0, weekDays = 15
        let medicationSlotsArray: NSMutableArray = []
        while (count < weekDays) {
            let slotsDictionary = NSMutableDictionary()
            if count < self.currentWeekDatesArray.count {
                let date = self.currentWeekDatesArray.objectAtIndex(count)
                let formattedDateString = DCDateUtility.dateStringFromDate(date as! NSDate, inFormat: SHORT_DATE_FORMAT)
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
    
    //MARK - DCMedicationAdministrationStatusProtocol delegate implementation
    
    func administerMedicationWithMedicationSlots (medicationSLotDictionary: NSDictionary, atIndexPath indexPath: NSIndexPath ,withWeekDate date : NSDate) {
        let parentView : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        parentView.displayAdministrationViewForMedicationSlot(medicationSLotDictionary as [NSObject : AnyObject], atIndexPath: indexPath, withWeekDate: date)
    }
    
    //MARK - EditAndDeleteActionDelegate methods
    
    func stopMedicationForSelectedIndexPath(indexPath: NSIndexPath) {
        deleteMedicationAtIndexPath(indexPath)
    }
    
    func editMedicationForSelectedIndexPath(indexPath: NSIndexPath) {
        let medicationScheduleDetails: DCMedicationScheduleDetails = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
        let addMedicationViewController : DCAddMedicationInitialViewController? = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_MEDICATION_POPOVER_SB_ID) as? DCAddMedicationInitialViewController

        addMedicationViewController?.patientId = self.patientId as String
        //TODO: Remove shedule details when scheduling is available from api
        if (medicationScheduleDetails.scheduling == nil) {
            medicationScheduleDetails.scheduling = DCScheduling.init();
            medicationScheduleDetails.scheduling.type = SPECIFIC_TIMES;
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
                // If we want to reload the medication list, uncomment the lines
//                if let delegate = self.delegate {
//                    delegate.refreshMedicationList()
//
//                }
            } else {
                // TO DO: handle the case for already deleted medication.
            }
        }
    }
    
//    - (void)medicationEditCancelledForIndexPath:(NSIndexPath *)editIndexPath {
//    
//    [prescriberMedicationListViewController animatePrescriberCellToOriginalStateAtIndexPath:editIndexPath];
//    }
    
    func animateAdministratorDetailsView (isRight : Bool) {
        let parentViewController : DCPrescriberMedicationViewController = self.parentViewController as! DCPrescriberMedicationViewController
        parentViewController.showActivityIndicationOnViewRefresh(true)
        let indexPathArray : [NSIndexPath] = medicationTableView!.indexPathsForVisibleRows!
        let calendarWidth : CGFloat = (DCUtility.mainWindowSize().width - MEDICATION_VIEW_WIDTH);
        var calendarWidthConstraint = calendarWidth
        if (!isRight) {
            calendarWidthConstraint = -calendarWidth
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
                                parentViewController.updatePrescriberMedicationListDetails()
                                parentViewController.cancelPreviousMedicationListFetchRequest()
                                parentViewController.fetchMedicationListForPatient()
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
}

