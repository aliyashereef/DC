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
        }
        slotToAdminister = DCUtility.getNearestMedicationSlotToBeAdministeredFromSlotsArray(medicationSlotsArray);
        
        addAdministerView()
    }
    
    func getAdministerViewErrorMessage() -> NSString {
        
        var errorMessage : String = EMPTY_STRING
        let lastMedicationSlot : DCMedicationSlot = medicationSlotsArray.last!
        let currentSystemDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
        if (lastMedicationSlot.time.compare(currentSystemDate) == NSComparisonResult.OrderedDescending) {
            errorMessage = NSLocalizedString("ADMINISTER_LATER", comment: "medication to be administered later")
        } else if (lastMedicationSlot.time.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
            errorMessage = NSLocalizedString("ALREADY_ADMINISTERED", comment: "medications are already administered")
        }
        return errorMessage
    }
    
    func addAdministerView () {
        
        //add administer view controller
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        if administerViewController == nil {
            administerViewController = administerStoryboard!.instantiateViewControllerWithIdentifier(ADMINISTER_STORYBOARD_ID) as? DCAdministerViewController
            administerViewController?.medicationSlot = slotToAdminister
            if (slotToAdminister == nil) {
                let errorMessage : String = getAdministerViewErrorMessage() as String
                administerViewController?.alertMessage = errorMessage
                NSLog("error is %@", errorMessage)
                let lastMedicationSlot : DCMedicationSlot = medicationSlotsArray.last!
                administerViewController?.medicationSlot = lastMedicationSlot
            }
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
        if medicationHistoryViewController == nil {
            medicationHistoryViewController = MedicationHistoryStoryboard!.instantiateViewControllerWithIdentifier(MEDICATION_STORYBOARD_ID) as? DCMedicationHistoryViewController
            self.addChildViewController(medicationHistoryViewController!)
            medicationHistoryViewController!.view.frame = containerView.bounds
            containerView.addSubview((medicationHistoryViewController?.view)!)
        }
        medicationHistoryViewController?.didMoveToParentViewController(self)
        containerView.bringSubviewToFront((medicationHistoryViewController?.view)!)
    }
    
    func addBNFView () {
        
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        if bnfViewController == nil {
            bnfViewController = administerStoryboard!.instantiateViewControllerWithIdentifier(BNF_STORYBOARD_ID) as? DCBNFViewController
            self.addChildViewController(bnfViewController!)
            bnfViewController!.view.frame = containerView.bounds
            containerView.addSubview((bnfViewController?.view)!)
        }
        bnfViewController?.didMoveToParentViewController(self)
        containerView.bringSubviewToFront((bnfViewController?.view)!)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate Methods
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        let presentationController : RoundRectPresentationController = RoundRectPresentationController (presentedViewController: presented, presentingViewController: presenting)
        return presentationController
    }
    
    // MARK: Action Methods
    

    @IBAction func doneButtonPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    @IBAction func segmentSelected(sender: UISegmentedControl) {
        
        //segment change
        switch sender.selectedSegmentIndex {
        case ADMINISTER_SEGMENT_INDEX :
            addAdministerView()
            containerView.sendSubviewToBack((medicationHistoryViewController?.view)!)
             break
        case MEDICATION_HISTORY_SEGMENT_INDEX :
            addMedicationHistoryView()
            containerView.sendSubviewToBack((administerViewController?.view)!)
            break
            
        case BNF_SEGMENT_INDEX :
            addBNFView()
            break
        default :
            break
        }
    }
}
