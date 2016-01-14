//
//  ContentCollectionViewCell.swift
//  CustomCollectionLayout
//
//  Created by JOSE MARTINEZ on 09/01/2015.
//  Copyright (c) 2015 brightec. All rights reserved.
//

import UIKit

class ContentCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    var observation:VitalSignObservation!
    var delegate:ObservationDelegate? = nil
    var showObservationType:ShowObservationType!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
     
    }
    
    func configureCell(observation:VitalSignObservation ,showobservationType:ShowObservationType )
    {
        self.observation = observation
        self.showObservationType = showobservationType
        // add the delete button
        if(showObservationType != ShowObservationType.None && showObservationType != ShowObservationType.All && ObjectIsNotNull())
        {
            
        let indicatorLabel: UILabel = UILabel()
        let originx = self.frame.width - 25
        indicatorLabel.frame = CGRectMake(originx, 4, 25, 25)
        indicatorLabel.font = UIFont.systemFontOfSize(12)
        indicatorLabel.textAlignment = .Center
        indicatorLabel.text = "X"
        indicatorLabel.layer.borderWidth = 0.5
        indicatorLabel.layer.borderColor = UIColor.redColor().CGColor
        indicatorLabel.textColor = UIColor.redColor()
        indicatorLabel.backgroundColor = UIColor.whiteColor()
        indicatorLabel.layer.cornerRadius = 14
        indicatorLabel.layer.masksToBounds = true
        self.addSubview(indicatorLabel)
        // add the event on label 
        let deleteGesture = UITapGestureRecognizer(target: self, action: "deleteObservation")
        indicatorLabel.userInteractionEnabled=true
        indicatorLabel.addGestureRecognizer(deleteGesture)
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
            observationDetails.configureView(observation, showobservatioType: showObservationType)
            let navigationController : UINavigationController? = UINavigationController(rootViewController: observationDetails)
            navigationController?.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            delegate?.ShowModalNavigationController(navigationController!)
        }
    }
    func deleteObservation()
    {
        let alert = UIAlertView()
        alert.title = "my title"
        alert.message = "things are working slowly"
        alert.addButtonWithTitle("Ok")
        alert.delegate = self
        alert.show()
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
