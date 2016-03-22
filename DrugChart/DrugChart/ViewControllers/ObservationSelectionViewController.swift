//
//  ObservationSelectionViewController.swift
//  DrugChart
//
//  Created by Noureen on 26/11/2015.
//
//

import UIKit

class ObservationSelectionViewController: PatientViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    let observationIdentifier = "ObservationIdentifier"
    var delegate:ObservationDelegate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: observationIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

   
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(observationIdentifier, forIndexPath: indexPath)
        
        
        let option = DashBoardAddOption(rawValue: indexPath.row + 1 )!
        switch(option)
        {
        case DashBoardAddOption.VitalSign:
            cell.textLabel?.text = "Vital Signs"
        case DashBoardAddOption.GCS:
            cell.textLabel?.text = "Glasgow Comma Score (GCS)"
        case DashBoardAddOption.NEWS:
            cell.textLabel?.text = "National Early Warning Score (NEWS)"
        }
        // Configure the cell...

        return cell
    }
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // now show the modal dialog to take the input
        let option = DashBoardAddOption(rawValue: indexPath.row + 1)!
        switch(option)
        {
        case DashBoardAddOption.VitalSign:
            let mainStoryboard = UIStoryboard(name: "PatientMenu", bundle: NSBundle.mainBundle())
            let observationDetails : ObservationViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ObservationViewController") as! ObservationViewController
            observationDetails.patient = patient
            let navigationController : UINavigationController? = UINavigationController(rootViewController: observationDetails)
            if(UIDevice.currentDevice().userInterfaceIdiom == .Pad)
            {
                observationDetails.tag = DataEntryObservationSource.VitalSignAddIPad
            }
            else if(UIDevice.currentDevice().userInterfaceIdiom  == .Phone)
            {
                observationDetails.tag = DataEntryObservationSource.VitalSignAddIPhone
            }
            navigationController?.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            delegate?.ShowModalNavigationController(navigationController!)
        case DashBoardAddOption.GCS:
            let mainStoryboard = UIStoryboard(name: "PatientMenu", bundle: NSBundle.mainBundle())
            let commaDetails : CommaScoreViewController = mainStoryboard.instantiateViewControllerWithIdentifier("CommaScoreViewController") as! CommaScoreViewController
            let navigationController : UINavigationController? = UINavigationController(rootViewController: commaDetails)
            navigationController?.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            delegate?.ShowModalNavigationController(navigationController!)
        case DashBoardAddOption.NEWS:
            
            let mainStoryboard = UIStoryboard(name: "PatientMenu", bundle: NSBundle.mainBundle())
            let observationDetails : ObservationViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ObservationViewController") as! ObservationViewController
            observationDetails.patient = patient
            let navigationController : UINavigationController? = UINavigationController(rootViewController: observationDetails)
            if(UIDevice.currentDevice().userInterfaceIdiom == .Pad)
            {
                observationDetails.tag = DataEntryObservationSource.NewsIPad
            }
            else if(UIDevice.currentDevice().userInterfaceIdiom  == .Phone)
            {
                observationDetails.tag = DataEntryObservationSource.NewsIPhone
            }
            navigationController?.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            delegate?.ShowModalNavigationController(navigationController!)
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
