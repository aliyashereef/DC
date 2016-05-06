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
    func moreButtonSelectedForIndexPath(indexPath : NSIndexPath)
}

let TIME_VIEW_WIDTH : CGFloat                       =               70.0
let TIME_VIEW_HEIGHT : CGFloat                      =               21.0
let MEDICATION_VIEW_LEFT_OFFSET : CGFloat           =               180.0
let MEDICATION_VIEW_INITIAL_LEFT_OFFSET : CGFloat   =               0.0
let ANIMATION_DURATION : Double                     =               0.3
let EDIT_TEXT : String                              =               "Edit"
let STOP_TEXT : String                              =               "Stop"
let DELETE_TEXT                                     =               "Delete"
let MORE_TEXT : String                              =               "More"

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
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var administerHolderViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var editButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var stopButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var moreButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var medicationViewLeadingConstraint: NSLayoutConstraint!
    // this is the constraint connected between the masterMedicationAdministerDetailsView (center)
    // to the containerView holding the 3 subviews (left, right, center)
    // To move the calendar left/right only this constant value needs to be changed.
    @IBOutlet weak var leadingSpaceMasterToContainerView: NSLayoutConstraint!
    @IBOutlet weak var medicationTypeLabel: UILabel!
    
    var calendarWidth : CGFloat!
    var editAndDeleteDelegate : EditAndDeleteActionDelegate?
    var indexPath : NSIndexPath!
    var cellDelegate : DCPrescriberCellDelegate?
    var inEditMode : Bool = false
    var isMedicationActive : Bool = true
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
    var cellHeight : CGFloat? = 0.0
    
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
            
            tag += 1
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
                count += 1
            }
        }
    }
    
    func updateAdministerStatusViewsHeight() {
        
        let noOfStatusViews = (appDelegate.windowState == DCWindowState.twoThirdWindow) ? 9 : 12
        let calendarStripDaysCount = (appDelegate.windowState == DCWindowState.fullWindow) ? 4:3
        var count = 0
        autoreleasepool { () -> () in
            for _ in 0..<noOfStatusViews {
                switch (count) {
                case 0..<calendarStripDaysCount:
                    // Status views in leftMedicationAdministerDetailsView
                    self.updateAdministerStatusViewsInContainerView(leftMedicationAdministerDetailsView, atSlotIndex: count)
                case calendarStripDaysCount..<2*calendarStripDaysCount:
                    // Status views in masterMedicationAdministerDetailsView
                    self.updateAdministerStatusViewsInContainerView(masterMedicationAdministerDetailsView, atSlotIndex: count-calendarStripDaysCount)
                case 2*calendarStripDaysCount..<3*calendarStripDaysCount:
                    // Status views in rightMedicationAdministerDetailsView
                    self.updateAdministerStatusViewsInContainerView(rightMedicationAdministerDetailsView, atSlotIndex: count-2*calendarStripDaysCount)
                default:
                    break
                }
                count += 1
            }
        }
    }
    
    // MARK: Private Methods
    
    func calculateHeightForCell() -> CGFloat? {
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        let height = self.contentView.systemLayoutSizeFittingSize(UILayoutFittingExpandedSize).height
        return height
    }
    
    func addAdministerStatusViewsTo(containerView: UIView, atSlotIndex index: Int) {
        //TODO: medication administration slots have to be made constant width , medication details flexible width
        
        let viewWidth : CGFloat = (appDelegate.windowState == DCWindowState.fullWindow) ?
                                            DCCalendarConstants.FULL_SCREEN_CALENDAR_WIDTH/DCCalendarConstants.FULL_SCREEN_DAYS_COUNT :
                                            DCCalendarConstants.TWO_THIRD_SCREEN_CALENDAR_WIDTH/DCCalendarConstants.TWO_THIRD_SCREEN_DAYS_COUNT
        let xValue : CGFloat = CGFloat(index) * viewWidth + CGFloat(index) + 1;
        let viewFrame = CGRectMake(xValue, 0, viewWidth, DCCalendarConstants.STATUS_VIEW_DEFAULT_WIDTH)
        let statusView : DCMedicationAdministrationStatusView = DCMedicationAdministrationStatusView(frame: viewFrame)
        statusView.tag = index+1
        statusView.isOneThirdScreen = false
        statusView.backgroundColor = UIColor.whiteColor()
        containerView.addSubview(statusView)
    }
    
    func updateAdministerStatusViewsInContainerView(containerView: UIView, atSlotIndex index: Int) {
        
        let administerViews = containerView.subviews.filter{$0 is DCMedicationAdministrationStatusView}
        for statusView in administerViews as! [DCMedicationAdministrationStatusView] {
            let viewFrame = statusView.frame
            statusView.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, cellHeight!)
            statusView.refreshViewWithUpdatedFrame()
            statusView.layoutIfNeeded()
        }
    }
    
    func addPanGestureToMedicationDetailHolderView () {
        
        //add pan gesture to medication detail holder view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(PrescriberMedicationTableViewCell.swipeMedicationDetailView(_:)))
        panGesture.delegate = self
        medicineDetailHolderView.addGestureRecognizer(panGesture)
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
                        self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                        self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                        self.moreButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                        self.editButton.setTitle(EDIT_TEXT, forState: UIControlState.Normal)
                        self.stopButton.setTitle(STOP_TEXT, forState: UIControlState.Normal)
                        self.moreButton.setTitle(MORE_TEXT, forState: UIControlState.Normal)
                        self.layoutIfNeeded()
                    })
                    if let delegate = editAndDeleteDelegate {
                        delegate.setIndexPathSelected   (indexPath)
                    }
                } else if ((translate.x > 0) && (self.medicationViewLeadingConstraint.constant == -MEDICATION_VIEW_LEFT_OFFSET)){ //right pan  when edit view is fully visible
                    UIView.animateWithDuration(ANIMATION_DURATION, animations: {
                        self.medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET
                        self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                        self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                        self.moreButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
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
                            self.editButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                            self.stopButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
                            self.moreButtonWidth.constant = -(self.medicationViewLeadingConstraint.constant / 3)
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
    
    @IBAction func moreButtonPressed(sender: AnyObject) {
        
        if let delegate = editAndDeleteDelegate {
            delegate.moreButtonSelectedForIndexPath(indexPath)
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
