//
//  TabularDashBoardView.swift
//  vitalsigns
//
//  Created by Noureen on 17/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit

class TabularDashBoardView: UIView ,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    // MARK: - Table view data source
    
    var delegate: ObservationEditDelegate? = nil
    var dataSource:[VitalSignObservation] = []
    func commonInit()
    {
        tableView.delegate=self
        tableView.dataSource=self
        let nib = UINib(nibName: "ObservationsDetailsCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "ObservationDetailsCell")
    }
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "TabularDashBoardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    
    func configureView(dataSource:[VitalSignObservation])
    {
        self.dataSource = dataSource
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ObservationDetailsCell", forIndexPath: indexPath) as! ObservationsDetailsCell
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        let observation = dataSource[indexPath.row]
        cell.configureCell(observation)
        return cell;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 145;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ObservationsDetailsCell?
        
            let mainStoryboard = UIStoryboard(name: "PatientMenu", bundle: NSBundle.mainBundle())
                let observationDetails : ObservationViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ObservationMaintenance") as! ObservationViewController
                observationDetails.observation = cell?.getObservation()
                let navigationController : UINavigationController? = UINavigationController(rootViewController: observationDetails)
                navigationController?.modalPresentationStyle = UIModalPresentationStyle.FormSheet

                self.delegate?.EditObservation(navigationController!)

    }
}
