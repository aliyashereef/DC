//
//  VitalsignDashboard.swift
//  vitalsigns
//
//  Created by Noureen on 09/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit

class VitalsignDashboard: DCBaseViewController , ObservationEditDelegate{

//    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var parentView: UIView!
    var temperatureList = [BodyTemperature]()
    var respiratoryList = [Respiratory]()
    var pulseList = [Pulse]()
    var spO2List = [SPO2]()
    var bmList = [BowelMovement]()
    var bpList = [BloodPressure]()
    var graphicalDashBoardView:GraphicalDashBoardView!
    var tabularDashBoardView:TabularDashBoardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphicalDashBoardView = GraphicalDashBoardView.instanceFromNib() as! GraphicalDashBoardView
        graphicalDashBoardView.commonInit()
        Helper.displayInChildView(graphicalDashBoardView, parentView: parentView)
        tabularDashBoardView = TabularDashBoardView.instanceFromNib() as! TabularDashBoardView
        tabularDashBoardView.commonInit()
        tabularDashBoardView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func indexChange(sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex)
        {
        case 0:
            Helper.displayInChildView(graphicalDashBoardView,parentView:parentView)
        case 1:
            Helper.displayInChildView(tabularDashBoardView,parentView:parentView)
        default:
            print("no default value is present", terminator: "")
        }
    }

    
    @IBAction func unwindToObservationList(sender:UIStoryboardSegue)
    {
        if let sourceViewController = sender.sourceViewController as? ObservationViewController
        {
            // add the temperature to the list
            temperatureList.append(sourceViewController.generalObservationView.obsBodyTemperature)
            respiratoryList.append(sourceViewController.generalObservationView.obsRespiratory)
            pulseList.append(sourceViewController.generalObservationView.obsPulse )
            spO2List.append(sourceViewController.generalObservationView.obsSPO2)
            bmList.append(sourceViewController.generalObservationView.obsBM)
            bpList.append(sourceViewController.generalObservationView.obsBP)
        }
        graphicalDashBoardView.reloadView(temperatureList, paramRespiratoryList: respiratoryList, paramPulseList: pulseList, paramSPO2List: spO2List , paramBMList: bmList, paramBPList: bpList)
        //collectionView.reloadData() : TODO : NEED TO WRITE A LOADING LINE HERE.
    }
    
    func EditObservation(navigationController:UINavigationController)
    {
        self.presentViewController(navigationController, animated: false, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
