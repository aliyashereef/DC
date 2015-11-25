//
//  DCOneThirdCalendarScreenMedicationCell.swift
//  DrugChart
//
//  Created by aliya on 17/11/15.
//
//

import Foundation

class DCOneThirdCalendarScreenMedicationCell: UITableViewCell {
    
    @IBOutlet weak var medicineDetailHolderView: UIView!
    @IBOutlet weak var medicineName: UILabel!
    @IBOutlet weak var route: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    var isMedicationActive : Bool = true
    var inEditMode : Bool = false

    @IBOutlet weak var adminstrationStatusView: UIView!
    @IBOutlet weak var medicationViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stopButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var editButtonWidth: NSLayoutConstraint!
    override func awakeFromNib() {
        
        super.awakeFromNib()
        addPanGestureToMedicationDetailHolderView()
    }
    
    // MARK: Private Methods
    
    func addPanGestureToMedicationDetailHolderView () {
        
        //add pan gesture to medication detail holder view
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("swipeMedicationDetailView:"))
        medicineDetailHolderView.addGestureRecognizer(panGesture)
    }
    
    // MARK: Action Methods
    
    func swipeMedicationDetailView(panGesture : UIPanGestureRecognizer) {
        
        //swipe medication view
        if isMedicationActive {
            let translate : CGPoint = panGesture.translationInView(self.contentView)
            let gestureVelocity : CGPoint = panGesture.velocityInView(self)
            if (gestureVelocity.x > 200.0 || gestureVelocity.x < -200.0) {
                if ((translate.x < 0) && (medicationViewLeadingConstraint.constant == 0)) { // left swipe
                    UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                        self.medicationViewLeadingConstraint.constant = -MEDICATION_VIEW_LEFT_OFFSET
                        self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                        self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                        self.editButton.setTitle(EDIT_TEXT, forState: UIControlState.Normal)
                        self.stopButton.setTitle(STOP_TEXT, forState: UIControlState.Normal)
                        self.layoutIfNeeded()
                    })
                } else if ((translate.x > 0) && (self.medicationViewLeadingConstraint.constant == -MEDICATION_VIEW_LEFT_OFFSET)){ //right pan  when edit view is fully visible
                    UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                        self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                        self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                        self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                        self.layoutIfNeeded()
                    })
                } else{
                    if (((translate.x < 0) && (self.medicationViewLeadingConstraint.constant > -MEDICATION_VIEW_LEFT_OFFSET)) || ((translate.x > 0) && (self.medicationViewLeadingConstraint.constant < MEDICATION_VIEW_INITIAL_LEFT_OFFSET))) {
                        //in process of tramslation
                        dispatch_async(dispatch_get_main_queue(), {
                            self.medicationViewLeadingConstraint.constant += (gestureVelocity.x / 25.0)
                            self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                            self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                            self.setEditViewButtonNames()
                            self.setMedicationViewFrame()
                        })
                    }
                }
            }
            
            if (panGesture.state == UIGestureRecognizerState.Ended) {
                //All fingers are lifted.
                adjustMedicationDetailViewOnPanGestureEndWithTranslationPoint(translate)
            }
        }
    }
    
    func swipeMedicationDetailViewToRight() {
        
        //swipe gesture - right when completion of edit/delete action
        inEditMode = false
        UIView.animateWithDuration(ANIMATION_DURATION) { () -> Void in
            self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET;
            self.layoutIfNeeded()
        }
    }
    func setEditViewButtonNames() {
        
        if (self.editButtonWidth.constant > 40.0) {
            self.editButton.setTitle(EDIT_TEXT, forState: UIControlState.Normal)
            self.stopButton.setTitle(STOP_TEXT, forState: UIControlState.Normal)
        } else {
            self.editButton.setTitle("", forState: UIControlState.Normal)
            self.stopButton.setTitle("", forState: UIControlState.Normal)
        }
    }
    
    func setMedicationViewFrame() {
        
        if (self.medicationViewLeadingConstraint.constant < -MEDICATION_VIEW_LEFT_OFFSET) {
            self.medicationViewLeadingConstraint.constant = -MEDICATION_VIEW_LEFT_OFFSET;
        } else if (self.medicationViewLeadingConstraint.constant > MEDICATION_VIEW_INITIAL_LEFT_OFFSET) {
            self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET;
        }
        inEditMode = true
    }
    
    func adjustMedicationDetailViewOnPanGestureEndWithTranslationPoint(translate : CGPoint) {
        
        //gesture ended
        if ((translate.x < 0) && self.medicationViewLeadingConstraint.constant < (-MEDICATION_VIEW_LEFT_OFFSET / 2)) {
            UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                self.medicationViewLeadingConstraint.constant = -MEDICATION_VIEW_LEFT_OFFSET
                self.layoutIfNeeded()
                }, completion: { finished in
                    self.setMedicationViewFrame()
            })
        } else if ((translate.x < 0) && self.medicationViewLeadingConstraint.constant > (-MEDICATION_VIEW_LEFT_OFFSET / 2)) {
            UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET + 10
                self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setMedicationViewFrame()
            })
        } else if ((translate.x > 0) && self.medicationViewLeadingConstraint.constant > (-MEDICATION_VIEW_LEFT_OFFSET / 2)){
            UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
                self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setMedicationViewFrame()
            })
        } else if ((translate.x > 0) && self.medicationViewLeadingConstraint.constant < (-MEDICATION_VIEW_LEFT_OFFSET / 2)){
            UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
                self.medicationViewLeadingConstraint.constant = -MEDICATION_VIEW_LEFT_OFFSET;
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setMedicationViewFrame()
            })
        }
        UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
            self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
            self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
            }, completion: { (finished) -> Void in
                self.setMedicationViewFrame()
        })
    }


}