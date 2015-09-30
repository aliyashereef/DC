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

class DCCalendarSlotDetailViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    var administerViewController : DCAdministerViewController?
    var medicationHistoryViewController : DCMedicationHistoryViewController?
    var bnfViewController : DCBNFViewController?
    
    var medicationSlotsArray : [DCMedicationSlot] = []
    var medicationDetails : DCMedicationScheduleDetails?
    var contentArray :[AnyObject] = []
    var slotToAdminister : DCMedicationSlot?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureViewElements()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        self.view.layer.masksToBounds = true
        self.view.superview?.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Private Methods
    
    func configureViewElements () {
        
        self.navigationController?.navigationBarHidden = true
        for medicationSlot : DCMedicationSlot in medicationSlotsArray {
            NSLog("time is %@", medicationSlot.time)
            slotToAdminister = medicationSlot;
            break;
        }
       // slotToAdminister = DCUtility.getNearestMedicationSlotToBeAdministeredFromSlotsArray(medicationSlotsArray);
        
        addAdministerView()
    }
    
    func getAdministerViewErrorMessage() -> NSString {
        
        let errorMessage : String = EMPTY_STRING
//        let lastMedicationSlot : DCMedicationSlot = medicationSlotsArray.last!
//        let currentSystemDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
//        if (lastMedicationSlot.time.compare(currentSystemDate) == NSComparisonResult.OrderedDescending) {
//            errorMessage = NSLocalizedString("ADMINISTER_LATER", comment: "medication to be administered later")
//        } else if (lastMedicationSlot.time.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
//            errorMessage = NSLocalizedString("ALREADY_ADMINISTERED", comment: "medications are already administered")
//        }
        return errorMessage
    }
    
    func addAdministerView () {
        
        //add administer view controller
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        showTopBarDoneButton(true)
        if administerViewController == nil {
            administerViewController = administerStoryboard!.instantiateViewControllerWithIdentifier(ADMINISTER_STORYBOARD_ID) as? DCAdministerViewController
            administerViewController?.medicationSlot = slotToAdminister
//            if (slotToAdminister == nil) {
//                let errorMessage : String = getAdministerViewErrorMessage() as String
//                administerViewController?.alertMessage = errorMessage
//                NSLog("error is %@", errorMessage)
//                let lastMedicationSlot : DCMedicationSlot = medicationSlotsArray.last!
//                administerViewController?.medicationSlot = lastMedicationSlot
//            }
            administerViewController?.medicationDetails = medicationDetails
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
            medicationHistoryViewController?.medicationDetails = medicationDetails
            medicationHistoryViewController?.medicationSlotArray = medicationSlotsArray
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
        NSLog("Medication Slot Status: %@", (administerViewController?.medicationSlot?.status)!)
        NSLog("Medication Status : %@", (administerViewController?.medicationSlot?.medicationAdministration.status)!)
        let medicationStatus = administerViewController?.medicationSlot?.medicationAdministration.status
        if (medicationStatus == ADMINISTERED) {
            //administered medication status
            let notes = administerViewController?.medicationSlot?.medicationAdministration.administeredNotes
            if (notes == EMPTY_STRING || notes == nil) {
                isValid = false
            }
        } else if (medicationStatus == REFUSED) {
            //refused medication status
            let refusedNotes = administerViewController?.medicationSlot?.medicationAdministration.refusedNotes
            if (refusedNotes == EMPTY_STRING || refusedNotes == nil) {
                isValid = false
            }
        } else {
            //omitted medication status
            let omittedNotes = administerViewController?.medicationSlot?.medicationAdministration.omittedNotes
            if (omittedNotes == EMPTY_STRING || omittedNotes == nil) {
                isValid = false
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
            self.dismissViewControllerAnimated(true) { () -> Void in
                
            }
        } else {
            // show entries in red
            print("******* Error in Validation ********")
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
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
