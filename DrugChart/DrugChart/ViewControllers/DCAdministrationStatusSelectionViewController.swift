//
//  DCAdministrationStatusSelectionViewController.swift
//  DrugChart
//
//  Created by aliya on 23/02/16.
//
//

import Foundation

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
    var statusState : String?
    var medicationSlotsArray : [DCMedicationSlot] = [DCMedicationSlot]()
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate

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
        saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "saveButtonPressed")
        cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonPressed")
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
    let currentSystemDate : NSDate = DCDateUtility.dateInCurrentTimeZone(NSDate())
    let nextMedicationTimeInterval : NSTimeInterval? = (medicationSlot?.time)!.timeIntervalSinceDate(currentSystemDate)
    if (nextMedicationTimeInterval  >= 60*60) {
        // is early administration
        medicationSlot?.medicationAdministration.isEarlyAdministration = true
        //display early administration error message
    } else {
        medicationSlot?.medicationAdministration.isEarlyAdministration = false
    }
}

func checkIfFrequentAdministrationForWhenRequiredMedication () {
    
    //check if frequent administration for when required medication
    if medicationSlotsArray.count > 1 {
        let previousMedicationSlot : DCMedicationSlot? = medicationSlotsArray[medicationSlotsArray.count - 2]
        let currentSystemDate : NSDate = DCDateUtility.dateInCurrentTimeZone(NSDate())
        let nextMedicationTimeInterval : NSTimeInterval? = currentSystemDate.timeIntervalSinceDate((previousMedicationSlot?.time)!)
        if (nextMedicationTimeInterval <= 2*60*60) {
            medicationSlot?.medicationAdministration.isEarlyAdministration = true
            medicationSlot?.medicationAdministration.isWhenRequiredEarlyAdministration = true
        } else {
            medicationSlot?.medicationAdministration.isEarlyAdministration = false
            medicationSlot?.medicationAdministration.isWhenRequiredEarlyAdministration = false
        }
    } else {
        medicationSlot?.medicationAdministration.isEarlyAdministration = false
        medicationSlot?.medicationAdministration.isWhenRequiredEarlyAdministration = false
    }
    }
    
    //MARK: Logic 
    
    func updateViewWithChangeInStatus (status : String) {
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
                let presentingViewController = self.presentingViewController as! UINavigationController
                let parentView = presentingViewController.presentingViewController as! UINavigationController
                let prescriberMedicationListViewController : DCPrescriberMedicationViewController = parentView.viewControllers.last as! DCPrescriberMedicationViewController
                let administationViewController : DCAdministrationViewController = presentingViewController.viewControllers.last as! DCAdministrationViewController
                administationViewController.activityIndicatorView.startAnimating()
                self.dismissViewControllerAnimated(true, completion: {
                    self.helper.reloadPrescriberMedicationHomeViewControllerWithCompletionHandler({ (Bool) -> Void in
                        prescriberMedicationListViewController.medicationSlotArray = self.medicationSlotsArray
                        prescriberMedicationListViewController.reloadAdministrationScreenWithMedicationDetails()
                        administationViewController.activityIndicatorView.stopAnimating()
                    })
                })
            } else {
                if Int(error.code) == Int(NETWORK_NOT_REACHABLE) {
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
        self.view.bringSubviewToFront(self.activityIndicator)
        if medicationSlot?.medicationAdministration.status == NOT_ADMINISTRATED {
            self.medicationSlot = DCMedicationSlot.init()
            self.medicationSlot = administrationFailureViewController?.medicationSlot
            self.activityIndicator.startAnimating()
            self.callAdministerMedicationWebService()
        } else if medicationSlot?.medicationAdministration.status == ADMINISTERED || medicationSlot?.medicationAdministration.status == STARTED {
            self.medicationSlot = DCMedicationSlot.init()
            self.medicationSlot = administrationSuccessViewController?.medicationSlot
            self.activityIndicator.startAnimating()
            self.callAdministerMedicationWebService()
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
//        self.saveClicked = true
//        if(entriesAreValid()) {
//            self.activityIndicator.startAnimating()
//            self.isValid = true
//            self.callAdministerMedicationWebService()
//        } else {
//            // show entries in red
//            self.validateAndReloadAdministerView()
//        }
    }
    
    func setSaveButtonDisability (state : Bool) {
        self.saveButton?.enabled = state
    }
    
    func cancelButtonPressed () {
        
        self.medicationSlot?.status = nil
        medicationSlot?.medicationAdministration = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}