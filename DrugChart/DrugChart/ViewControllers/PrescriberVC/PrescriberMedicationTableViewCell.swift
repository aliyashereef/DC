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
let ANIMATION_DURATION : Double                     =               0.3
let EDIT_TEXT : String                              =               "Edit"
let STOP_TEXT : String                              =               "Stop"

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
        addNotifications()
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
    
    func addNotifications () {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("calendarScreenPanned:"), name: kCalendarPanned, object: nil)
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
    
    func swipeMedicationDetailViewToRight(swipeGesture : UIGestureRecognizer) {
        
        //swipe gesture - right when completion of edit/delete action
        UIView.animateWithDuration(ANIMATION_DURATION) { () -> Void in
            self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET;
            self.layoutIfNeeded()
        }
    }

    @IBAction func editMedicationButtonPressed(sender: AnyObject) {
        
    }
    
    @IBAction func stopMedicationButtonPressed(sender: AnyObject) {
        
    }
    
    // MARK: Notification Methods
    
    func calendarScreenPanned (notification : NSNotification) {
        
        print("**** Calendar Pan Action in Table cell")
        let notificationInfo = notification.userInfo as! [String : CGFloat]?
        NSLog("notificationInfo is %@", notificationInfo!)
        if let xTranslation  = notificationInfo?["xPoint"] {
            NSLog("xTranslation is %f", xTranslation)
            leadingSpaceMasterToContainerView.constant = leadingSpaceMasterToContainerView.constant + xTranslation;
            self.layoutIfNeeded()
        }
        if let xVelocity : CGFloat = notificationInfo?["xVelocity"] {
            NSLog("xVelocity is %f", xVelocity)
        }
        if let panEnded : CGFloat = notificationInfo?["panEnded"] {
            NSLog("panEnded is %d", panEnded)
            if (panEnded == 1) {
                leadingSpaceMasterToContainerView.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
            }
        }
    }
    
}
