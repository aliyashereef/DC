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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(observation:VitalSignObservation)
    {
        self.observation = observation
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        let tap = UITapGestureRecognizer(target: self, action: "doubleTapped")
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
    }
    
    func doubleTapped() {
        //                let alert = UIAlertView()
        //                alert.title = "my title"
        //                alert.message = "things are working slowly"
        //                alert.addButtonWithTitle("Ok")
        //                alert.delegate = self
        //                alert.show()
        
        let mainStoryboard = UIStoryboard(name: "PatientMenu", bundle: NSBundle.mainBundle())
        let observationDetails : ObservationViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ObservationViewController") as! ObservationViewController
        //observationDetails.observation = cell?.getObservation()
        let navigationController : UINavigationController? = UINavigationController(rootViewController: observationDetails)
        navigationController?.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        delegate?.EditObservation(navigationController!)
    }
    
    
}
