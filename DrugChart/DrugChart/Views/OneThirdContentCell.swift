//
//  OneThirdContentCell.swift
//  DrugChart
//
//  Created by Noureen on 14/01/2016.
//
//

import UIKit
import CocoaLumberjack

class OneThirdContentCell: UITableViewCell {

    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var title: UILabel!
    var showObservationType:ShowObservationType!
    var observation:VitalSignObservation!
    var delegate:ObservationDelegate? = nil
    var isDeletable:Bool = false
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
            observationDetails.configureView(observation, showobservatioType: showObservationType,tag:DataEntryObservationSource.VitalSignEditIPhone)
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
            return  (observation != nil && observation.respiratory.isValueEntered()) ? true : false
        case ShowObservationType.SpO2:
            return  (observation != nil && observation.spo2.isValueEntered()) ? true : false
            
        case ShowObservationType.Temperature:
            return  (observation != nil && observation.temperature.isValueEntered()) ? true : false
            
        case ShowObservationType.BloodPressure:
            return  (observation != nil && observation.bloodPressure.isValueEntered()) ? true : false
            
        case ShowObservationType.Pulse:
            return  (observation != nil && observation.pulse.isValueEntered()) ? true : false
            
        default:
            return false
        }
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(showObservationType:ShowObservationType ,observation:VitalSignObservation )
    {
        self.showObservationType = showObservationType
        self.observation = observation
        
        // add the delete button
        if(showObservationType != ShowObservationType.None && showObservationType != ShowObservationType.All && ObjectIsNotNull())
        {
            isDeletable = true
        }
        else
        {
            isDeletable = false
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
                    self.observation.respiratory.delete()
                }
                
            case ShowObservationType.SpO2:
                if(self.observation != nil)
                {
                    self.observation.spo2.delete()
                }
                
            case ShowObservationType.Temperature:
                if(self.observation != nil)
                {
                    self.observation.temperature.delete()
                }
            case ShowObservationType.BloodPressure:
                if(self.observation != nil)
                {
                    self.observation.bloodPressure.delete()
                }
            case ShowObservationType.Pulse:
                if(self.observation != nil)
                {
                    self.observation.pulse.delete()
                }
            default:
                DDLogDebug("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) nothing to delete")
            }
            
            let tableView =  self.superview?.superview as? UITableView
            tableView?.reloadData()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            let tableView =  self.superview?.superview as? UITableView
            tableView?.editing = false
        }))
        
        delegate?.ShowAlertController(deleteAlert)
    }
}
