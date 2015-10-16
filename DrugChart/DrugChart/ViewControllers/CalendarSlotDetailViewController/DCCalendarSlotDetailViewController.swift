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
    
    var medicationSlotsArray : [DCMedicationSlot] = []
    var medicationDetails : DCMedicationScheduleDetails?
    var contentArray :[AnyObject] = []
    var slotToAdminister : DCMedicationSlot?
    var weekDate : NSDate?
    var errorMessage : String = EMPTY_STRING
    
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
            let error = getAdministerViewErrorMessage() as String?
            if (slotToAdminister == nil) {
                addAdministerView()
            } else {
                if (error == NSLocalizedString("ALREADY_ADMINISTERED", comment: "")) {
                    segmentedControl.selectedSegmentIndex = MEDICATION_HISTORY_SEGMENT_INDEX;
                    addMedicationHistoryView()
                } else {
                    addAdministerView()
                }
            }
        }
     }
    
    func adjustSegmentedControlWidth () {
        
        let windowWidth : CGFloat = DCUtility.getMainWindowSize().width
        let screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
        if (windowWidth < screenWidth/3) {
            segmentedControlWidth?.constant = SEGMENTED_CONTROL_ONE_THIRD_WIDTH
//            let attr = NSDictionary(object: UIFont(name: "HelveticaNeue", size: 9.5)!, forKey: NSFontAttributeName)
//            segmentedControl.setTitleTextAttributes(attr as [NSObject : AnyObject], forState: .Normal)
        } else {
            segmentedControlWidth?.constant = SEGMENTED_CONTROL_FULL_WIDTH
//            //let attr = NSDictionary(object: UIFont(name: "HelveticaNeue", size: 14)!, forKey: NSFontAttributeName)
//            segmentedControl.setTitleTextAttributes(attr as [NSObject : AnyObject], forState: .Normal)
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
    
    func getAdministerViewErrorMessage() -> NSString {
        
        if (medicationSlotsArray.count == 0) {
            errorMessage = NSLocalizedString("NO_ADMINISTRATION_TODAY", comment: "no medication slots today")
        } else {
            let currentSystemDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
            if (slotToAdminister?.time == nil) {
                errorMessage = NSLocalizedString("ALREADY_ADMINISTERED", comment: "medications are already administered")
            } else {
                if (slotToAdminister?.time?.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
                    if (slotToAdminister?.medicationAdministration?.actualAdministrationTime != nil) {
                        errorMessage = NSLocalizedString("ALREADY_ADMINISTERED", comment: "medications are already administered")
                    }
                } else if (slotToAdminister?.time?.compare(currentSystemDate) == NSComparisonResult.OrderedDescending) {
                    let currentDateString : NSString? = DCDateUtility.convertDate(currentSystemDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: SHORT_DATE_FORMAT)
                    let slotDateString : NSString? = DCDateUtility.convertDate(slotToAdminister?.time, fromFormat: DEFAULT_DATE_FORMAT, toFormat: SHORT_DATE_FORMAT)
                    if (currentDateString != slotDateString) {
                        errorMessage = NSLocalizedString("ADMINISTER_LATER", comment: "medication to be administered later")
                    }
                }
            }
        }
         return errorMessage
    }
    
    func addAdministerView () {
        
        //add administer view controller
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        showTopBarDoneButton(true)
        if administerViewController == nil {
            administerViewController = administerStoryboard!.instantiateViewControllerWithIdentifier(ADMINISTER_STORYBOARD_ID) as? DCAdministerViewController
            administerViewController?.medicationSlot = slotToAdminister
            administerViewController?.weekDate = weekDate
            if (medicationSlotsArray.count > 0) {
                administerViewController?.medicationSlot = slotToAdminister
                administerViewController?.alertMessage = errorMessage
//                if (slotToAdminister?.medicationAdministration?.actualAdministrationTime == nil) {
//                    doneButton.enabled = false
//                }
            }
            administerViewController?.medicationDetails = medicationDetails
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
            administerViewController?.medicationSlotsArray = medicationArray
            self.addChildViewController(administerViewController!)
            administerViewController!.view.frame = containerView.bounds
            containerView.addSubview((administerViewController?.view)!)
        }
        administerViewController?.didMoveToParentViewController(self)
        containerView.bringSubviewToFront((administerViewController?.view)!)
    }
    
    func addMedicationHistoryView () {
        
        //add medication History view controller
        let MedicationHistoryStoryboard : UIStoryboard? = UIStoryboard(name:MEDICATION_HISTORY, bundle: nil)
        showTopBarDoneButton(false)
        if medicationHistoryViewController == nil {
            medicationHistoryViewController = MedicationHistoryStoryboard!.instantiateViewControllerWithIdentifier(MEDICATION_STORYBOARD_ID) as? DCMedicationHistoryViewController
            medicationHistoryViewController?.medicationSlot = slotToAdminister
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
        
        if(entriesAreValid()) {
            administerViewController?.isValid = true
            self.dismissViewControllerAnimated(true) { () -> Void in
            }
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
}
