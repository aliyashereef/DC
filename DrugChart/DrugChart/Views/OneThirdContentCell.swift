//
//  OneThirdContentCell.swift
//  DrugChart
//
//  Created by Noureen on 14/01/2016.
//
//

import UIKit

class OneThirdContentCell: UITableViewCell {

    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var title: UILabel!
    var showObservationType:ShowObservationType!
    var observation:VitalSignObservation!
    var delegate:ObservationDelegate? = nil
    var deleteIcon: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        title.layer.borderWidth = Constant.BORDER_WIDTH
        title.layer.borderColor = Constant.CELL_BORDER_COLOR
        title.layer.cornerRadius = Constant.CORNER_RADIUS
       
        content.layer.borderWidth = Constant.BORDER_WIDTH
        content.layer.borderColor = Constant.CELL_BORDER_COLOR
        content.layer.cornerRadius = Constant.CORNER_RADIUS
        
        title.font = UIFont.systemFontOfSize(15)
        title.backgroundColor = Constant.SELECTION_CELL_BACKGROUND_COLOR
        
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
            observationDetails.configureView(observation, showobservatioType: showObservationType,tag:2)
            let navigationController : UINavigationController? = UINavigationController(rootViewController: observationDetails)
            navigationController?.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            delegate?.ShowModalNavigationController(navigationController!)
        }
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


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func clearCell()
    {
        if(deleteIcon != nil)
        {
            deleteIcon.removeFromSuperview()
        }
        
    }
    
    func configureCell(showObservationType:ShowObservationType ,observation:VitalSignObservation )
    {
        self.showObservationType = showObservationType
        self.observation = observation
        
        // add the delete button
        if(showObservationType != ShowObservationType.None && showObservationType != ShowObservationType.All && ObjectIsNotNull())
        {
            
            deleteIcon = UILabel()
            let originx = self.frame.width - 25
            deleteIcon.frame = CGRectMake(originx, 4, 25, 25)
            deleteIcon.font = UIFont.systemFontOfSize(12)
            deleteIcon.textAlignment = .Center
            deleteIcon.text = "X"
            deleteIcon.layer.borderWidth = 0.5
            deleteIcon.layer.borderColor = UIColor.redColor().CGColor
            deleteIcon.textColor = UIColor.redColor()
            deleteIcon.backgroundColor = UIColor.whiteColor()
            deleteIcon.layer.cornerRadius = 14
            deleteIcon.layer.masksToBounds = true
            self.addSubview(deleteIcon)
            // add the event on label
            let deleteGesture = UITapGestureRecognizer(target: self, action: "deleteObservation")
            deleteIcon.userInteractionEnabled=true
            deleteIcon.addGestureRecognizer(deleteGesture)
        }
    }
    
    func deleteObservation()
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
            
            let tableView =  self.superview?.superview as? UITableView
            tableView?.reloadData()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            print("in cancel")
        }))
        
        delegate?.ShowAlertController(deleteAlert)
    }
}
