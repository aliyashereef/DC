//
//  DCCalendarSlotDetailViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/22/15.
//
//

import UIKit

//Constants

let ADMINISTER_SEGMENT_INDEX : NSInteger = 0
let MEDICATION_HISTORY_SEGMENT_INDEX : NSInteger = 1
let BNF_SEGMENT_INDEX : NSInteger = 2
let SEGMENTED_CONTROL_FULL_WIDTH : CGFloat = 335.00
let SEGMENTED_CONTROL_ONE_THIRD_WIDTH : CGFloat = 180.00


class DCCalendarSlotDetailViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlWidth: NSLayoutConstraint?
    
    var administerViewController : DCAdministerViewController?
    var medicationHistoryViewController : DCMedicationHistoryViewController?
    var bnfViewController : DCBNFViewController?
    
    var medicationSlotsArray : [DCMedicationSlot] = [DCMedicationSlot]()
    var medicationDetails : DCMedicationScheduleDetails?
    var contentArray :[AnyObject] = []
    var slotToAdminister : DCMedicationSlot?
    var weekDate : NSDate?
    var patientId : NSString = EMPTY_STRING
    var scheduleId : NSString = EMPTY_STRING
    var errorMessage : String = EMPTY_STRING
    var helper : DCSwiftObjCNavigationHelper = DCSwiftObjCNavigationHelper.init()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureViewElements()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        self.view.layer.masksToBounds = true
        self.view.superview?.backgroundColor = UIColor.clearColor()
    }
        
    override func viewDidLayoutSubviews() {
        
        adjustSegmentedControlWidth()
        super.viewDidLayoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private Methods
    
    func configureViewElements () {
        
        self.navigationController?.navigationBarHidden = true
        if (medicationSlotsArray.count > 0) {
            initialiseMedicationSlotToAdministerObject()
            if (slotToAdminister == nil) {
                addAdministerView()
            } else {
                updateViewForValidSlotToAdminister()
            }
        } else {
            setErrorMessageForEmptyMedicationSlotArray()
            addAdministerView()
        }
        if (errorMessage != EMPTY_STRING) {
            doneButton.enabled = false
        }
     }
    
    func updateViewForValidSlotToAdminister () {
        
        let error = errorMessageForFilledMedicationSlotArray() as String?
        if (error == NSLocalizedString("ALREADY_ADMINISTERED", comment: "")) {
            if (medicationDetails?.medicineCategory != WHEN_REQUIRED) {
                segmentedControl.selectedSegmentIndex = MEDICATION_HISTORY_SEGMENT_INDEX;
                addMedicationHistoryView()
            } else {
                let currentDateString : NSString = DCDateUtility.systemDateStringInShortDisplayFormat()
                let weekDateString : NSString? = DCDateUtility.dateStringFromDate(weekDate, inFormat: SHORT_DATE_FORMAT)
                if (currentDateString == weekDateString) {
                    errorMessage = EMPTY_STRING
                    addAdministerView()
                } else {
                    segmentedControl.selectedSegmentIndex = MEDICATION_HISTORY_SEGMENT_INDEX;
                    addMedicationHistoryView()
                }
            }
        } else {
            addAdministerView()
        }
    }
    
    func adjustSegmentedControlWidth () {
        
        let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
        if (appDelegate.windowState == DCWindowState.halfWindow || appDelegate.windowState == DCWindowState.oneThirdWindow ) {
            let orientation : UIDeviceOrientation = UIDevice.currentDevice().orientation
            if UIDeviceOrientationIsLandscape(orientation) {
                if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                    segmentedControlWidth?.constant = SEGMENTED_CONTROL_FULL_WIDTH
                }
            } else {
                segmentedControlWidth?.constant = SEGMENTED_CONTROL_ONE_THIRD_WIDTH
            }
        } else if (appDelegate.windowState == DCWindowState.fullWindow || appDelegate.windowState == DCWindowState.twoThirdWindow) {
        segmentedControlWidth?.constant = SEGMENTED_CONTROL_FULL_WIDTH
        }
        self.view.layoutIfNeeded()
    }
    
    func initialiseMedicationSlotToAdministerObject () {
        
        //initialise medication slot to administer object
        slotToAdminister = DCMedicationSlot.init()
        if (medicationSlotsArray.count > 0) {
            for slot : DCMedicationSlot in medicationSlotsArray {
                if (slot.medicationAdministration?.actualAdministrationTime == nil) {
                    slotToAdminister = slot
                    break
                }
            }
        }
    }
    
    func errorMessageForFilledMedicationSlotArray() -> NSString {
        
        let currentSystemDate : NSDate = NSDate()
        let currentDateString : NSString? = DCDateUtility.dateStringFromDate(currentSystemDate, inFormat: SHORT_DATE_FORMAT)
        if (slotToAdminister?.time == nil) {
            errorMessage = NSLocalizedString("ALREADY_ADMINISTERED", comment: "medications are already administered")
        } else {
            if (slotToAdminister?.time?.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
                if (slotToAdminister?.medicationAdministration?.actualAdministrationTime != nil) {
                    errorMessage = NSLocalizedString("ALREADY_ADMINISTERED", comment: "medications are already administered")
                }
            } else if (slotToAdminister?.time?.compare(currentSystemDate) == NSComparisonResult.OrderedDescending) {
                let slotDateString : NSString? = DCDateUtility.dateStringFromDate(slotToAdminister?.time, inFormat: SHORT_DATE_FORMAT)
                if (currentDateString != slotDateString) {
                    errorMessage = NSLocalizedString("ADMINISTER_LATER", comment: "medication to be administered later")
                }
            }
        }
        return errorMessage
    }
    
    func setErrorMessageForEmptyMedicationSlotArray() -> NSString {
        
        //Whne medication slot array is empty
        if (medicationDetails?.medicineCategory == WHEN_REQUIRED) {
            let currentSystemDate : NSDate = NSDate()
            let currentDateString : NSString? = DCDateUtility.dateStringFromDate(currentSystemDate, inFormat: SHORT_DATE_FORMAT)
            let weekDateString : NSString? = DCDateUtility.dateStringFromDate(weekDate, inFormat: SHORT_DATE_FORMAT)
            if (currentDateString != weekDateString) {
                errorMessage = NSLocalizedString("NO_ADMINISTRATION_DETAILS", comment: "no medication slots today")
            }
        } else {
            errorMessage = NSLocalizedString("NO_ADMINISTRATION_DETAILS", comment: "no medication slots today")
        }
        return errorMessage
    }
    
    func addAdministerView () {
        
        //add administer view controller
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        

        showTopBarDoneButton(true)
        if administerViewController == nil {
            //administerViewController = administerStoryboard!.instantiateViewControllerWithIdentifier(ADMINISTER_STORYBOARD_ID) as? DCAdministerViewController
            administerViewController?.medicationSlot = slotToAdminister
            administerViewController?.weekDate = weekDate
            if (medicationSlotsArray.count > 0) {
                administerViewController?.medicationSlot = slotToAdminister
                var medicationArray : [DCMedicationSlot] = [DCMedicationSlot]()
                if let toAdministerArray : [DCMedicationSlot] = medicationSlotsArray {
                    var slotCount = 0
                    for slot : DCMedicationSlot in toAdministerArray {
                        if (slot.medicationAdministration?.actualAdministrationTime == nil) {
                            medicationArray.insert(slot, atIndex: slotCount)
                            slotCount++
                        }
                    }
                }
                administerViewController?.medicationSlotsArray = (medicationDetails?.medicineCategory == WHEN_REQUIRED) ? medicationSlotsArray as [DCMedicationSlot] : medicationArray as [DCMedicationSlot]
            }
            administerViewController?.medicationDetails = medicationDetails
            administerViewController?.alertMessage = errorMessage
            containerView.addSubview((administerViewController?.view)!)
            self.addChildViewController(administerViewController!)
            administerViewController!.view.frame = containerView.bounds

        }
        containerView.bringSubviewToFront((administerViewController?.view)!)
    }
    
    func addMedicationHistoryView () {
        
        //add medication History view controller
        let MedicationHistoryStoryboard : UIStoryboard? = UIStoryboard(name:MEDICATION_HISTORY, bundle: nil)
        showTopBarDoneButton(false)
        if medicationHistoryViewController == nil {
            medicationHistoryViewController = MedicationHistoryStoryboard!.instantiateViewControllerWithIdentifier(MEDICATION_STORYBOARD_ID) as? DCMedicationHistoryViewController
            medicationHistoryViewController?.weekDate = weekDate
            medicationHistoryViewController?.medicationDetails = medicationDetails
            var medicationArray : [DCMedicationSlot] = [DCMedicationSlot]()
            if let historyArray : [DCMedicationSlot] = medicationSlotsArray {
                var slotCount = 0
                for slot : DCMedicationSlot in historyArray {
                    if (slot.medicationAdministration?.status != nil && slot.medicationAdministration.actualAdministrationTime != nil) {
                        medicationArray.insert(slot, atIndex: slotCount)
                        slotCount++
                    }
                }
            }
            medicationHistoryViewController?.medicationSlotArray = medicationArray
            self.addChildViewController(medicationHistoryViewController!)
            medicationHistoryViewController!.view.frame = containerView.bounds
            containerView.addSubview((medicationHistoryViewController?.view)!)
        }
        medicationHistoryViewController?.didMoveToParentViewController(self)
        containerView.bringSubviewToFront((medicationHistoryViewController?.view)!)
    }
    
    func addBNFView () {
        
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        showTopBarDoneButton(false)
        if bnfViewController == nil {
            bnfViewController = administerStoryboard!.instantiateViewControllerWithIdentifier(BNF_STORYBOARD_ID) as? DCBNFViewController
            self.addChildViewController(bnfViewController!)
            bnfViewController!.view.frame = containerView.bounds
            containerView.addSubview((bnfViewController?.view)!)
        }
        bnfViewController?.didMoveToParentViewController(self)
        containerView.bringSubviewToFront((bnfViewController?.view)!)
    }
    
    func showTopBarDoneButton(enable : Bool) {
        
        //enable/disable top bar items
        if(enable) {
            doneButton.hidden = false
        } else {
            doneButton.hidden = true
        }
    }
    
    func entriesAreValid() -> (Bool) {
        
        // check if the values entered are valid
        var isValid : Bool = true
        let medicationStatus = administerViewController?.medicationSlot?.medicationAdministration.status
        //notes will be mandatory always for omitted ones , it will be mandatory for administered/refused for early administration, currently checked for all cases
        if (medicationStatus == OMITTED) {
            //omitted medication status
            let omittedNotes = administerViewController?.medicationSlot?.medicationAdministration.omittedNotes
            if (omittedNotes == EMPTY_STRING || omittedNotes == nil) {
                isValid = false
            }
        } else if (medicationStatus == nil) {
            isValid = false
        }
        
        if (administerViewController?.medicationSlot?.medicationAdministration?.isEarlyAdministration == true) {
            
            //early administration condition
            if (medicationStatus == ADMINISTERED) {
                //administered medication status
                let notes : String? = administerViewController?.medicationSlot?.medicationAdministration?.administeredNotes
                if (notes == EMPTY_STRING || notes == nil) {
                    isValid = false
                }
            } else if (medicationStatus == REFUSED) {
                //refused medication status
                let refusedNotes = administerViewController?.medicationSlot?.medicationAdministration.refusedNotes
                if (refusedNotes == EMPTY_STRING || refusedNotes == nil) {
                    isValid = false
                }
            }
        }
        return isValid
    }
    
    // MARK: - UIViewControllerTransitioningDelegate Methods
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        let presentationController : RoundRectPresentationController = RoundRectPresentationController (presentedViewController: presented, presentingViewController: presenting)
        return presentationController
    }
    
    // MARK: Action Methods

    @IBAction func doneButtonPressed(sender: AnyObject) {
        
        //perform administer medication api call here
        administerViewController?.saveClicked = true
        if(entriesAreValid()) {
            administerViewController?.activityIndicator.startAnimating()
            administerViewController?.isValid = true
            self.callAdministerMedicationWebService()
        } else {
            // show entries in red
            administerViewController?.validateAndReloadAdministerView()
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        administerViewController?.resetSavedAdministrationDetails()
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    @IBAction func segmentSelected(sender: UISegmentedControl) {
        
        //segment change
        switch sender.selectedSegmentIndex {
        case ADMINISTER_SEGMENT_INDEX :
            addAdministerView()
             break
        case MEDICATION_HISTORY_SEGMENT_INDEX :
            addMedicationHistoryView()
            break
            
        case BNF_SEGMENT_INDEX :
            addBNFView()
            break
        default :
            break
        }
    }
    
    //MARK: API Integration
    func medicationAdministrationDictionary() -> NSDictionary {
        
        let administerDictionary : NSMutableDictionary = [:]
        let scheduledDateString : NSString
        if (administerViewController?.medicationSlot?.medicationAdministration?.scheduledDateTime != nil) {
            scheduledDateString = DCDateUtility.dateStringFromDate(administerViewController?.medicationSlot?.medicationAdministration?.scheduledDateTime, inFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        } else {
            scheduledDateString = DCDateUtility.dateStringFromDate(NSDate(), inFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        }
        administerDictionary.setValue(scheduledDateString, forKey:SCHEDULED_ADMINISTRATION_TIME)
        let dateFormatter : NSDateFormatter = NSDateFormatter.init()
        dateFormatter.dateFormat = EMIS_DATE_FORMAT
        if (administerViewController?.medicationSlot?.medicationAdministration?.actualAdministrationTime != nil) {
            let administeredDateString : NSString = dateFormatter.stringFromDate((administerViewController?.medicationSlot?.medicationAdministration?.actualAdministrationTime)!)
            administerDictionary.setValue(administeredDateString, forKey:ACTUAL_ADMINISTRATION_TIME)
        } else {
            administerDictionary.setValue(dateFormatter.stringFromDate(NSDate()), forKey:ACTUAL_ADMINISTRATION_TIME)
        }
        administerDictionary.setValue(administerViewController?.medicationSlot?.medicationAdministration?.status, forKey: ADMINISTRATION_STATUS)
        if let administratingStatus : Bool = administerViewController?.medicationSlot?.medicationAdministration?.isSelfAdministered.boolValue {
            if administratingStatus == false {
                administerDictionary.setValue(administerViewController?.medicationSlot?.medicationAdministration?.administratingUser!.userIdentifier, forKey:"AdministratingUserIdentifier")
            }
            administerDictionary.setValue(administratingStatus, forKey: IS_SELF_ADMINISTERED)
        }
        //TO DO : Configure the dosage and batch number from the form.
        if let dosage = self.medicationDetails?.dosage {
            administerDictionary.setValue(dosage, forKey: ADMINISTRATING_DOSAGE)
        }
        if let batch = administerViewController?.medicationSlot?.medicationAdministration?.batch {
            administerDictionary.setValue(batch, forKey: ADMINISTRATING_BATCH)
        }
        let notes : NSString  = administrationNotesBasedOnMedicationStatus ((administerViewController?.medicationSlot?.medicationAdministration?.status)!)
        administerDictionary.setValue(notes, forKey:ADMINISTRATING_NOTES)
        
        //TODO: currently hardcoded as ther is no expiry field in UI
       // administerDictionary.setValue("2015-10-23T19:40:00.000Z", forKey: EXPIRY_DATE)
        return administerDictionary
    }
    
    func callAdministerMedicationWebService() {
    
        let administerMedicationWebService : DCAdministerMedicationWebService = DCAdministerMedicationWebService.init()
        let parameterDictionary : NSDictionary = medicationAdministrationDictionary()
        administerMedicationWebService.administerMedicationForScheduleId(scheduleId as String, forPatientId:patientId as String , withParameters:parameterDictionary as [NSObject : AnyObject]) { (array, error) -> Void in
            self.administerViewController?.activityIndicator.stopAnimating()
            if error == nil {
                self.dismissViewControllerAnimated(true, completion: nil)
                self.helper.reloadPrescriberMedicationHomeViewControllerWithCompletionHandler({ (success) -> Void in
                    
                })
            } else {
                if Int(error.code) == Int(NETWORK_NOT_REACHABLE) {
                    self.displayAlertWithTitle("ERROR", message: NSLocalizedString("INTERNET_CONNECTION_ERROR", comment:""))
                } else if Int(error.code) == Int(WEBSERVICE_UNAVAILABLE)  {
                    self.displayAlertWithTitle("ERROR", message: NSLocalizedString("WEBSERVICE_UNAVAILABLE", comment:""))
                } else {
                    self.displayAlertWithTitle("ERROR", message:"Administration Failed")
                }
            }
        }
    }
            
    func displayAlertWithTitle(title : NSString, message : NSString ) {
    //display alert view for view controllers
        let alertController : UIAlertController = UIAlertController(title: title as String, message: message as String, preferredStyle: UIAlertControllerStyle.Alert)
        let action : UIAlertAction = UIAlertAction(title: OK_BUTTON_TITLE, style: UIAlertActionStyle.Default, handler: { action in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(action)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Return the note string based on the administrating status
    func administrationNotesBasedOnMedicationStatus (status : NSString) -> NSString{
        var noteString : NSString = EMPTY_STRING
        if (status == ADMINISTERED || status == SELF_ADMINISTERED)  {
            if let administeredNotes = administerViewController?.medicationSlot?.medicationAdministration?.administeredNotes {
                noteString = administeredNotes
            }
        } else if status == REFUSED {
            if let refusedNotes = administerViewController?.medicationSlot?.medicationAdministration?.refusedNotes {
                noteString =  refusedNotes
            }
        } else {
            if let omittedNotes = administerViewController?.medicationSlot?.medicationAdministration?.omittedNotes {
                noteString = omittedNotes
            }
        }
        return noteString
    }

}
