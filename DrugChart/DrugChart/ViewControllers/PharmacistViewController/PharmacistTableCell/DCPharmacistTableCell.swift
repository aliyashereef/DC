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

let ACTION_BUTTON_COUNT : CGFloat = 3
let ACTION_BUTTON_COUNT_WITH_EDIT : CGFloat = 4

let ACTION_BUTTONS_DEFAULT_TOTAL_WIDTH_WITH_EDIT : CGFloat = 500.0
let ACTION_BUTTONS_ONE_THIRD_TOTAL_WIDTH_WITH_EDIT : CGFloat = 292.0

let PAN_VELOCITY_TRIGGER_LIMIT : CGFloat = 100.0

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
    func editInterventionActionOnTableCellAtIndexPath(indexPath : NSIndexPath)
}

class DCPharmacistTableCell: UITableViewCell {

    @IBOutlet weak var medicationNameLabel: UILabel!
    @IBOutlet weak var routeAndInstructionsLabel: UILabel!
    @IBOutlet weak var frequencyDescriptionLabel: UILabel!
    @IBOutlet weak var firstStatusImageView: UIImageView!
    @IBOutlet weak var secondStatusImageView: UIImageView!
    @IBOutlet weak var thirdStatusImageView: UIImageView!
    @IBOutlet weak var medicationDetailsView: UIView!
    @IBOutlet weak var pharmacistDetailsViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pharmacistDetailsViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var podStatusButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var podStatusButton: UIButton!
    @IBOutlet weak var resolveInterventionButton: UIButton!
    @IBOutlet weak var editInterventionButton: UIButton!
    @IBOutlet weak var clinicalCheckButton: UIButton!
    @IBOutlet weak var resolveInterventionButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var editInterventionButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var clinicalButtonWidth: NSLayoutConstraint!
    
    var medicationDetails : DCMedicationScheduleDetails?
    var pharmacistCellDelegate : PharmacistCellDelegate?
    
    var indexPath : NSIndexPath?
    var actionButtonsTotalWidth : CGFloat = ACTION_BUTTONS_DEFAULT_TOTAL_WIDTH
    var actionButtonWidth : CGFloat = ACTION_BUTTON_DEFAULT_WIDTH
    var buttonCount : CGFloat = ACTION_BUTTON_COUNT
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
    var isTableViewScrolling : Bool? = false
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        //configureCellElements()
        self.addPanGestureToMedicationDetailsView()
        self.addPharmacistTableViewScrollNotification()
    }

    override func layoutSubviews() {

        super.layoutSubviews()
        self.calculateActionButtonWidthAndCount()
        if (self.pharmacistDetailsViewLeadingConstraint.constant != 0) {
            self.pharmacistDetailsViewLeadingConstraint.constant = -actionButtonsTotalWidth
            self.pharmacistDetailsViewTrailingConstraint.constant = actionButtonsTotalWidth
        }
        if let tableView : UITableView = self.superview?.superview as? UITableView {
            //donot allow tableviewcell show the underlying buttons in editing mode
            if tableView.editing == true {
                configurePharmacistButtonState(true)
            }
        }
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
        configureEditInterventionButton()
        calculateActionButtonWidthAndCount()
    }
    
    func configureClinicalCheckButton() {
        
        clinicalCheckButton.titleLabel?.textAlignment = NSTextAlignment.Center
        if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow) {
            clinicalCheckButton.titleLabel?.font = PHARMACIST_ONE_THIRD_FONT
        } else {
            clinicalCheckButton.titleLabel?.font = PHARMACIST_DEFAULT_FONT
        }
        clinicalButtonWidth?.constant = actionButtonWidth
        //on cell selection background buttons were visible. Inorder to fix this initialy clinical check, resolve intervention, update pod status button titles are set to nil
        if pharmacistDetailsViewLeadingConstraint.constant == 0 {
            clinicalCheckButton.setTitle(EMPTY_STRING, forState: UIControlState.Normal)
        }
    }
    
    func configureResolveInterventionButton() {
        
        //set the properties of intervention button
        resolveInterventionButton.titleLabel?.textAlignment = NSTextAlignment.Center
        if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow) {
            resolveInterventionButton.titleLabel?.font = PHARMACIST_ONE_THIRD_FONT
        } else {
            resolveInterventionButton.titleLabel?.font = PHARMACIST_DEFAULT_FONT
        }
        resolveInterventionButtonWidth?.constant = actionButtonWidth
        if pharmacistDetailsViewLeadingConstraint.constant == 0 {
            resolveInterventionButton.setTitle(EMPTY_STRING, forState: UIControlState.Normal)
        }
    }
    
    func configurePODStatusButton() {
        
        podStatusButton.titleLabel?.textAlignment = NSTextAlignment.Center
        if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow) {
            podStatusButton.titleLabel?.font = PHARMACIST_ONE_THIRD_FONT
        } else {
            podStatusButton.titleLabel?.font = PHARMACIST_DEFAULT_FONT
        }
        podStatusButtonWidth?.constant = actionButtonWidth
        if pharmacistDetailsViewLeadingConstraint.constant == 0 {
            podStatusButton.setTitle(EMPTY_STRING, forState: UIControlState.Normal)
        }
    }
    
    func configureEditInterventionButton() {
        //set the properties of intervention button
        editInterventionButton.titleLabel?.textAlignment = NSTextAlignment.Center
        if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow) {
            editInterventionButton.titleLabel?.font = PHARMACIST_ONE_THIRD_FONT
            
        } else {
            editInterventionButton.titleLabel?.font = PHARMACIST_DEFAULT_FONT
        }
        editInterventionButtonWidth?.constant = actionButtonWidth
        if pharmacistDetailsViewLeadingConstraint.constant == 0 {
            editInterventionButton.setTitle(EMPTY_STRING, forState: UIControlState.Normal)
        }
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
                updateStatusIconsForClinicallyRemovedMedicationsWithPharmacistAction(pharmacistAction)
            } else {
                //clinical verified
                if let intervention = medicationDetails?.pharmacistAction?.intervention {
                    updateStatusIconsForClinicallyVerifiedMedicationsWithIntervention(intervention)
                }
            }
        } else {
            initialisePharmacistObject()
        }
    }
    
    func updateStatusIconsForClinicallyRemovedMedicationsWithPharmacistAction(pharmacistAction : DCPharmacistAction) {
        
        //firstimageview will display cli
        firstStatusImageView.image = UIImage(named: CLINICAL_CHECK_IPAD_IMAGE)
        if let intervention = pharmacistAction.intervention {
            if (intervention.toResolve == true) {
                //first image is intervention image
                secondStatusImageView.image = UIImage(named: INTERVENTION_IPAD_IMAGE)
                if let podStatus = pharmacistAction.podStatus {
                    thirdStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
                } else {
                    thirdStatusImageView.image = nil
                }
            } else {
                //pod status
                if let podStatus = pharmacistAction.podStatus {
                    secondStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
                } else {
                    secondStatusImageView.image = nil
                }
                thirdStatusImageView.image = nil
            }
        } else {
            // display pod status
            if let podStatus = pharmacistAction.podStatus {
                secondStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
            } else {
                secondStatusImageView.image = nil
            }
            thirdStatusImageView.image = nil
        }
    }
    
    func updateStatusIconsForClinicallyVerifiedMedicationsWithIntervention(intervention : DCIntervention) {
        
        //if intervention is added, first imageview should display intervention icon. if pod status is updated,
        // second image view will show corresponding status image
        if (intervention.toResolve == true) {
            //first image is intervention image
            firstStatusImageView.image = UIImage(named: INTERVENTION_IPAD_IMAGE)
            if let podStatus = medicationDetails?.pharmacistAction?.podStatus {
                secondStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
            } else {
                secondStatusImageView.image = nil
            }
            thirdStatusImageView.image = nil
        } else {
            if let podStatus = medicationDetails?.pharmacistAction?.podStatus {
                firstStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
            } else {
                firstStatusImageView.image = nil
            }
            secondStatusImageView.image = nil
            thirdStatusImageView.image = nil
        }
    }
    
    func initialisePharmacistObject() {
        
        //initialise pharmacist object
        medicationDetails?.pharmacistAction = DCPharmacistAction.init()
        medicationDetails?.pharmacistAction.clinicalCheck = false
        firstStatusImageView?.image = UIImage(named: CLINICAL_CHECK_IPAD_IMAGE)
        medicationDetails?.pharmacistAction?.intervention = DCIntervention.init()
        medicationDetails?.pharmacistAction?.intervention?.toResolve = false
        medicationDetails?.pharmacistAction?.podStatus = DCPODStatus.init()
        medicationDetails?.pharmacistAction?.podStatus?.podStatusType = eNoStatus
    }
    
    func addPanGestureToMedicationDetailsView() {
        
        // add swipe gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(DCPharmacistTableCell.swipeMedicationDetailView(_:)))
        panGesture.delegate = self
        medicationDetailsView.addGestureRecognizer(panGesture)
    }
    
    func swipeMedicationDetailView(panGesture : UIPanGestureRecognizer) {
        
        let tableView : UITableView = (self.superview?.superview as? UITableView)!
        //donot allow tableviewcell swipe when tableview is in editing mode
        if tableView.editing == false && isTableViewScrolling == false {
            configurePharmacistButtonState(false)
            let translate : CGPoint = panGesture.translationInView(self.contentView)
            let gestureVelocity : CGPoint = panGesture.velocityInView(self)
            if (gestureVelocity.x > PAN_VELOCITY_TRIGGER_LIMIT || gestureVelocity.x < -PAN_VELOCITY_TRIGGER_LIMIT) {
                if ((translate.x < 0) && (pharmacistDetailsViewLeadingConstraint.constant == 0)) { // left swipe
                    UIView.animateWithDuration(0.5, animations: {
                        self.pharmacistDetailsViewLeadingConstraint.constant = -self.actionButtonsTotalWidth
                        self.pharmacistDetailsViewTrailingConstraint.constant = self.actionButtonsTotalWidth
                        self.updateActionButtonWidthRespectiveToLeadingConstraint()
                        self.setClinicalCheckButtonTitle()
                        self.setPharmacistInterventionButtonTitle()
                        self.podStatusButton.setTitle(UPDATE_POD_STATUS, forState: UIControlState.Normal)
                        self.layoutIfNeeded()
                    })
                    if let delegate = pharmacistCellDelegate {
                        delegate.swipeActionOnTableCellAtIndexPath(indexPath!)
                    }
                } else if ((translate.x > 0) && (self.pharmacistDetailsViewLeadingConstraint.constant == -actionButtonsTotalWidth)){ //right pan  when edit view is fully visible
                    UIView.animateWithDuration(0.5, animations: {
                        self.pharmacistDetailsViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                        self.pharmacistDetailsViewTrailingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                        self.updateActionButtonWidthRespectiveToLeadingConstraint()
                        self.setPrescriberButtonNames()
                        self.layoutIfNeeded()
                    })
                    if let delegate = pharmacistCellDelegate {
                        delegate.swipeActionOnTableCellAtIndexPath(indexPath!)
                    }
                } else{
                    if (((translate.x < 0) && (self.pharmacistDetailsViewLeadingConstraint.constant > -actionButtonsTotalWidth)) || ((translate.x > 0) && (self.pharmacistDetailsViewLeadingConstraint.constant < MEDICATION_VIEW_INITIAL_LEFT_OFFSET))) {
                        //in process of tramslation
                        dispatch_async(dispatch_get_main_queue(), {
                            self.pharmacistDetailsViewLeadingConstraint.constant += (gestureVelocity.x / 25.0)
                            self.pharmacistDetailsViewTrailingConstraint.constant -= (gestureVelocity.x / 25.0)
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
   }
    
    func swipePrescriberDetailViewToRight() {
        
        //swipe gesture - right when completion of edit/delete action
        UIView.animateWithDuration(0.5) { () -> Void in
            self.pharmacistDetailsViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
            self.pharmacistDetailsViewTrailingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
            self.layoutIfNeeded()
        }
    }
    
    func setClinicalCheckButtonTitle() {
        
        if medicationDetails?.pharmacistAction?.clinicalCheck == false {
            clinicalCheckButton.setTitle(CLINICAL_CHECK, forState: UIControlState.Normal)
        } else {
            clinicalCheckButton.setTitle(CLINICAL_REMOVE, forState: UIControlState.Normal)
        }
    }
    
    func calculateActionButtonWidthAndCount() {
        
        if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow) {
            
            actionButtonWidth = ACTION_BUTTON_ONE_THIRD_WIDTH
            if medicationDetails?.pharmacistAction?.intervention?.toResolve == false {
                editInterventionButtonWidth.constant = 0.0
                self.actionButtonsTotalWidth = ACTION_BUTTONS_ONE_THIRD_TOTAL_WIDTH
                buttonCount = ACTION_BUTTON_COUNT
            } else {
                editInterventionButtonWidth.constant = actionButtonWidth
                self.actionButtonsTotalWidth = ACTION_BUTTONS_ONE_THIRD_TOTAL_WIDTH_WITH_EDIT
                buttonCount = ACTION_BUTTON_COUNT_WITH_EDIT
            }
        } else {
            actionButtonWidth = ACTION_BUTTON_DEFAULT_WIDTH
            if medicationDetails?.pharmacistAction?.intervention?.toResolve == false {
                editInterventionButtonWidth.constant = 0.0
                self.actionButtonsTotalWidth = ACTION_BUTTONS_DEFAULT_TOTAL_WIDTH
                buttonCount = ACTION_BUTTON_COUNT
            } else {
                editInterventionButtonWidth.constant = actionButtonWidth
                self.actionButtonsTotalWidth = ACTION_BUTTONS_DEFAULT_TOTAL_WIDTH_WITH_EDIT
                buttonCount = ACTION_BUTTON_COUNT_WITH_EDIT
            }
        }
    }
    
    func setPharmacistInterventionButtonTitle() {
        
        if medicationDetails?.pharmacistAction?.intervention?.toResolve == false {
            // intervention not added yet or added intervention has been resolved
            resolveInterventionButton.setTitle(ADD_INTERVENTION, forState: .Normal)
            editInterventionButton.setTitle(EMPTY_STRING, forState: .Normal)
            editInterventionButtonWidth.constant = 0.0
        } else {
            resolveInterventionButton.setTitle(RESOLVE_INTERVENTION, forState: .Normal)
            editInterventionButton.setTitle(EDIT_INTERVENTION, forState: .Normal)
            editInterventionButtonWidth.constant = actionButtonWidth
        }
    }
    
    func setPrescriberButtonNames() {
        
        if (self.podStatusButtonWidth.constant > actionButtonWidth) {
            self.podStatusButton.setTitle(UPDATE_POD_STATUS, forState: .Normal)
            self.setClinicalCheckButtonTitle()
            self.setPharmacistInterventionButtonTitle()
        } else {
            self.podStatusButton.setTitle(EMPTY_STRING, forState: .Normal)
            self.resolveInterventionButton.setTitle(EMPTY_STRING, forState: .Normal)
            self.clinicalCheckButton.setTitle(EMPTY_STRING, forState: .Normal)
            self.editInterventionButton.setTitle(EMPTY_STRING, forState: .Normal)
        }
    }
    
    func configurePharmacistButtonState(hidden : Bool ) {
        self.editInterventionButton.hidden = hidden
        self.clinicalCheckButton.hidden = hidden
        self.resolveInterventionButton.hidden = hidden
        self.podStatusButton.hidden = hidden
    }
    
    func setPrescriberDetailsViewFrame() {
        
        if (self.pharmacistDetailsViewLeadingConstraint.constant < -actionButtonsTotalWidth) {
            self.pharmacistDetailsViewLeadingConstraint.constant = -actionButtonsTotalWidth
            self.pharmacistDetailsViewTrailingConstraint.constant = actionButtonsTotalWidth
        } else if (self.pharmacistDetailsViewLeadingConstraint.constant > MEDICATION_VIEW_INITIAL_LEFT_OFFSET) {
            self.pharmacistDetailsViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
            self.pharmacistDetailsViewTrailingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
        }
    }

    
    func adjustMedicationDetailViewOnPanGestureEndWithTranslationPoint(translate : CGPoint) {
        
        //gesture ended
        if ((translate.x < 0) && self.pharmacistDetailsViewLeadingConstraint.constant < (-actionButtonsTotalWidth / buttonCount)) {
            UIView.animateWithDuration(0.5, animations: {
                self.pharmacistDetailsViewLeadingConstraint.constant = -self.actionButtonsTotalWidth
                self.layoutIfNeeded()
                }, completion: { finished in
                    self.setPrescriberDetailsViewFrame()
            })
        } else if ((translate.x < 0) && self.pharmacistDetailsViewLeadingConstraint.constant > (-actionButtonsTotalWidth / buttonCount)) {
            UIView.animateWithDuration(0.5, animations: {
                self.pharmacistDetailsViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET + 10
                self.updateActionButtonWidthRespectiveToLeadingConstraint()
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setPrescriberDetailsViewFrame()
            })
        } else if ((translate.x > 0) && self.pharmacistDetailsViewLeadingConstraint.constant > (-actionButtonsTotalWidth / buttonCount)) {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.pharmacistDetailsViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                self.updateActionButtonWidthRespectiveToLeadingConstraint()
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setPrescriberDetailsViewFrame()
            })
        } else if ((translate.x > 0) && self.pharmacistDetailsViewLeadingConstraint.constant < (-actionButtonsTotalWidth / buttonCount)){
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.pharmacistDetailsViewLeadingConstraint.constant = -self.actionButtonsTotalWidth;
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setPrescriberDetailsViewFrame()
            })
        }
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.updateActionButtonWidthRespectiveToLeadingConstraint()
            }, completion: { (finished) -> Void in
                self.setPrescriberDetailsViewFrame()
        })
    }
    
    func updateActionButtonWidthRespectiveToLeadingConstraint() {
        
        //set action buttons width
        self.podStatusButtonWidth.constant = -(self.pharmacistDetailsViewLeadingConstraint.constant / buttonCount)
        self.clinicalButtonWidth.constant = -(self.pharmacistDetailsViewLeadingConstraint.constant / buttonCount)
        self.resolveInterventionButtonWidth.constant = -(self.pharmacistDetailsViewLeadingConstraint.constant / buttonCount)
        if medicationDetails?.pharmacistAction?.intervention?.toResolve == true {
            self.editInterventionButtonWidth.constant = -(self.pharmacistDetailsViewLeadingConstraint.constant / buttonCount)
        } else {
            self.editInterventionButtonWidth.constant = 0.0
        }
    }
    
    func addPharmacistTableViewScrollNotification() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DCPharmacistTableCell.pharmacistTableViewIsScrolling(_:)), name: kPharmacistTableViewScrollNotification, object: nil)
    }
    
    func pharmacistTableViewIsScrolling(notification : NSNotification) {
        
        let scrolling : Bool = notification.userInfo![IS_SCROLLING] as! Bool
        isTableViewScrolling = scrolling
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
        
        swipePrescriberDetailViewToRight()
        if let delegate = pharmacistCellDelegate {
            delegate.clinicalCheckActionOnTableCellAtIndexPath(indexPath!)
        }
    }
    
    @IBAction func editInterventionButtonAction(sender: AnyObject) {
        
        swipePrescriberDetailViewToRight()
        if let delegate = pharmacistCellDelegate {
            delegate.editInterventionActionOnTableCellAtIndexPath(indexPath!)
        }
    }
    
    
    // MARK: Gesture Delegate Methods
    
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
