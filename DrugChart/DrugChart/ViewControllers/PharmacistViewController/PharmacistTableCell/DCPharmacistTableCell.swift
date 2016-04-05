//
//  DCPharmacistTableCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/29/16.
//
//

import UIKit

let ACTION_BUTTONS_DEFAULT_TOTAL_WIDTH : CGFloat = 375.0
let ACTION_BUTTON_DEFAULT_WIDTH : CGFloat = 125.0
let ACTION_BUTTONS_ONE_THIRD_TOTAL_WIDTH : CGFloat = 219.0
let ACTION_BUTTON_ONE_THIRD_WIDTH : CGFloat = 73.0
let PAN_VELOCITY_TRIGGER_LIMIT : CGFloat = 200.0

let PHARMACIST_ONE_THIRD_FONT = UIFont.systemFontOfSize(11.0)
let PHARMACIST_DEFAULT_FONT = UIFont.systemFontOfSize(14.0)
let MEDICINE_NAME_DEFAULT_FONT = UIFont.systemFontOfSize(18.0)
let MEDICINE_NAME_ONE_THIRD_FONT = UIFont.systemFontOfSize(15.0)
let ROUTE_DEFAULT_FONT = UIFont.systemFontOfSize(16.0)
let ROUTE_ONE_THIRD_FONT = UIFont.systemFontOfSize(14.0)
let INSTRUCTIONS_FONT = UIFont.systemFontOfSize(12.0)
let FREQUENCY_DEFUALT_FONT = UIFont.systemFontOfSize(12.0)
let FREQUENCY_ONE_THIRD_FONT = UIFont.systemFontOfSize(10.0)


protocol PharmacistCellDelegate {
    
    func swipeActionOnTableCellAtIndexPath(indexPath : NSIndexPath)
    func podStatusActionOnTableCellAtIndexPath(indexPath : NSIndexPath)
    func clinicalCheckActionOnTableCellAtIndexPath(indexPath : NSIndexPath)
    func resolveInterventionActionOnTableCellAtIndexPath(indexPath : NSIndexPath)
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
    @IBOutlet weak var resolveInterventionButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var clinicalButtonWidth: NSLayoutConstraint!
    
    var medicationDetails : DCMedicationScheduleDetails?
    var pharmacistCellDelegate : PharmacistCellDelegate?
    
    var indexPath : NSIndexPath?
    var actionButtonsTotalWidth : CGFloat = ACTION_BUTTONS_DEFAULT_TOTAL_WIDTH
    var actionButtonWidth : CGFloat = ACTION_BUTTON_DEFAULT_WIDTH
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        configureCellElements()
        self.addPanGestureToMedicationDetailsView()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    func configureCellElements() {
        
        if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow) {
            actionButtonsTotalWidth = ACTION_BUTTONS_ONE_THIRD_TOTAL_WIDTH
            actionButtonWidth = ACTION_BUTTON_ONE_THIRD_WIDTH
        } else {
            actionButtonsTotalWidth = ACTION_BUTTONS_DEFAULT_TOTAL_WIDTH
            actionButtonWidth = ACTION_BUTTON_DEFAULT_WIDTH
        }
        configureClinicalCheckButton()
        configureResolveInterventionButton()
        configurePODStatusButton()
    }
    
    func configureClinicalCheckButton() {
        
        clinicalCheckButton.titleLabel?.textAlignment = NSTextAlignment.Center
        if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow) {
            clinicalCheckButton.titleLabel?.font = PHARMACIST_ONE_THIRD_FONT
        } else {
            clinicalCheckButton.titleLabel?.font = PHARMACIST_DEFAULT_FONT
        }
        clinicalButtonWidth?.constant = actionButtonWidth
       setClinicalCheckButtonTitle()
    }
    
    func configureResolveInterventionButton() {
        
        resolveInterventionButton.titleLabel?.textAlignment = NSTextAlignment.Center
        if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow) {
            resolveInterventionButton.titleLabel?.font = PHARMACIST_ONE_THIRD_FONT
        } else {
            resolveInterventionButton.titleLabel?.font = PHARMACIST_DEFAULT_FONT
        }
        resolveInterventionButtonWidth?.constant = actionButtonWidth
        setPharmacistInterventionButtonTitle()
    }
    
    func configurePODStatusButton() {
        
        podStatusButton.titleLabel?.textAlignment = NSTextAlignment.Center
        if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow) {
            podStatusButton.titleLabel?.font = PHARMACIST_ONE_THIRD_FONT
            
        } else {
            podStatusButton.titleLabel?.font = PHARMACIST_DEFAULT_FONT
        }
        podStatusButtonWidth?.constant = actionButtonWidth
    }
    
    func fillMedicationDetailsInTableCell(medicationSchedule : DCMedicationScheduleDetails) {
        
        //populate medication details
        medicationDetails = medicationSchedule
        if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow) {
            medicationNameLabel.font = MEDICINE_NAME_ONE_THIRD_FONT
        } else {
            medicationNameLabel.font = MEDICINE_NAME_DEFAULT_FONT
        }
        medicationNameLabel.text = medicationSchedule.name
        self.populateRouteAndInstructionLabel(medicationSchedule)
        self.populateFrequencyCountLabel()
        self.updatePharmacistStatusInCell()
    }
    
    func populateRouteAndInstructionLabel(medicationDetails : DCMedicationScheduleDetails?) {
        
        let route : String = medicationDetails!.route.stringByReplacingOccurrencesOfString(" ", withString: EMPTY_STRING)
        var routeAttributes = [:]
        if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow) {
            routeAttributes = [NSFontAttributeName : ROUTE_ONE_THIRD_FONT]
        } else {
            routeAttributes = [NSFontAttributeName : ROUTE_DEFAULT_FONT]
        }
        let attributedRouteString : NSMutableAttributedString = NSMutableAttributedString(string: route, attributes: routeAttributes as? [String : AnyObject])
        let attributedInstructionsString : NSMutableAttributedString
        let instructionString : String
        if (medicationDetails?.instruction != EMPTY_STRING && medicationDetails?.instruction != nil) {
            instructionString = String(format: " (%@)", (medicationDetails?.instruction)!)
        } else {
            instructionString = EMPTY_STRING
        }
        attributedInstructionsString  = NSMutableAttributedString(string: instructionString, attributes: [NSFontAttributeName : INSTRUCTIONS_FONT])
        attributedRouteString.appendAttributedString(attributedInstructionsString)
        routeAndInstructionsLabel.attributedText = attributedRouteString;
    }
    
    func populateFrequencyCountLabel() {
        
        frequencyDescriptionLabel.text = DCCalendarHelper.typeDescriptionForMedication(medicationDetails!)
    }
    
    func updatePharmacistStatusInCell() {
        
        if let pharmacistAction = medicationDetails?.pharmacistAction {
            //display logic
            if pharmacistAction.clinicalCheck == false {
                //display clinical check icon since pharamcist has not verified medication yet
                firstStatusImageView.image = UIImage(named: CLINICAL_CHECK_IPAD_IMAGE)
                if let intervention = pharmacistAction.intervention {
                    if (intervention.reason != nil && intervention.resolution == nil) {
                        //first image is intervention image
                        secondStatusImageView.image = UIImage(named: INTERVENTION_IPAD_IMAGE)
                        if let podStatus = pharmacistAction.podStatus {
                            thirdStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
                        }
                    } else {
                        //pod status
                        if let podStatus = pharmacistAction.podStatus {
                            secondStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
                        }
                    }
                } else {
                    // display pod status
                    if let podStatus = pharmacistAction.podStatus {
                        secondStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
                    }
                }
            } else {
                //clinical verified
                if let intervention = pharmacistAction.intervention {
                    if (intervention.reason != nil && intervention.resolution == nil) {
                        //first image is intervention image
                        firstStatusImageView.image = UIImage(named: INTERVENTION_IPAD_IMAGE)
                        if let podStatus = pharmacistAction.podStatus {
                            secondStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
                        }
                    } else {
                        if let podStatus = pharmacistAction.podStatus {
                            firstStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
                        }
                    }
                }
            }
        } else {
            initialisePharmacistObject()
        }
    }
    
    func initialisePharmacistObject() {
        
        //initialise pharmacist object
        medicationDetails?.pharmacistAction = DCPharmacistAction.init()
        medicationDetails?.pharmacistAction.clinicalCheck = false
        firstStatusImageView?.image = UIImage(named: CLINICAL_CHECK_IPAD_IMAGE)
        medicationDetails?.pharmacistAction?.intervention = DCIntervention.init()
        medicationDetails?.pharmacistAction?.podStatus = DCPODStatus.init()
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
                    self.prescriberDetailsViewLeadingConstraint.constant = -self.actionButtonsTotalWidth
                    self.prescriberDetailsViewTrailingConstraint.constant = self.actionButtonsTotalWidth
                    self.updateActionButtonWidthRespectiveToLeadingConstraint()
                    self.setClinicalCheckButtonTitle()
                    self.setPharmacistInterventionButtonTitle()
                    self.podStatusButton.setTitle(UPDATE_POD_STATUS, forState: UIControlState.Normal)
                    self.layoutIfNeeded()
                })
                if let delegate = pharmacistCellDelegate {
                    delegate.swipeActionOnTableCellAtIndexPath(indexPath!)
                }
            } else if ((translate.x > 0) && (self.prescriberDetailsViewLeadingConstraint.constant == -actionButtonsTotalWidth)){ //right pan  when edit view is fully visible
                UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                    self.prescriberDetailsViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                    self.prescriberDetailsViewTrailingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                    self.updateActionButtonWidthRespectiveToLeadingConstraint()
                    self.layoutIfNeeded()
                })
                if let delegate = pharmacistCellDelegate {
                    delegate.swipeActionOnTableCellAtIndexPath(indexPath!)
                }
            } else{
                if (((translate.x < 0) && (self.prescriberDetailsViewLeadingConstraint.constant > -actionButtonsTotalWidth)) || ((translate.x > 0) && (self.prescriberDetailsViewLeadingConstraint.constant < MEDICATION_VIEW_INITIAL_LEFT_OFFSET))) {
                    //in process of tramslation
                    dispatch_async(dispatch_get_main_queue(), {
                        self.prescriberDetailsViewLeadingConstraint.constant += (gestureVelocity.x / 25.0)
                        self.prescriberDetailsViewTrailingConstraint.constant -= (gestureVelocity.x / 25.0)
                        self.updateActionButtonWidthRespectiveToLeadingConstraint()
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
    
    func setClinicalCheckButtonTitle() {
        
        if medicationDetails?.pharmacistAction?.clinicalCheck == false {
            clinicalCheckButton.titleLabel?.text = CLINICAL_CHECK
        } else {
            clinicalCheckButton.titleLabel?.text = CLINICAL_REMOVE
        }
    }
    
    func setPharmacistInterventionButtonTitle() {
        
        if (medicationDetails?.pharmacistAction?.intervention?.reason == nil || medicationDetails?.pharmacistAction?.intervention?.resolution != nil) {
            // intervention not added yet or added intervention has been resolved
            resolveInterventionButton.setTitle(ADD_INTERVENTION, forState: .Normal)
        } else {
            resolveInterventionButton.setTitle(RESOLVE_INTERVENTION, forState: .Normal)
        }
    }
    
    func setPrescriberButtonNames() {
        
        if (self.podStatusButtonWidth.constant > actionButtonWidth) {
            self.podStatusButton.setTitle(UPDATE_POD_STATUS, forState: UIControlState.Normal)
            self.setClinicalCheckButtonTitle()
            self.setPharmacistInterventionButtonTitle()
        } else {
            self.podStatusButton.setTitle(EMPTY_STRING, forState: UIControlState.Normal)
            self.resolveInterventionButton.setTitle(EMPTY_STRING, forState: UIControlState.Normal)
            self.clinicalCheckButton.setTitle(EMPTY_STRING, forState: .Normal)
        }
    }
    
    func setPrescriberDetailsViewFrame() {
        
        if (self.prescriberDetailsViewLeadingConstraint.constant < -actionButtonsTotalWidth) {
            self.prescriberDetailsViewLeadingConstraint.constant = -actionButtonsTotalWidth
            self.prescriberDetailsViewTrailingConstraint.constant = actionButtonsTotalWidth
        } else if (self.prescriberDetailsViewLeadingConstraint.constant > MEDICATION_VIEW_INITIAL_LEFT_OFFSET) {
            self.prescriberDetailsViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
            self.prescriberDetailsViewTrailingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
        }
    }

    
    func adjustMedicationDetailViewOnPanGestureEndWithTranslationPoint(translate : CGPoint) {
        
        //gesture ended
        if ((translate.x < 0) && self.prescriberDetailsViewLeadingConstraint.constant < (-actionButtonsTotalWidth / 3)) {
            UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                self.prescriberDetailsViewLeadingConstraint.constant = -self.actionButtonsTotalWidth
                self.layoutIfNeeded()
                }, completion: { finished in
                    self.setPrescriberDetailsViewFrame()
            })
        } else if ((translate.x < 0) && self.prescriberDetailsViewLeadingConstraint.constant > (-actionButtonsTotalWidth / 3)) {
            UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                self.prescriberDetailsViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET + 10
                self.updateActionButtonWidthRespectiveToLeadingConstraint()
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setPrescriberDetailsViewFrame()
            })
        } else if ((translate.x > 0) && self.prescriberDetailsViewLeadingConstraint.constant > (-actionButtonsTotalWidth / 3)) {
            UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
                self.prescriberDetailsViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                self.updateActionButtonWidthRespectiveToLeadingConstraint()
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setPrescriberDetailsViewFrame()
            })
        } else if ((translate.x > 0) && self.prescriberDetailsViewLeadingConstraint.constant < (-actionButtonsTotalWidth / 3)){
            UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
                self.prescriberDetailsViewLeadingConstraint.constant = -self.actionButtonsTotalWidth;
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setPrescriberDetailsViewFrame()
            })
        }
        UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
            self.updateActionButtonWidthRespectiveToLeadingConstraint()
            }, completion: { (finished) -> Void in
                self.setPrescriberDetailsViewFrame()
        })
    }
    
    func updateActionButtonWidthRespectiveToLeadingConstraint() {
        
        //set action buttons width
        self.podStatusButtonWidth.constant = -(self.prescriberDetailsViewLeadingConstraint.constant / 3)
        self.clinicalButtonWidth.constant = -(self.prescriberDetailsViewLeadingConstraint.constant / 3)
        self.resolveInterventionButtonWidth.constant = -(self.prescriberDetailsViewLeadingConstraint.constant / 3)
    }
    
    
    // MARK: Action Methods
    
    @IBAction func podStatusButtonAction(sender: AnyObject) {
        
        swipePrescriberDetailViewToRight()
        if let delegate = pharmacistCellDelegate {
            delegate.podStatusActionOnTableCellAtIndexPath(indexPath!)
        }
    }
    
    @IBAction func resolveInterventionButtonAction(sender: AnyObject) {
        
        if let delegate = pharmacistCellDelegate {
            delegate.resolveInterventionActionOnTableCellAtIndexPath(indexPath!)
        }
        swipePrescriberDetailViewToRight()
    }
    
    @IBAction func clinicalCheckButtonAction(sender: AnyObject) {
        
        if let delegate = pharmacistCellDelegate {
            delegate.clinicalCheckActionOnTableCellAtIndexPath(indexPath!)
        }
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
