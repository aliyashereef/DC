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

protocol EditAndDeleteActionDelegate {
    
    func stopMedicationForSelectedIndexPath(indexPath : NSIndexPath)

}

let TIME_VIEW_WIDTH : CGFloat                       =               70.0
let TIME_VIEW_HEIGHT : CGFloat                      =               21.0
let MEDICATION_VIEW_LEFT_OFFSET : CGFloat           =               120.0
let MEDICATION_VIEW_INITIAL_LEFT_OFFSET : CGFloat   =               0.0
let ANIMATION_DURATION : Double                     =               0.3
let MEDICATION_VIEW_WIDTH : CGFloat                 =               300
let EDIT_TEXT : String                              =               "Edit"
let STOP_TEXT : String                              =               "Stop"

protocol DCPrescriberCellDelegate:class {
    
    func movePrescriberCellWithTranslationParameters(xTranslation : CGPoint, xVelocity : CGPoint, panEnded: Bool)
}

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
    var editAndDeleteDelegate : EditAndDeleteActionDelegate?
    var indexPath : NSIndexPath!
    
    var cellDelegate : DCPrescriberCellDelegate?

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

    
    // MARK: Action Methods
    
    func swipeMedicationDetailView(panGesture : UIPanGestureRecognizer) {
        
        //swipe medication view
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
    
    func swipeMedicationDetailViewToRight() {
        
        //swipe gesture - right when completion of edit/delete action
        UIView.animateWithDuration(ANIMATION_DURATION) { () -> Void in
            self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET;
            self.layoutIfNeeded()
        }
    }

    @IBAction func editMedicationButtonPressed(sender: AnyObject) {
        
    }
    
    @IBAction func stopMedicationButtonPressed(sender: AnyObject) {
        swipeMedicationDetailViewToRight()
        if let delegate = editAndDeleteDelegate {
            delegate.stopMedicationForSelectedIndexPath(indexPath)
        }
    }
    
    func setIndexPathForCell(indexpath : NSIndexPath) {
        self.indexPath = indexpath
    }
    
    
    func movePrescriberCellWithTranslationParameters(xTranslation : CGFloat, xVelocity : CGFloat, panEnded : Bool) {
        
        let calendarWidth : CGFloat = (DCUtility.getMainWindowSize().width - MEDICATION_VIEW_WIDTH);
        let valueToTranslate = leadingSpaceMasterToContainerView.constant + xTranslation;
        if (valueToTranslate >= -calendarWidth && valueToTranslate <= calendarWidth) {
            leadingSpaceMasterToContainerView.constant = leadingSpaceMasterToContainerView.constant + xTranslation;
        }
        if (panEnded == true) {
            if (xVelocity > 0) {
                // animate to left. show previous week
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    if (self.leadingSpaceMasterToContainerView.constant >= MEDICATION_VIEW_WIDTH) {
                        self.leadingSpaceMasterToContainerView.constant = calendarWidth
                    } else {
                        //display current week
                        self.leadingSpaceMasterToContainerView.constant = 0.0
                    }
                    self.layoutIfNeeded()
                })
            } else {
                //show next week
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                if (self.leadingSpaceMasterToContainerView.constant <= -MEDICATION_VIEW_WIDTH) {
                    self.leadingSpaceMasterToContainerView.constant = -calendarWidth
                } else {
                    self.leadingSpaceMasterToContainerView.constant = 0.0
                }
                self.layoutIfNeeded()
            })
        }
    }
}
    
}
