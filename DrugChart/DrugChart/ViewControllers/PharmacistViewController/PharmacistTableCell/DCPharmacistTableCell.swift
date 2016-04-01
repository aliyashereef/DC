//
//  DCPharmacistTableCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/29/16.
//
//

import UIKit

let ACTION_BUTTONS_TOTAL_WIDTH : CGFloat = 375.0
let PAN_VELOCITY_TRIGGER_LIMIT : CGFloat = 200.0
let ACTION_BUTTON_MINIMUM_WIDTH : CGFloat = 150.0

protocol PharmacistCellDelegate {
    
    func swipeActionOnTableCellAtIndexPath(indexPath : NSIndexPath)
}

class DCPharmacistTableCell: UITableViewCell {

    @IBOutlet weak var medicationNameLabel: UILabel!
    @IBOutlet weak var routeAndInstructionsLabel: UILabel!
    @IBOutlet weak var frequencyDescriptionLabel: UILabel!
    @IBOutlet weak var firstStatusImageView: UIImageView!
    @IBOutlet weak var secondStatusImageView: UIImageView!
    @IBOutlet weak var thirdStatusImageView: UIImageView!
    @IBOutlet weak var medicationDetailsView: UIView!
    @IBOutlet weak var prescriberDetailsView: UIView!
    @IBOutlet weak var prescriberDetailsViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var prescriberDetailsViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var podStatusButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var podStatusButton: UIButton!
    @IBOutlet weak var resolveInterventionButton: UIButton!
    @IBOutlet weak var clinicalCheckButton: UIButton!
    
    var medicationDetails : DCMedicationScheduleDetails?
    var pharmacistCellDelegate : PharmacistCellDelegate?
    
    var indexPath : NSIndexPath?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        podStatusButton.titleLabel?.textAlignment = NSTextAlignment.Center
        resolveInterventionButton.titleLabel?.textAlignment = NSTextAlignment.Center
        clinicalCheckButton.titleLabel?.textAlignment = NSTextAlignment.Center
        self.addPanGestureToMedicationDetailsView()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillMedicationDetailsInTableCell(medicationSchedule : DCMedicationScheduleDetails) {
        
        //populate medication details
        medicationDetails = medicationSchedule
        medicationNameLabel.text = medicationSchedule.name
        self.populateRouteAndInstructionLabel(medicationSchedule)
        self.updatePharmacistStatusInCell()
    }
        
    func populateRouteAndInstructionLabel(medicationDetails : DCMedicationScheduleDetails?) {
        
        let route : String = medicationDetails!.route.stringByReplacingOccurrencesOfString(" ", withString: EMPTY_STRING)
        let attributedRouteString : NSMutableAttributedString = NSMutableAttributedString(string: route, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(16.0)])
        let attributedInstructionsString : NSMutableAttributedString
        let instructionString : String
        if (medicationDetails?.instruction != EMPTY_STRING && medicationDetails?.instruction != nil) {
            instructionString = String(format: " (%@)", (medicationDetails?.instruction)!)
        } else {
            instructionString = EMPTY_STRING
        }
        attributedInstructionsString  = NSMutableAttributedString(string: instructionString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12.0)])
        attributedRouteString.appendAttributedString(attributedInstructionsString)
        routeAndInstructionsLabel.attributedText = attributedRouteString;
    }
    
    func updatePharmacistStatusInCell() {
        
        if let pharmacistAction = medicationDetails?.pharmacistAction {
            print("****** Pharamacist ACtion ******")
            //display logic
            if pharmacistAction.clinicalCheck == false {
                //display clinical check icon since pharamcist has not verified medication yet
                firstStatusImageView.image = UIImage(named: CLINICAL_CHECK_IPAD_IMAGE)
                if let _ = pharmacistAction.intervention {
                    // medication has added intervention, second icon will have pod images
                    if let podStatus = pharmacistAction.podStatus {
                        secondStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
                    }
                } else {
                    secondStatusImageView.image = UIImage(named: INTERVENTION_IPAD_IMAGE)
                }
            }
        } else {
            medicationDetails?.pharmacistAction = DCPharmacistAction.init()
            medicationDetails?.pharmacistAction.clinicalCheck = false
            medicationDetails?.pharmacistAction?.intervention = DCIntervention.init()
            medicationDetails?.pharmacistAction?.podStatus = DCPODStatus.init()
        }
    }
    
    func addPanGestureToMedicationDetailsView() {
        
        // add swipe gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("swipeMedicationDetailView:"))
        panGesture.delegate = self
        medicationDetailsView.addGestureRecognizer(panGesture)
    }
    
    func swipeMedicationDetailView(panGesture : UIPanGestureRecognizer) {
        
        let translate : CGPoint = panGesture.translationInView(self.contentView)
        let gestureVelocity : CGPoint = panGesture.velocityInView(self)
        if (gestureVelocity.x > PAN_VELOCITY_TRIGGER_LIMIT || gestureVelocity.x < -PAN_VELOCITY_TRIGGER_LIMIT) {
            if ((translate.x < 0) && (prescriberDetailsViewLeadingConstraint.constant == 0)) { // left swipe
                UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                    self.prescriberDetailsViewLeadingConstraint.constant = -ACTION_BUTTONS_TOTAL_WIDTH
                    self.prescriberDetailsViewTrailingConstraint.constant = ACTION_BUTTONS_TOTAL_WIDTH
                    self.podStatusButtonWidth.constant = -(self.prescriberDetailsViewLeadingConstraint.constant / 2)
                    self.podStatusButton.setTitle(UPDATE_POD_STATUS, forState: UIControlState.Normal)
                    self.resolveInterventionButton.setTitle(RESOLVE_INTERVENTION, forState: UIControlState.Normal)
                    self.clinicalCheckButton.setTitle(CLINICAL_CHECK, forState: UIControlState.Normal)
                    self.layoutIfNeeded()
                })
                if let delegate = pharmacistCellDelegate {
                    delegate.swipeActionOnTableCellAtIndexPath(indexPath!)
                }
            } else if ((translate.x > 0) && (self.prescriberDetailsViewLeadingConstraint.constant == -ACTION_BUTTONS_TOTAL_WIDTH)){ //right pan  when edit view is fully visible
                UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                    self.prescriberDetailsViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                    self.prescriberDetailsViewTrailingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                    self.podStatusButtonWidth.constant = -(self.prescriberDetailsViewLeadingConstraint.constant / 2)
                    self.layoutIfNeeded()
                })
                if let delegate = pharmacistCellDelegate {
                    delegate.swipeActionOnTableCellAtIndexPath(indexPath!)
                }
            } else{
                if (((translate.x < 0) && (self.prescriberDetailsViewLeadingConstraint.constant > -ACTION_BUTTONS_TOTAL_WIDTH)) || ((translate.x > 0) && (self.prescriberDetailsViewLeadingConstraint.constant < MEDICATION_VIEW_INITIAL_LEFT_OFFSET))) {
                    //in process of tramslation
                    dispatch_async(dispatch_get_main_queue(), {
                        self.prescriberDetailsViewLeadingConstraint.constant += (gestureVelocity.x / 25.0)
                        self.prescriberDetailsViewTrailingConstraint.constant -= (gestureVelocity.x / 25.0)
                        self.podStatusButtonWidth.constant = -(self.prescriberDetailsViewLeadingConstraint.constant / 2)
                        self.setPrescriberButtonNames()
                        self.setPrescriberDetailsViewFrame()
                    })
                    if let delegate = pharmacistCellDelegate {
                        delegate.swipeActionOnTableCellAtIndexPath(indexPath!)
                    }
                }
            }
        }
        if (panGesture.state == UIGestureRecognizerState.Ended) {
            //pan ended
            adjustMedicationDetailViewOnPanGestureEndWithTranslationPoint(translate)
        }
   }
    
    func swipePrescriberDetailViewToRight() {
        
        //swipe gesture - right when completion of edit/delete action
        UIView.animateWithDuration(ANIMATION_DURATION) { () -> Void in
            self.prescriberDetailsViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
            self.prescriberDetailsViewTrailingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
            self.layoutIfNeeded()
        }
    }
    
    func setPrescriberButtonNames() {
        
        if (self.podStatusButtonWidth.constant > ACTION_BUTTON_MINIMUM_WIDTH) {
            self.podStatusButton.setTitle(UPDATE_POD_STATUS, forState: UIControlState.Normal)
            self.resolveInterventionButton.setTitle(RESOLVE_INTERVENTION, forState: UIControlState.Normal)
            self.clinicalCheckButton.setTitle(CLINICAL_CHECK, forState: .Normal)
        } else {
            self.podStatusButton.setTitle(EMPTY_STRING, forState: UIControlState.Normal)
            self.resolveInterventionButton.setTitle(EMPTY_STRING, forState: UIControlState.Normal)
            self.clinicalCheckButton.setTitle(EMPTY_STRING, forState: .Normal)
        }
    }
    
    func setPrescriberDetailsViewFrame() {
        
        if (self.prescriberDetailsViewLeadingConstraint.constant < -ACTION_BUTTONS_TOTAL_WIDTH) {
            self.prescriberDetailsViewLeadingConstraint.constant = -ACTION_BUTTONS_TOTAL_WIDTH
            self.prescriberDetailsViewTrailingConstraint.constant = ACTION_BUTTONS_TOTAL_WIDTH
        } else if (self.prescriberDetailsViewLeadingConstraint.constant > MEDICATION_VIEW_INITIAL_LEFT_OFFSET) {
            self.prescriberDetailsViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
            self.prescriberDetailsViewTrailingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
        }
    }

    
    func adjustMedicationDetailViewOnPanGestureEndWithTranslationPoint(translate : CGPoint) {
        
        //gesture ended
        if ((translate.x < 0) && self.prescriberDetailsViewLeadingConstraint.constant < (-ACTION_BUTTONS_TOTAL_WIDTH / 2)) {
            UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                self.prescriberDetailsViewLeadingConstraint.constant = -ACTION_BUTTONS_TOTAL_WIDTH
                self.layoutIfNeeded()
                }, completion: { finished in
                    self.setPrescriberDetailsViewFrame()
            })
        } else if ((translate.x < 0) && self.prescriberDetailsViewLeadingConstraint.constant > (-ACTION_BUTTONS_TOTAL_WIDTH / 2)) {
            UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                self.prescriberDetailsViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET + 10
                self.podStatusButtonWidth.constant = -(self.prescriberDetailsViewLeadingConstraint.constant / 2)
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setPrescriberDetailsViewFrame()
            })
        } else if ((translate.x > 0) && self.prescriberDetailsViewLeadingConstraint.constant > (-ACTION_BUTTONS_TOTAL_WIDTH / 2)) {
            UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
                self.prescriberDetailsViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                self.podStatusButtonWidth.constant = -(self.prescriberDetailsViewLeadingConstraint.constant / 2)
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setPrescriberDetailsViewFrame()
            })
        } else if ((translate.x > 0) && self.prescriberDetailsViewLeadingConstraint.constant < (-ACTION_BUTTONS_TOTAL_WIDTH / 2)){
            UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
                self.prescriberDetailsViewLeadingConstraint.constant = -ACTION_BUTTONS_TOTAL_WIDTH;
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setPrescriberDetailsViewFrame()
            })
        }
        UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
            self.podStatusButtonWidth.constant = -(self.prescriberDetailsViewLeadingConstraint.constant / 2)
            }, completion: { (finished) -> Void in
                self.setPrescriberDetailsViewFrame()
        })
    }
    
    // MARK : Action Methods
    
    @IBAction func podStatusButtonAction(sender: AnyObject) {
        
        swipePrescriberDetailViewToRight()
    }
    
    @IBAction func resolveInterventionButtonAction(sender: AnyObject) {
        
        swipePrescriberDetailViewToRight()
    }
    
    @IBAction func clinicalCheckButtonAction(sender: AnyObject) {
        
        swipePrescriberDetailViewToRight()
    }
    
   override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    
        if (gestureRecognizer.isKindOfClass(UIPanGestureRecognizer)) {
            let panGesture = gestureRecognizer as? UIPanGestureRecognizer
            let translation : CGPoint = panGesture!.translationInView(panGesture?.view);
            if (fabs(translation.x) > fabs(translation.y)) {
                return false
            }
        }
        return true
    }
    

}
