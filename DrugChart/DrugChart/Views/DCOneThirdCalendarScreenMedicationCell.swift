//
//  DCOneThirdCalendarScreenMedicationCell.swift
//  DrugChart
//
//  Created by aliya on 17/11/15.
//
//

import Foundation

protocol EditDeleteActionDelegate {
    
    func stopMedicationForSelectedIndexPath(indexPath : NSIndexPath)
    func editMedicationForSelectedIndexPath (indexPath : NSIndexPath)
    func setIndexPathSelected(indexPath : NSIndexPath)
    func transitToSummaryScreenForMedication(indexpath : NSIndexPath)
    func moreButtonSelectedForIndexPath(indexPath: NSIndexPath)
}

class DCOneThirdCalendarScreenMedicationCell: UITableViewCell {
    
    @IBOutlet weak var medicineDetailHolderView: UIView!
    @IBOutlet weak var medicineName: UILabel!
    @IBOutlet weak var route: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var adminstrationStatusView: UIView!
    @IBOutlet weak var medicationViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var stopButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var editButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var moreButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var editButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var stopButtonHeight: NSLayoutConstraint!
    
    var isMedicationActive : Bool = true
    var inEditMode : Bool = false
    var indexPath : NSIndexPath!
    var editAndDeleteDelegate : EditDeleteActionDelegate?

    override func awakeFromNib() {
        
        super.awakeFromNib()
        addPanGestureToMedicationDetailHolderView()
    }
    
    override func layoutSubviews() {
        
        editButtonHeight.constant = self.frame.height
        stopButtonHeight.constant = self.frame.height
        super.layoutSubviews()
    }
    
    // MARK: Private Methods
    
    func addPanGestureToMedicationDetailHolderView () {
        
        //add pan gesture to medication detail holder view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(DCOneThirdCalendarScreenMedicationCell.swipeMedicationDetailView(_:)))
        panGesture.delegate = self
        medicineDetailHolderView.addGestureRecognizer(panGesture)
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: Action Methods
    
    func swipeMedicationDetailView(panGesture : UIPanGestureRecognizer) {
        
        //swipe medication view
        if isMedicationActive {
            if let delegate = editAndDeleteDelegate {
                delegate.setIndexPathSelected(indexPath)
            }

            let translate : CGPoint = panGesture.translationInView(self.contentView)
            let gestureVelocity : CGPoint = panGesture.velocityInView(self)
            if (gestureVelocity.x > 300.0 || gestureVelocity.x < -300.0) {
                if ((translate.x < 0) && (medicationViewLeadingConstraint.constant == 0)) { // left swipe
                    UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                        self.medicationViewLeadingConstraint.constant = -MEDICATION_VIEW_LEFT_OFFSET
                        self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                        self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                        self.moreButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                        self.editButton.setTitle(EDIT_TEXT, forState: UIControlState.Normal)
                        self.stopButton.setTitle(STOP_TEXT, forState: UIControlState.Normal)
                        self.moreButton.setTitle(MORE_TEXT, forState: UIControlState.Normal)
                        self.layoutIfNeeded()
                    })
                } else if ((translate.x > 0) && (self.medicationViewLeadingConstraint.constant == -MEDICATION_VIEW_LEFT_OFFSET)){ //right pan  when edit view is fully visible
                    UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                        self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                        self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                        self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                        self.moreButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                        self.layoutIfNeeded()
                    })
                } else{
                    if (((translate.x < 0) && (self.medicationViewLeadingConstraint.constant > -MEDICATION_VIEW_LEFT_OFFSET)) || ((translate.x > 0) && (self.medicationViewLeadingConstraint.constant < MEDICATION_VIEW_INITIAL_LEFT_OFFSET))) {
                        //in process of tramslation
                        dispatch_async(dispatch_get_main_queue(), {
                            self.medicationViewLeadingConstraint.constant += (gestureVelocity.x / 25.0)
                            self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                            self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                            self.moreButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
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
            self.moreButton.setTitle(MORE_TEXT, forState: UIControlState.Normal)
        } else {
            self.editButton.setTitle(EMPTY_STRING, forState: UIControlState.Normal)
            self.stopButton.setTitle(EMPTY_STRING, forState: UIControlState.Normal)
            self.moreButton.setTitle(EMPTY_STRING, forState: UIControlState.Normal)
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
                self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                self.moreButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setMedicationViewFrame()
            })
        } else if ((translate.x > 0) && self.medicationViewLeadingConstraint.constant > (-MEDICATION_VIEW_LEFT_OFFSET / 2)){
            UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
                self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                self.moreButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
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
            self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
            self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
            self.moreButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
            }, completion: { (finished) -> Void in
                self.setMedicationViewFrame()
        })
    }
    
    //MARK :EditDeleteActionDelegate Methods
    
    @IBAction func editMedicationButtonPressed(sender: AnyObject) {
        if let delegate = editAndDeleteDelegate {
            delegate.editMedicationForSelectedIndexPath(indexPath)
        }
    }
    
    @IBAction func stopMedicationButtonPressed(sender: AnyObject) {
        
        swipeMedicationDetailViewToRight()
        if let delegate = editAndDeleteDelegate {
            delegate.stopMedicationForSelectedIndexPath(indexPath)
        }
    }

    @IBAction func moreButtonPressed(sender: AnyObject) {
        
        swipeMedicationDetailViewToRight()
        if let delegate = editAndDeleteDelegate {
            delegate.moreButtonSelectedForIndexPath(indexPath)
        }
    }
    @IBAction func typeDescriptionButtonPressed(sender: AnyObject) {
        
       // summary popover display
        print("***** Display Summary popover")
    }

    @IBAction func summaryDisplayButton(sender: AnyObject) {

        //Display Summary
        if let delegate = editAndDeleteDelegate {
            delegate.transitToSummaryScreenForMedication(indexPath)
        }
    }


}