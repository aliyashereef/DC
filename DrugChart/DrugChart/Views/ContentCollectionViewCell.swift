//
//  ContentCollectionViewCell.swift
//  CustomCollectionLayout
//
//  Created by JOSE MARTINEZ on 09/01/2015.
//  Copyright (c) 2015 brightec. All rights reserved.
//

import UIKit

class ContentCollectionViewCell: UICollectionViewCell,UIGestureRecognizerDelegate{
    @IBOutlet weak var contentLabel: UILabel!
    var observation:VitalSignObservation!
    var delegate:ObservationDelegate? = nil
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var deleteButton: UIButton!
    var showObservationType:ShowObservationType!
    var selectedCellDelegate:CellDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel.bounds.size = CGSize (width: 165 , height: 30)
        scrollView.contentSize.width = 400
        let swipeGesture:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("setSelectedCell:"))
        swipeGesture.direction = .Left
       swipeGesture.delegate = self
        self.addGestureRecognizer(swipeGesture)
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func setSelectedCell(sender:UISwipeGestureRecognizer)
    {
        if(sender.state == .Ended && deleteButton.hidden == false)
        {
            selectedCellDelegate.selectedCell(self)
        }
    }
    
    func resetCellScroll()
    {
        if(deleteButton.hidden == false) // only select the cell if there is delete button available
        {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    func configureCell(observation:VitalSignObservation ,showobservationType:ShowObservationType )
    {
        self.observation = observation
        self.showObservationType = showobservationType
        // add the delete button
        if(showObservationType != ShowObservationType.None && showObservationType != ShowObservationType.All && ObjectIsNotNull())
        {
            deleteButton.hidden = false
        }
        else
        {
            deleteButton.hidden = true
        }
        // normal stuff
        let tap = UITapGestureRecognizer(target: self, action: "doubleTapped")
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
    }
    
    func doubleTapped() {
        if(showObservationType != ShowObservationType.None && showObservationType != ShowObservationType.All && ObjectIsNotNull())
        {
            let mainStoryboard = UIStoryboard(name: "PatientMenu", bundle: NSBundle.mainBundle())
            let observationDetails : ObservationViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ObservationViewController") as! ObservationViewController
            observationDetails.configureView(observation, showobservatioType: showObservationType,tag:1)
            let navigationController : UINavigationController? = UINavigationController(rootViewController: observationDetails)
            navigationController?.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            delegate?.ShowModalNavigationController(navigationController!)
        }
    }
    
    @IBAction func deleteObservation()
    {
        let deleteAlert = UIAlertController(title: "Delete", message: "Are you sure, you want to delete?", preferredStyle: UIAlertControllerStyle.Alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            switch (self.showObservationType!)
            {
            case ShowObservationType.Respiratory:
                if(self.observation != nil)
                {
                    self.observation.respiratory = nil
                }
                
            case ShowObservationType.SpO2:
                if(self.observation != nil)
                {
                    self.observation.spo2 = nil
                }
                
            case ShowObservationType.Temperature:
                if(self.observation != nil)
                {
                    self.observation.temperature = nil
                }
            case ShowObservationType.BloodPressure:
                if(self.observation != nil)
                {
                    self.observation.bloodPressure = nil
                }
            case ShowObservationType.Pulse:
                if(self.observation != nil)
                {
                    self.observation.pulse = nil
                }
            default:
                print("nothing to delete")
            }
            
            let collectionView =  self.superview as? UICollectionView
            collectionView?.reloadData()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            print("in cancel")
            self.resetCellScroll()
        }))
        
        delegate?.ShowAlertController(deleteAlert)
        resetCellScroll()
    }
    func ObjectIsNotNull()->Bool
    {
        switch (showObservationType!)
        {
        case ShowObservationType.Respiratory:
            return  (observation != nil && observation.respiratory != nil) ? true : false
        case ShowObservationType.SpO2:
            return  (observation != nil && observation.spo2 != nil) ? true : false
            
        case ShowObservationType.Temperature:
            return  (observation != nil && observation.temperature != nil) ? true : false
            
        case ShowObservationType.BloodPressure:
            return  (observation != nil && observation.bloodPressure != nil) ? true : false
            
        case ShowObservationType.Pulse:
            return  (observation != nil && observation.pulse != nil) ? true : false
            
        default:
            return false
        }
    }
}
