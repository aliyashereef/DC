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
        // add the delete button 
        if(showObservationType != ShowObservationType.None && showObservationType != ShowObservationType.All)
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
        }
        // normal stuff
        self.observation = observation
        self.showObservationType = showobservationType
        let tap = UITapGestureRecognizer(target: self, action: "doubleTapped")
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
    }
    
    func doubleTapped() {
        if(showObservationType != ShowObservationType.None && showObservationType != ShowObservationType.All)
        {
            let mainStoryboard = UIStoryboard(name: "PatientMenu", bundle: NSBundle.mainBundle())
            let observationDetails : ObservationViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ObservationViewController") as! ObservationViewController
            observationDetails.configureView(observation, showobservatioType: showObservationType)
            let navigationController : UINavigationController? = UINavigationController(rootViewController: observationDetails)
            navigationController?.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            delegate?.ShowModalNavigationController(navigationController!)
        }
    }
}
