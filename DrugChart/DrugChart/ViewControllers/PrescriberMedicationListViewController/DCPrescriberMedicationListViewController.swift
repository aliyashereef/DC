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
    func refreshMedicationList()
}


@objc class DCPrescriberMedicationListViewController: DCBaseViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, DCMedicationAdministrationStatusProtocol, EditAndDeleteActionDelegate {


    @IBOutlet var medicationTableView: UITableView?
    var displayMedicationListArray : NSMutableArray = []
    var currentWeekDatesArray : NSMutableArray = []
    var delegate : PrescriberListDelegate?
    var patientId : NSString = EMPTY_STRING
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        medicationTableView!.tableFooterView = UIView(frame: CGRectZero)
        addPanGestureToPrescriberTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return displayMedicationListArray.count
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

    // MARK: - Private methods
    // MARK: - Pan gesture methods
    func addPanGestureToPrescriberTableView () {
        
        // add pan gesture to table view
        let panGesture : UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("moveMedicationCalendarDisplayForPanGesture:"))
        medicationTableView?.addGestureRecognizer(panGesture)
        panGesture.delegate = self
    }
    
    func moveMedicationCalendarDisplayForPanGesture (panGestureRecognizer : UIPanGestureRecognizer) {
        
        // translate table view
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
            let meditationCell = medicationTableView?.cellForRowAtIndexPath(indexPath) as? PrescriberMedicationTableViewCell
            meditationCell!.movePrescriberCellWithTranslationParameters(translation.x, xVelocity: velocity.x, panEnded: panEnded)
        }
        panGestureRecognizer.setTranslation(CGPointMake(0, 0), inView: panGestureRecognizer.view)
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
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
                medicationCell.route.text = medicationSchedules.route;
            }
    }
    
    func configureMedicationCell(medicationCell:PrescriberMedicationTableViewCell, withMedicationSlotsArray
        rowDisplayMedicationSlotsArray:NSMutableArray,
        atIndexPath indexPath:NSIndexPath,
        andSlotIndex index:NSInteger) {
            
            // just for the display purpose.
            // metjod implementation in progress.
            //TODO: commented out for Oct 12 release. Logic to be corrected. Temporary logic for left and right display.
            if (index < 5) {
                let statusView : DCMedicationAdministrationStatusView = self.addAdministerStatusViewsToTableCell(medicationCell, forMedicationSlotDictionary: rowDisplayMedicationSlotsArray.objectAtIndex(index) as! NSDictionary,
                    atIndexPath: indexPath,
                    atSlotIndex: index)
                statusView.weekdate = currentWeekDatesArray.objectAtIndex(index) as? NSDate
                medicationCell.leftMedicationAdministerDetailsView.addSubview(statusView)
            }
            else if (index >= 5 && index < 10) {
                let statusView : DCMedicationAdministrationStatusView = self.addAdministerStatusViewsToTableCell(medicationCell, forMedicationSlotDictionary: rowDisplayMedicationSlotsArray.objectAtIndex(index) as! NSDictionary,
                    atIndexPath: indexPath,
                    atSlotIndex: index - 5)
                statusView.weekdate = currentWeekDatesArray.objectAtIndex(index) as? NSDate
                medicationCell.masterMedicationAdministerDetailsView.addSubview(statusView)
            }
            else if (index >= 10 && index < 15) {
                let statusView : DCMedicationAdministrationStatusView = self.addAdministerStatusViewsToTableCell(medicationCell, forMedicationSlotDictionary: rowDisplayMedicationSlotsArray.objectAtIndex(index) as! NSDictionary,
                    atIndexPath: indexPath,
                    atSlotIndex: index - 10)
                statusView.weekdate = currentWeekDatesArray.objectAtIndex(index) as? NSDate
                medicationCell.rightMedicationAdministerDetailsView.addSubview(statusView)
            }
    }
    
    func addAdministerStatusViewsToTableCell(medicationCell: PrescriberMedicationTableViewCell, forMedicationSlotDictionary slotDictionary:NSDictionary,
        atIndexPath indexPath:NSIndexPath,
        atSlotIndex tag:NSInteger) -> DCMedicationAdministrationStatusView {
            
            let slotWidth = DCUtility.getMainWindowSize().width
            let viewWidth = (slotWidth - 300)/5
            let xValue : CGFloat = CGFloat(tag) * viewWidth + CGFloat(tag) + 1;
            let viewFrame = CGRectMake(xValue, 0, viewWidth, 78.0)
            let statusView : DCMedicationAdministrationStatusView = DCMedicationAdministrationStatusView(frame: viewFrame)
            statusView.delegate = self
            statusView.tag = tag
            statusView.weekdate = currentWeekDatesArray.objectAtIndex(tag) as? NSDate
            statusView.currentIndexPath = indexPath
            statusView.backgroundColor = UIColor.whiteColor()
            statusView.updateAdministrationStatusViewWithMedicationSlotDictionary(slotDictionary)
            return statusView
    }
    
    func prepareMedicationSlotsForDisplayInCellFromScheduleDetails (medicationScheduleDetails: DCMedicationScheduleDetails) -> NSMutableArray {
        
        //TODO: commented out for Oct 12 release. Logic to be corrected.
        //var count = 0, weekDays = 5
        var count = 0, weekDays = 15
        let medicationSlotsArray: NSMutableArray = []
        while (count < weekDays) {
            let slotsDictionary = NSMutableDictionary()
            if count < currentWeekDatesArray.count {
                let date = currentWeekDatesArray.objectAtIndex(count)
                let formattedDateString = DCDateUtility.convertDate(date as! NSDate, fromFormat: DEFAULT_DATE_FORMAT,
                    toFormat: SHORT_DATE_FORMAT)
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
        let parentView : PrescriberMedicationViewController = self.parentViewController as! PrescriberMedicationViewController
        parentView.displayAdministrationViewForMedicationSlot(medicationSLotDictionary as [NSObject : AnyObject], atIndexPath: indexPath, withWeekDate: date)
    }
    
    //MARK - EditAndDeleteActionDelegate methods 
    func stopMedicationForSelectedIndexPath(indexPath: NSIndexPath) {
        deleteMedicationAtIndexPath(indexPath)
    }
    
    func deleteMedicationAtIndexPath(indexPath : NSIndexPath) {
        
        let medicationScheduleDetails: DCMedicationScheduleDetails = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
        let webService : DCStopMedicationWebService = DCStopMedicationWebService.init()
        webService.stopMedicationForPatientWithId(patientId as String, drugWithScheduleId: medicationScheduleDetails.scheduleId) { (array, error) -> Void in
            if error == nil {
                self.medicationTableView!.beginUpdates()
                print(self.displayMedicationListArray ,"index PAth     ******", indexPath.row)
                var arr : [DCMedicationScheduleDetails] = [DCMedicationScheduleDetails]()
                arr = self.displayMedicationListArray.mutableCopy() as! [DCMedicationScheduleDetails]
                arr.removeAtIndex(indexPath.row)
                self.displayMedicationListArray = (arr as? NSMutableArray)!
                
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
}

