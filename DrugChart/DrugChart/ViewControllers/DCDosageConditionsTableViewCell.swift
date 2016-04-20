//
//  DCDosageConditionsTableViewCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 04/01/16.
//
//

import UIKit

protocol EditDeleteDelegate {
    
    func deleteSelectedIndexPath(indexPath : NSIndexPath)
    func editSelectedIndexPath (indexPath : NSIndexPath)
    func setIndexPathSelected(indexPath : NSIndexPath)
}

class DCDosageConditionsTableViewCell: UITableViewCell {
    
    var indexPath : NSIndexPath!
    
    let DOSAGE_VIEW_LEFT_OFFSET : CGFloat           =               120.0
    let DOSAGE_VIEW_INITIAL_LEFT_OFFSET : CGFloat   =               0.0
    
    @IBOutlet weak var dosageDetailViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var conditionsMainLabel: UILabel!
    @IBOutlet weak var dosageConditionHolderView: UIView!
    @IBOutlet weak var editDeleteHolderView: UIView!

    @IBOutlet weak var editButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var stopButtonWidth: NSLayoutConstraint!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var editDeleteDelegate : EditDeleteDelegate?

    override func awakeFromNib() {
        self.addPanGestureToMedicationDetailHolderView()
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Action Methods
    func addPanGestureToMedicationDetailHolderView () {
        
        //add pan gesture to medication detail holder view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(DCDosageConditionsTableViewCell.swipeMedicationDetailView(_:)))
        panGesture.delegate = self
        dosageConditionHolderView.addGestureRecognizer(panGesture)
    }
    
    // To make the swipe smooth.
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func swipeMedicationDetailView(panGesture : UIPanGestureRecognizer) {
        
        //swipe medication view
        if (indexPath != nil) {
            let translate : CGPoint = panGesture.translationInView(self.contentView)
            let gestureVelocity : CGPoint = panGesture.velocityInView(self)
            if (gestureVelocity.x > 200.0 || gestureVelocity.x < -200.0) {
                if ((translate.x < 0) && (dosageDetailViewLeadingConstraint.constant == 0)) { // left swipe
                    UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                        self.dosageDetailViewLeadingConstraint.constant = -self.DOSAGE_VIEW_LEFT_OFFSET
                        self.setEditDeleteButtonWidth()
                        self.editButton.setTitle(EDIT_TEXT, forState: UIControlState.Normal)
                        self.stopButton.setTitle(DELETE_TEXT, forState: UIControlState.Normal)
                        self.layoutIfNeeded()
                    })
                    if let delegate = editDeleteDelegate {
                        delegate.setIndexPathSelected(indexPath)
                    }
                } else if ((translate.x > 0) && (self.dosageDetailViewLeadingConstraint.constant == -DOSAGE_VIEW_LEFT_OFFSET)){ //right pan  when edit view is fully visible
                    UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                        self.dosageDetailViewLeadingConstraint.constant = self.DOSAGE_VIEW_INITIAL_LEFT_OFFSET
                        self.setEditDeleteButtonWidth()
                        self.layoutIfNeeded()
                    })
                    if let delegate = editDeleteDelegate {
                        delegate.setIndexPathSelected(indexPath)
                    }
                } else{
                    if (((translate.x < 0) && (self.dosageDetailViewLeadingConstraint.constant > -DOSAGE_VIEW_LEFT_OFFSET)) || ((translate.x > 0) && (self.dosageDetailViewLeadingConstraint.constant < DOSAGE_VIEW_INITIAL_LEFT_OFFSET))) {
                        //in process of tramslation
                        dispatch_async(dispatch_get_main_queue(), {
                            self.dosageDetailViewLeadingConstraint.constant += (gestureVelocity.x / 25.0)
                            self.setEditDeleteButtonWidth()
                            self.setEditViewButtonNames()
                            self.setDosageConditionViewFrame()
                        })
                        if let delegate = editDeleteDelegate {
                            delegate.setIndexPathSelected(indexPath)
                        }
                    }
                }
            }
            if (panGesture.state == UIGestureRecognizerState.Ended) {
                //All fingers are lifted.
                adjustMedicationDetailViewOnPanGestureEndWithTranslationPoint(translate)
            }

        }
    }
    
    func adjustMedicationDetailViewOnPanGestureEndWithTranslationPoint(translate : CGPoint) {
        
        //gesture ended
        if ((translate.x < 0) && self.dosageDetailViewLeadingConstraint.constant < (-MEDICATION_VIEW_LEFT_OFFSET / 2)) {
            UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                self.dosageDetailViewLeadingConstraint.constant = -self.DOSAGE_VIEW_LEFT_OFFSET
                self.layoutIfNeeded()
                }, completion: { finished in
                    self.setDosageConditionViewFrame()
            })
        } else if ((translate.x < 0) && self.dosageDetailViewLeadingConstraint.constant > (-MEDICATION_VIEW_LEFT_OFFSET / 2)) {
            UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                self.dosageDetailViewLeadingConstraint.constant = self.DOSAGE_VIEW_INITIAL_LEFT_OFFSET + 10
                self.setEditDeleteButtonWidth()
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setDosageConditionViewFrame()
            })
        } else if ((translate.x > 0) && self.dosageDetailViewLeadingConstraint.constant > (-MEDICATION_VIEW_LEFT_OFFSET / 2)){
            UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
                self.dosageDetailViewLeadingConstraint.constant = self.DOSAGE_VIEW_INITIAL_LEFT_OFFSET
                self.setEditDeleteButtonWidth()
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setDosageConditionViewFrame()
            })
        } else if ((translate.x > 0) && self.dosageDetailViewLeadingConstraint.constant < (-DOSAGE_VIEW_LEFT_OFFSET / 2)){
            UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
                self.dosageDetailViewLeadingConstraint.constant = -self.DOSAGE_VIEW_LEFT_OFFSET;
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.setDosageConditionViewFrame()
            })
        }
        UIView.animateWithDuration(ANIMATION_DURATION, animations: { () -> Void in
            self.setEditDeleteButtonWidth()
            }, completion: { (finished) -> Void in
                self.setDosageConditionViewFrame()
        })
    }

    
    func setEditViewButtonNames() {
        
        if (self.editButtonWidth.constant > 40.0) {
            self.editButton.setTitle(EDIT_TEXT, forState: UIControlState.Normal)
            self.stopButton.setTitle(DELETE_TEXT, forState: UIControlState.Normal)
        } else {
            self.editButton.setTitle(EMPTY_STRING, forState: UIControlState.Normal)
            self.stopButton.setTitle(EMPTY_STRING, forState: UIControlState.Normal)
        }
    }
    
    func setDosageConditionViewFrame() {
        
        if (self.dosageDetailViewLeadingConstraint.constant < -DOSAGE_VIEW_LEFT_OFFSET) {
            self.dosageDetailViewLeadingConstraint.constant = -DOSAGE_VIEW_LEFT_OFFSET;
        } else if (self.dosageDetailViewLeadingConstraint.constant > DOSAGE_VIEW_INITIAL_LEFT_OFFSET) {
            self.dosageDetailViewLeadingConstraint.constant = DOSAGE_VIEW_INITIAL_LEFT_OFFSET;
        }
    }
    
    @IBAction func editButtonPressed(sender: AnyObject) {
        if let delegate = editDeleteDelegate {
            delegate.editSelectedIndexPath(indexPath)
        }
    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        
        swipeMedicationDetailViewToRight()
        if let delegate = editDeleteDelegate {
            delegate.deleteSelectedIndexPath(indexPath)
        }
    }
    
    func setEditDeleteButtonWidth () {
        // for the first condition, we can only edit it
        if indexPath.row == 0 {
            self.stopButtonWidth.constant = 0
        } else {
            self.editButtonWidth.constant = -(self.dosageDetailViewLeadingConstraint.constant / 2)
            self.stopButtonWidth.constant = -(self.dosageDetailViewLeadingConstraint.constant / 2)
        }
    }
    
    func swipeMedicationDetailViewToRight() {
        
        //swipe gesture - right when completion of edit/delete action
        UIView.animateWithDuration(ANIMATION_DURATION) { () -> Void in
            self.dosageDetailViewLeadingConstraint.constant = self.DOSAGE_VIEW_INITIAL_LEFT_OFFSET;
            self.layoutIfNeeded()
        }
    }

}
