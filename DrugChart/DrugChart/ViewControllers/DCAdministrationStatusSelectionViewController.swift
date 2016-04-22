//
//  DCAdministrationStatusSelectionViewController.swift
//  DrugChart
//
//  Created by aliya on 23/02/16.
//
//

import Foundation

let INITIAL_SECTION_ROW_COUNT : NSInteger = 2
let STATUS_ROW_COUNT : NSInteger = 1
let ADMINISTERED_SECTION_ROW_COUNT : NSInteger = 4
let OMITTED_OR_REFUSED_SECTION_ROW_COUNT : NSInteger = 1
let NOTES_SECTION_ROW_COUNT : NSInteger = 1
let INITIAL_SECTION_HEIGHT : CGFloat = 0.0
let TABLEVIEW_DEFAULT_SECTION_HEIGHT : CGFloat = 20.0
let MEDICATION_DETAILS_SECTION_HEIGHT : CGFloat = 0.0
let MEDICATION_DETAILS_CELL_INDEX : NSInteger = 0
let DATE_PICKER_VIEW_CELL_HEIGHT : CGFloat = 200.0
let NOTES_CELL_HEIGHT : CGFloat = 125.0
let TABLE_CELL_DEFAULT_HEIGHT : CGFloat = 41.0
let DATE_PICKER_CELL_TAG : NSInteger = 101
let SECURITY_PIN_VIEW_ALPHA : CGFloat = 0.3
let DISPLAY_SECURITY_PIN_ENTRY : String = "displaySecurityPinEntryViewForUser:"

enum SectionCount : NSInteger {
    
    // enum for Section Count
    case eZerothSection = 0
    case eFirstSection
    case eSecondSection
    case eThirdSection
    case eFourthSection
}

enum RowCount : NSInteger {
    
    //enum for row count
    case eZerothRow = 0
    case eFirstRow
    case eSecondRow
    case eThirdRow
    case eFourthRow
}

class DCAdministrationStatusSelectionViewController: UIViewController,StatusListDelegate {
    
    @IBOutlet weak var administerStatusSelectionTableView: UITableView!
    @IBOutlet weak var administerContainerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    //MARK: Variables
    //MARK:
    var medicationSlot : DCMedicationSlot?
    var medicationDetails : DCMedicationScheduleDetails?
    var weekDate : NSDate?
    var patientId : NSString = EMPTY_STRING
    var helper : DCSwiftObjCNavigationHelper = DCSwiftObjCNavigationHelper.init()
    var statusState : String? // To store the current status state of the main parent view.
    var medicationSlotsArray : [DCMedicationSlot] = [DCMedicationSlot]()
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
    var saveClicked : Bool?
    var isValid : Bool = true

    //MARK:
    var saveButton: UIBarButtonItem?
    var cancelButton: UIBarButtonItem?
    var administrationSuccessViewController : DCAdministrationSuccessViewController?
    var administrationFailureViewController : DCAdministrationFailureViewController?
    var administrationInProgressViewController : DCAdministrationInProgressViewController?
    //MARK: View Management Methods
    //MARK:
    override func viewDidLoad() {
        self.configureViewElements()
        self.configureNavigationBar()
        self.saveButton?.enabled = false
        super.viewDidLoad()
    }
    // MARK: Private Methods
    //MARK:
    
    override func viewDidLayoutSubviews() {
        self.administerContainerView.layoutIfNeeded()
        administrationFailureViewController?.view.frame = administerContainerView.bounds
        administrationFailureViewController?.view.layoutIfNeeded()
        administrationSuccessViewController?.view.frame = administerContainerView.bounds
        administrationSuccessViewController?.view.layoutIfNeeded()
        administrationInProgressViewController?.view.frame = administerContainerView.bounds
        administrationInProgressViewController?.view.layoutIfNeeded()
        super.viewDidLayoutSubviews()
    }
    
    func configureTableViewProperties () {
        self.administerStatusSelectionTableView.rowHeight = UITableViewAutomaticDimension
        self.administerStatusSelectionTableView.estimatedRowHeight = 44.0
        self.administerStatusSelectionTableView.tableFooterView = UIView(frame: CGRectZero)
        administerStatusSelectionTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    }
    
    func configureViewElements () {
        
        configureTableViewProperties()
        initialiseMedicationSlotObject()
        //check if early administration
        if (medicationDetails?.medicineCategory == WHEN_REQUIRED) {
            checkIfFrequentAdministrationForWhenRequiredMedication()
        } else {
            if (medicationSlot?.time != nil) {
                checkIfAdministrationIsEarly()
            }
        }
    }
    
    func configureNavigationBar() {
        //Navigation bar title string
        let dateString : String
        if let date = medicationSlot?.time {
            dateString = DCDateUtility.dateStringFromDate(date, inFormat: DATE_MONTHNAME_YEAR_FORMAT)
        } else {
            dateString = DCDateUtility.dateStringFromDate(weekDate, inFormat: DATE_MONTHNAME_YEAR_FORMAT)
        }
        let slotDate = DCDateUtility.dateStringFromDate(medicationSlot!.time, inFormat: TWENTYFOUR_HOUR_FORMAT)
        self.title = "\(dateString), \(slotDate)"
        // Navigation bar done button
        // Navigation bar done button
        saveButton = UIBarButtonItem(title: SAVE_BUTTON_TITLE, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DCAdministrationStatusSelectionViewController.saveButtonPressed))
        cancelButton = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DCAdministrationStatusSelectionViewController.cancelButtonPressed))
        if (appDelegate.windowState == DCWindowState.halfWindow || appDelegate.windowState == DCWindowState.oneThirdWindow) {
            self.navigationItem.leftBarButtonItem = cancelButton
            self.navigationItem.rightBarButtonItem = saveButton
        } else {
            let negativeSpacerLeading: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
            negativeSpacerLeading.width = -12
            let negativeSpacerTrailing: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
            negativeSpacerTrailing.width = -12
            self.navigationItem.leftBarButtonItems = [negativeSpacerLeading,cancelButton!]
            self.navigationItem.rightBarButtonItems = [negativeSpacerTrailing,saveButton!]
        }
    }
    
    //MARK: TableView Delegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            return self.medicationDetailsCellAtIndexPath(indexPath)
        default:
            return self.administrationStatusTableCellAtIndexPath(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        administerStatusSelectionTableView.deselectRowAtIndexPath(indexPath, animated: true)
        administerStatusSelectionTableView.resignFirstResponder()
        if (indexPath.section == 0) {
            self.navigationController?.pushViewController(DCAdministrationHelper.addBNFView(), animated: true)
        } else {
            let statusViewController : DCAdministrationStatusTableViewController = DCAdministrationHelper.administratedStatusPopOverAtIndexPathWithStatus(indexPath, status:statusState!)
            statusViewController.previousSelectedValue = medicationSlot?.medicationAdministration?.status
            statusViewController.medicationDetails = medicationDetails
            statusViewController.medicationStatusDelegate = self
            self.navigationController!.pushViewController(statusViewController, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            return UITableViewAutomaticDimension
        default:
            return 44
        }
    }
    //MARK: Configuring Table View Cells
    
    //Medication Details Cell
    func medicationDetailsCellAtIndexPath (indexPath :NSIndexPath) -> UITableViewCell {
        
        if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationDetails!){
            let cell = administerStatusSelectionTableView.dequeueReusableCellWithIdentifier("DurationBasedInfusionCell") as? DCDurationBasedMedicationDetailsCell
            if let _ = medicationDetails {
                cell!.configureMedicationDetails(medicationDetails!)
            }
            return cell!
        } else {
            let cell = administerStatusSelectionTableView.dequeueReusableCellWithIdentifier("MedicationDetailsTableViewCell") as? DCMedicationDetailsTableViewCell
            if let _ = medicationDetails {
                cell!.configureMedicationDetails(medicationDetails!)
            }
            return cell!
        }
    }
    
    // Administration Status Cell
    func administrationStatusTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administerStatusSelectionTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.titleLabel.text = STATUS
        administerCell.detailLabel.text = EMPTY_STRING
        if statusState == IN_PROGRESS {
            updateViewWithChangeInStatus(statusState!)
        }
        return administerCell
    }
    //MARK: StatusList Delegate Methods
    
    func selectedMedicationStatusEntry(status: String!) {
        statusState = status
        self.updateViewWithChangeInStatus(status)
    }

    func initialiseMedicationSlotObject () {
        if (medicationSlot == nil) {
            medicationSlot = DCMedicationSlot.init()
        }
        if(medicationSlot?.medicationAdministration == nil) {
            medicationSlot?.medicationAdministration = DCMedicationAdministration.init()
            medicationSlot?.medicationAdministration.checkingUser = DCUser.init()
            medicationSlot?.medicationAdministration.administratingUser = DCUser.init()
            medicationSlot?.medicationAdministration.scheduledDateTime = medicationSlot?.time
        }
    }
    
    func checkIfAdministrationIsEarly () {
        
        //check if administration is early
        let currentSystemDate : NSDate = NSDate()
        let nextMedicationTimeInterval : NSTimeInterval? = (medicationSlot?.time)!.timeIntervalSinceDate(currentSystemDate)
        if (nextMedicationTimeInterval  >= ONE_HOUR) {
            // is early administration
            medicationSlot?.medicationAdministration?.isEarlyAdministration = true
            //display early administration error message
        } else {
            medicationSlot?.medicationAdministration?.isEarlyAdministration = false
        }
        //Late administration active only after 10 mins of medication time.
        let calendar = NSCalendar.currentCalendar()
        let medicationTime = calendar.dateByAddingUnit(.Minute, value: -10, toDate: currentSystemDate, options: [])
        if (medicationSlot?.time.compare(medicationTime!) == NSComparisonResult.OrderedAscending) {
            //past time, check if any medication administration is pending
            medicationSlot?.medicationAdministration?.isLateAdministration = true
        } else {
            medicationSlot?.medicationAdministration?.isLateAdministration = false
        }
    }
    
    func checkIfFrequentAdministrationForWhenRequiredMedication () {
        
    //check if frequent administration for when required medication
    if medicationSlotsArray.count > 1 {
        let previousMedicationSlot : DCMedicationSlot? = medicationSlotsArray[medicationSlotsArray.count - 2]
        let currentSystemDate : NSDate = NSDate()
        let nextMedicationTimeInterval : NSTimeInterval? = currentSystemDate.timeIntervalSinceDate((previousMedicationSlot?.time)!)
        if (nextMedicationTimeInterval <= 2*60*60) {
            medicationSlot?.medicationAdministration?.isEarlyAdministration = true
            medicationSlot?.medicationAdministration?.isWhenRequiredEarlyAdministration = true
        } else {
            medicationSlot?.medicationAdministration?.isEarlyAdministration = false
            medicationSlot?.medicationAdministration?.isWhenRequiredEarlyAdministration = false
        }
    } else {
        medicationSlot?.medicationAdministration?.isEarlyAdministration = false
        medicationSlot?.medicationAdministration?.isWhenRequiredEarlyAdministration = false
    }
    }
    
    //MARK: Logic 
    
    func updateViewWithChangeInStatus (status : String) {
        saveClicked = false
        isValid = true
        statusState = status
        switch statusState! {
        case ADMINISTERED :
            addAdministrationSuccessView ()
            break
        case STARTED :
            addAdministrationSuccessView ()
            break
        case NOT_ADMINISTRATED :
            addAdministrationFailureView ()
            break
        default :
            addInProgressStatusView ()
            self.administerStatusSelectionTableView.reloadData()
            break
        }
    }
    
    func addAdministrationSuccessView () {
        //add administer view controller
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        if administrationSuccessViewController == nil {
            administrationSuccessViewController = administerStoryboard!.instantiateViewControllerWithIdentifier(ADMINISTER_SUCCESS_VC_STORYBOARD_ID) as? DCAdministrationSuccessViewController
            
            administrationSuccessViewController?.medicationSlot = self.medicationSlot
            administrationSuccessViewController?.medicationSlot?.status = statusState
            administrationSuccessViewController?.medicationDetails = medicationDetails
            administerContainerView.addSubview((administrationSuccessViewController?.view)!)
            self.addChildViewController(administrationSuccessViewController!)
            administrationSuccessViewController!.view.frame = administerContainerView.bounds
            
        }
        administrationSuccessViewController?.isValid = self.isValid
        self.saveButton?.enabled = true
        self.view.bringSubviewToFront(administerContainerView)
        administerContainerView.bringSubviewToFront((administrationSuccessViewController?.view)!)
    }
    
    func addAdministrationFailureView () {
        //add administer view controller
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        if administrationFailureViewController == nil {
            administrationFailureViewController = administerStoryboard!.instantiateViewControllerWithIdentifier(ADMINISTER_FAILURE_VC_STORYBOARD_ID) as? DCAdministrationFailureViewController
            
            administrationFailureViewController?.medicationSlot = medicationSlot
            administrationFailureViewController?.medicationDetails = medicationDetails
            administerContainerView.addSubview((administrationFailureViewController?.view)!)
            self.addChildViewController(administrationFailureViewController!)
            administrationFailureViewController!.view.frame = administerContainerView.bounds
        }
        administrationFailureViewController?.isValid = self.isValid
        self.saveButton?.enabled = true
        self.view.bringSubviewToFront(administerContainerView)
        administerContainerView.bringSubviewToFront((administrationFailureViewController?.view)!)
    }
    
    func addInProgressStatusView () {
        //add administer view controller
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        if administrationInProgressViewController == nil {
            administrationInProgressViewController = administerStoryboard!.instantiateViewControllerWithIdentifier(ADMINISTER_IN_PROGRESS_VC_STORYBOARD_ID) as? DCAdministrationInProgressViewController
            
            administrationInProgressViewController?.medicationSlot = medicationSlot
            administrationInProgressViewController?.medicationDetails = medicationDetails
            administerContainerView.addSubview((administrationInProgressViewController?.view)!)
            self.addChildViewController(administrationInProgressViewController!)
            administrationInProgressViewController!.view.frame = administerContainerView.bounds
            
        }
        self.view.bringSubviewToFront(administerContainerView)
        administerContainerView.bringSubviewToFront((administrationInProgressViewController?.view)!)
    }
    
    func callAdministerMedicationWebService() {
        
        let administerMedicationWebService : DCAdministerMedicationWebService = DCAdministerMedicationWebService.init()
        let parameterDictionary : NSDictionary = DCAdministrationHelper.medicationAdministrationDictionaryForMedicationSlot(medicationSlot!, medicationDetails: medicationDetails!)
        administerMedicationWebService.administerMedicationForScheduleId((medicationDetails?.scheduleId)! as String, forPatientId:patientId as String , withParameters:parameterDictionary as [NSObject : AnyObject]) { (array, error) -> Void in
            self.activityIndicator.stopAnimating()
            if error == nil {
                let presentingViewController = self.presentingViewController as? UINavigationController
                let parentView = presentingViewController!.presentingViewController as! UINavigationController
                let prescriberMedicationListViewController : DCPrescriberMedicationViewController = parentView.viewControllers.last as! DCPrescriberMedicationViewController
                let administationViewController : DCAdministrationViewController = presentingViewController?.viewControllers.last as! DCAdministrationViewController
                administationViewController.activityIndicatorView.startAnimating()
                self.dismissViewControllerAnimated(true, completion: {
                    self.helper.reloadPrescriberMedicationHomeViewControllerWithCompletionHandler({ (Bool) -> Void in
                        prescriberMedicationListViewController.medicationSlotArray = self.medicationSlotsArray
                        prescriberMedicationListViewController.reloadAdministrationScreenWithMedicationDetails()
                        administationViewController.activityIndicatorView.stopAnimating()
                    })
                })
            } else {
                if ((Int(error.code) == Int(NETWORK_NOT_REACHABLE)) || (Int(error.code) == Int(NOT_CONNECTED_TO_INTERNET))) {
                    self.presentViewController(DCAdministrationHelper.displayAlertWithTitle("ERROR", message: NSLocalizedString("INTERNET_CONNECTION_ERROR", comment:"")), animated: true, completion: nil)

                } else if Int(error.code) == Int(WEBSERVICE_UNAVAILABLE)  {
                    self.presentViewController(DCAdministrationHelper.displayAlertWithTitle("ERROR", message: NSLocalizedString("WEBSERVICE_UNAVAILABLE", comment:"")), animated: true, completion: nil)
                } else {
                    self.presentViewController(DCAdministrationHelper.displayAlertWithTitle("ERROR", message:"Administration Failed"), animated: true, completion: nil)
                }
            }
        }
    }

    func saveButtonPressed () {
        //perform administer medication api call here
        self.saveClicked = true
        self.checkValidAndCallAdministerMedicationWebService()
    }
    
    func setSaveButtonDisability (state : Bool) {
        self.saveButton?.enabled = state
    }
    
    func cancelButtonPressed () {
        self.medicationSlot?.status = nil
        medicationSlot?.medicationAdministration = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkValidAndCallAdministerMedicationWebService () {
        checkAndUpdateMedicationAdministrationValidation()
        if(entriesAreValid()) {
            self.isValid = true
            if statusState == NOT_ADMINISTRATED {
                self.medicationSlot = DCMedicationSlot.init()
                administrationFailureViewController?.medicationSlot?.medicationAdministration?.status = NOT_ADMINISTRATED
                self.medicationSlot = administrationFailureViewController?.medicationSlot
            } else if statusState == ADMINISTERED || statusState == STARTED {
                self.medicationSlot = DCMedicationSlot.init()
                administrationSuccessViewController?.medicationSlot?.medicationAdministration?.status = statusState
                self.medicationSlot = administrationSuccessViewController?.medicationSlot
            } else {
                self.medicationSlot = DCMedicationSlot.init()
                self.medicationSlot = administrationInProgressViewController?.medicationSlot
            }
            self.view.bringSubviewToFront(self.activityIndicator)
            let inProgressArray = [ENDED,STOPED_DUE_TO_PROBLEM,CONTINUED_AFTER_PROBLEM,FLUID_CHANGED,PAUSED]
            if inProgressArray.contains((medicationSlot?.medicationAdministration.status)!) {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.activityIndicator.startAnimating()
                self.callAdministerMedicationWebService()
            }
        } else {

        }
    }
    
    func checkAndUpdateMedicationAdministrationValidation () {
        
        if (medicationDetails?.medicineCategory == WHEN_REQUIRED) {
            checkIfFrequentAdministrationForWhenRequiredMedication()
        } else {
            if (medicationSlot?.time != nil) {
                checkIfAdministrationIsEarly()
            }
        }
    }
    
    func entriesAreValid() -> (Bool) {
        
        isValid = true
        let medicationStatus = statusState
        //notes will be mandatory always for omitted ones , it will be mandatory for administered/refused for early administration, currently checked for all cases
        if (medicationStatus == nil) {
            isValid = false
        }
        // Status reason is a mandatory. If it is nil - is invalid
        if medicationStatus != STARTED && medicationStatus != IN_PROGRESS && (medicationSlot?.medicationAdministration?.statusReason == nil || medicationSlot?.medicationAdministration?.statusReason == EMPTY_STRING) {
            isValid = false
            if (medicationStatus == ADMINISTERED) {
                administrationSuccessViewController?.isValid = isValid
                administrationSuccessViewController?.administerSuccessTableView.reloadData()
                administrationSuccessViewController?.scrollTableViewToErrorField()
            }
            if (medicationStatus == NOT_ADMINISTRATED) {
                administrationFailureViewController?.isValid = false
                administrationFailureViewController?.administrationFailureTableView.reloadData()
                administrationFailureViewController?.scrollTableViewToErrorField()
            }
        }
        // For in progress fluid change restrted date is mandatory.
        let inProgressArray = [ENDED,STOPED_DUE_TO_PROBLEM,CONTINUED_AFTER_PROBLEM,FLUID_CHANGED,PAUSED]
        if inProgressArray.contains((medicationSlot?.medicationAdministration.status)!) {
            if (medicationSlot?.medicationAdministration.status)! == FLUID_CHANGED {
                if (medicationSlot?.medicationAdministration.restartedDate == nil || medicationSlot?.medicationAdministration.restartedDate == EMPTY_STRING) {
                    isValid = false
                    administrationInProgressViewController?.isValid = false
                    administrationInProgressViewController?.isSaveClicked = true
                    administrationInProgressViewController?.administerInProgressTableView.reloadData()
                }
            } else if (medicationSlot?.medicationAdministration.status)! == CONTINUED_AFTER_PROBLEM || (medicationSlot?.medicationAdministration.status)! == STOPED_DUE_TO_PROBLEM  {
                if (medicationSlot?.medicationAdministration.infusionStatusChangeReason == nil || medicationSlot?.medicationAdministration.infusionStatusChangeReason == EMPTY_STRING){
                    isValid = false
                    administrationInProgressViewController?.isValid = false
                    administrationInProgressViewController?.isSaveClicked = true
                    administrationInProgressViewController?.administerInProgressTableView.reloadData()
                    administrationInProgressViewController?.scrollTableViewToErrorField()
                }
            }
        }
        // For not administrated state, not administrated other should have the reason field filled.
        if (medicationStatus == NOT_ADMINISTRATED) {
            if (self.medicationSlot?.medicationAdministration?.statusReason == NOT_ADMINISTRATED_OTHERS && (self.medicationSlot?.medicationAdministration?.secondaryReason == EMPTY_STRING || self.medicationSlot?.medicationAdministration?.secondaryReason == nil)) {
                isValid = false
                administrationFailureViewController?.isValid = false
                administrationFailureViewController?.administrationFailureTableView.reloadData()
                administrationFailureViewController?.scrollTableViewToErrorField()
            }
        }
        // For late and early administration, the notes string is mandatory.
        if (self.medicationSlot?.medicationAdministration?.isLateAdministration == true || self.medicationSlot?.medicationAdministration?.isEarlyAdministration == true) {
            //early administration condition
            if (medicationStatus == ADMINISTERED || medicationStatus == STARTED) {
                //administered medication status
                let notes : String? = self.medicationSlot?.medicationAdministration?.administeredNotes
                if (notes == EMPTY_STRING || notes == nil) {
                    isValid = false
                    administrationSuccessViewController?.isValid = isValid
                    administrationSuccessViewController?.administerSuccessTableView.reloadData()
                    administrationSuccessViewController?.scrollTableViewToErrorField()
                }
            }
            if (medicationStatus == NOT_ADMINISTRATED) {
                let notes : String? = self.medicationSlot?.medicationAdministration?.refusedNotes
                if (notes == EMPTY_STRING || notes == nil) {
                    isValid = false
                    administrationFailureViewController?.isValid = false
                    administrationFailureViewController?.administrationFailureTableView.reloadData()
                    administrationFailureViewController?.scrollTableViewToErrorField()
                }
            }
        }
        if (self.medicationSlot?.medicationAdministration.isDoseUpdated == true) {
            //Dose Value updated.
            if (medicationStatus == ADMINISTERED || medicationStatus == STARTED) {
                //administered medication status.
                let reason : String? = self.medicationSlot?.medicationAdministration?.doseEditReason
                if (reason == REASON || reason == nil) {
                    isValid = false
                    administrationSuccessViewController?.isValid = isValid
                    administrationSuccessViewController?.administerSuccessTableView.reloadData()
                }
            }
        }
        return isValid
    }
}