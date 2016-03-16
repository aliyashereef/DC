//
//  PrescriberMedicationTableViewCell.swift
//  DrugChart
//
//  Created by Muhammed Shaheer on 05/10/15.
//
//

import UIKit

protocol EditAndDeleteActionDelegate {
    
    func stopMedicationForSelectedIndexPath(indexPath : NSIndexPath)
    func editMedicationForSelectedIndexPath (indexPath : NSIndexPath)
    func setIndexPathSelected(indexPath : NSIndexPath)
    func transitToSummaryScreenForMedication(indexpath : NSIndexPath)
}

let TIME_VIEW_WIDTH : CGFloat                       =               70.0
let TIME_VIEW_HEIGHT : CGFloat                      =               21.0
let MEDICATION_VIEW_LEFT_OFFSET : CGFloat           =               120.0
let MEDICATION_VIEW_INITIAL_LEFT_OFFSET : CGFloat   =               0.0
let ANIMATION_DURATION : Double                     =               0.3
let EDIT_TEXT : String                              =               "Edit"
let STOP_TEXT : String                              =               "Stop"

protocol DCPrescriberCellDelegate:class {
    
    func movePrescriberCellWithTranslationParameters(xTranslation : CGPoint, xVelocity : CGPoint, panEnded: Bool)
}

class PrescriberMedicationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var medicationDetailHolderViewWidthConstraint: NSLayoutConstraint!

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
    @IBOutlet weak var medicationTypeLabel: UILabel!
    
    var editAndDeleteDelegate : EditAndDeleteActionDelegate?
    var indexPath : NSIndexPath!
    var cellDelegate : DCPrescriberCellDelegate?
    var inEditMode : Bool = false
    var isMedicationActive : Bool = true
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
            addPanGestureToMedicationDetailHolderView()
            addPanGestureToMedicationDetailHolderView()
        // Administer status views are created here to make the views reusable for a table view cell
            createAdministerStatusViews()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // This function should be called when there is a change in the number of weekdays displayed.
    // Removes the previously added status views.
    func removeAllStatusViews() {
        let noOfSubviews = masterMedicationAdministerDetailsView.subviews.count
        
        var tag = 1
        for _ in 0..<noOfSubviews {
            leftMedicationAdministerDetailsView.viewWithTag(tag)?.removeFromSuperview()
            masterMedicationAdministerDetailsView.viewWithTag(tag)?.removeFromSuperview()
            rightMedicationAdministerDetailsView.viewWithTag(tag)?.removeFromSuperview()
            
            tag++
        }
    }
    
    func createAdministerStatusViews() {
        let noOfStatusViews = (appDelegate.windowState == DCWindowState.twoThirdWindow) ? 9 : 15
        let calendarStripDaysCount = (appDelegate.windowState == DCWindowState.fullWindow) ? 5:3
        
        var count = 0
        
        autoreleasepool { () -> () in
            for _ in 0..<noOfStatusViews {
                switch (count) {
                case 0..<calendarStripDaysCount:
                    // Status views should be added to leftMedicationAdministerDetailsView
                    self.addAdministerStatusViewsTo(leftMedicationAdministerDetailsView, atSlotIndex: count)
                case calendarStripDaysCount..<2*calendarStripDaysCount:
                    // Status views should be added to masterMedicationAdministerDetailsView
                    self.addAdministerStatusViewsTo(masterMedicationAdministerDetailsView, atSlotIndex: count-calendarStripDaysCount)
                case 2*calendarStripDaysCount..<3*calendarStripDaysCount:
                    // Status views should be added to rightMedicationAdministerDetailsView
                    self.addAdministerStatusViewsTo(rightMedicationAdministerDetailsView, atSlotIndex: count-2*calendarStripDaysCount)
                default:
                    break
                }
                
                count++
            }
        }
        
    }
    
    // MARK: Private Methods
    
    func addAdministerStatusViewsTo(containerView: UIView, atSlotIndex index: Int) {
        let slotWidth = DCUtility.mainWindowSize().width
        let viewFrameWidth = slotWidth * 0.30 // 70 percent of the screen width
        let viewWidth = (appDelegate.windowState == DCWindowState.fullWindow) ? (slotWidth - viewFrameWidth)/5 : (slotWidth - viewFrameWidth)/3
        let xValue : CGFloat = CGFloat(index) * viewWidth + CGFloat(index) + 1;
        let viewFrame = CGRectMake(xValue, 0, viewWidth, 78.0)
        let statusView : DCMedicationAdministrationStatusView = DCMedicationAdministrationStatusView(frame: viewFrame)
        statusView.tag = index+1
        statusView.isOneThirdScreen = false
        statusView.backgroundColor = UIColor.whiteColor()
        
        containerView.addSubview(statusView)
    }
    
    func addPanGestureToMedicationDetailHolderView () {
        
        //add pan gesture to medication detail holder view
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("swipeMedicationDetailView:"))
        panGesture.delegate = self
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
                    if let delegate = editAndDeleteDelegate {
                        delegate.setIndexPathSelected   (indexPath)
                    }
                } else if ((translate.x > 0) && (self.medicationViewLeadingConstraint.constant == -MEDICATION_VIEW_LEFT_OFFSET)){ //right pan  when edit view is fully visible
                    UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                        self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                        self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                        self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 2)
                        self.layoutIfNeeded()
                    })
                    if let delegate = editAndDeleteDelegate {
                        delegate.setIndexPathSelected   (indexPath)
                    }
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
                        if let delegate = editAndDeleteDelegate {
                            delegate.setIndexPathSelected   (indexPath)
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
    
    func swipeMedicationDetailViewToRight() {
        
        //swipe gesture - right when completion of edit/delete action
        inEditMode = false
        UIView.animateWithDuration(ANIMATION_DURATION) { () -> Void in
            self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET;
            self.layoutIfNeeded()
        }
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
    
    func todayButtonAction () {
        
        UIView.animateWithDuration(0.1) { () -> Void in
            self.leadingSpaceMasterToContainerView.constant = 0.0
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func typeDescriptionButtonSelected(sender: AnyObject) {
        
        //Display Summary
        if let delegate = editAndDeleteDelegate {
            delegate.transitToSummaryScreenForMedication(indexPath)
        }
    }
}
