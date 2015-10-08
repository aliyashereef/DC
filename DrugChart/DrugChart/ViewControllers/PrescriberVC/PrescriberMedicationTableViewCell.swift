//
//  PrescriberMedicationTableViewCell.swift
//  DrugChart
//
//  Created by Muhammed Shaheer on 05/10/15.
//
//

import UIKit

//protocol PrescriberMedicationTableViewCellDelegate:class {
//    
//    func tableCellSwipedToLeftDirection()
//    func tableCellSwipedToRightDirection()
//}

let TIME_VIEW_WIDTH : CGFloat                       =               70.0
let TIME_VIEW_HEIGHT : CGFloat                      =               21.0
let MEDICATION_VIEW_LEFT_OFFSET : CGFloat           =               120.0
let MEDICATION_VIEW_INITIAL_LEFT_OFFSET : CGFloat   =               0.0
let ANIMATION_DURATION : CGFloat                    =               0.3

class PrescriberMedicationTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var medicineDetailHolderView: UIView!
    @IBOutlet weak var medicineName: UILabel!
    @IBOutlet weak var route: UILabel!
    @IBOutlet weak var instructions: UILabel!
    @IBOutlet weak var administerDetailsHolderView: UIView!
    @IBOutlet weak var masterMedicationAdministerDetailsView : UIView!
    @IBOutlet weak var leftMedicationAdministerDetailsView: UIView!
    @IBOutlet weak var rightMedicationAdministerDetailsView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var administerHolderViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var editButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var stopButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var medicationViewLeadingConstraint: NSLayoutConstraint!
    // this is the constraint connected between the masterMedicationAdministerDetailsView (center)
    // to the containerView holding the 3 subviews (left, right, center)
    // To move the calendar left/right only this constant value needs to be changed.
    @IBOutlet weak var leadingSpaceMasterToContainerView: NSLayoutConstraint!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        addPanGestureToMedicationDetailHolderView()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Private Methods
        
    func addPanGestureToMedicationDetailHolderView () {
        
        //add pan gesture to medication detail holder view
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("swipeMedicationDetailView:"))
        medicineDetailHolderView.addGestureRecognizer(panGesture)
    }
    
    func setEditViewButtonNames() {
        
        if (self.editButtonWidth.constant > 40.0) {
            self.editButton.setTitle("Edit", forState: UIControlState.Normal)
            self.stopButton.setTitle("Stop", forState: UIControlState.Normal)
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
    }
    
    // MARK: Action Methods
    
    func swipeMedicationDetailView(panGesture : UIPanGestureRecognizer) {
        
        //swipe medication view
        let translate : CGPoint = panGesture.translationInView(self.contentView)
        let gestureVelocity : CGPoint = panGesture.velocityInView(self)
        if (gestureVelocity.x > 200.0 || gestureVelocity.x < -200.0) {
            if ((translate.x < 0) && (medicationViewLeadingConstraint.constant == 0)) {
                UIView.animateWithDuration(0.2, animations: {
                    self.medicationViewLeadingConstraint.constant = -MEDICATION_VIEW_LEFT_OFFSET
                    self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                    self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                    self.editButton.setTitle("Edit", forState: UIControlState.Normal)
                    self.stopButton.setTitle("Stop", forState: UIControlState.Normal)
                    self.layoutIfNeeded()
                    })
            } else if ((translate.x > 0) && (self.medicationViewLeadingConstraint.constant == -MEDICATION_VIEW_LEFT_OFFSET)){
                UIView.animateWithDuration(0.2, animations: {
                    self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                    self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                    self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                })
            } else{
                if (((translate.x < 0) && (self.medicationViewLeadingConstraint.constant > -MEDICATION_VIEW_LEFT_OFFSET)) || ((translate.x > 0) && (self.medicationViewLeadingConstraint.constant < MEDICATION_VIEW_INITIAL_LEFT_OFFSET))) {
                    
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
            if ((translate.x < 0) && self.medicationViewLeadingConstraint.constant < (-MEDICATION_VIEW_LEFT_OFFSET / 2)) {
                UIView.animateWithDuration(0.2, animations: {
                    self.medicationViewLeadingConstraint.constant = -MEDICATION_VIEW_LEFT_OFFSET
                    self.layoutIfNeeded()
                    }, completion: { finished in
                        self.setMedicationViewFrame()
                })
            } else if ((translate.x < 0) && self.medicationViewLeadingConstraint.constant > (-MEDICATION_VIEW_LEFT_OFFSET / 2)) {
                UIView.animateWithDuration(0.2, animations: {
                    self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET + 10
                    self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                    self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                    self.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        self.setMedicationViewFrame()
                })
            } else if ((translate.x > 0) && self.medicationViewLeadingConstraint.constant > (-MEDICATION_VIEW_LEFT_OFFSET / 2)){
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                    self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                    self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                    self.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        self.setMedicationViewFrame()
                })
            } else if ((translate.x > 0) && self.medicationViewLeadingConstraint.constant < (-MEDICATION_VIEW_LEFT_OFFSET / 2)){
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.medicationViewLeadingConstraint.constant = -MEDICATION_VIEW_LEFT_OFFSET;
                    self.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        self.setMedicationViewFrame()
                })
            }
             UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                }, completion: { (finished) -> Void in
                    self.setMedicationViewFrame()
            })
        }

    }

    @IBAction func editMedicationButtonPressed(sender: AnyObject) {
        
    }
    
    @IBAction func stopMedicationButtonPressed(sender: AnyObject) {
        
    }
    
}
