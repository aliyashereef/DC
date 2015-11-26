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
    var observationList = [VitalSignObservation]()
    var graphicalDashBoardView:GraphicalDashBoardView!
    //var tabularDashBoardView:TabularDashBoardView!
    var tabularDashBoardView:ExcelTabularView!
    override func viewDidLoad() {
        super.viewDidLoad()
        observationList.appendContentsOf(Helper.VitalSignObservationList)
        graphicalDashBoardView = GraphicalDashBoardView.instanceFromNib() as! GraphicalDashBoardView
        graphicalDashBoardView.commonInit()
        graphicalDashBoardView.reloadView(observationList)
        Helper.displayInChildView(graphicalDashBoardView, parentView: parentView)
        tabularDashBoardView = ExcelTabularView.instanceFromNib() as! ExcelTabularView
        tabularDashBoardView.configureView(observationList)
        //tabularDashBoardView.delegate = self
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
            graphicalDashBoardView.reloadView(observationList)
        case 1:
            //tabularDashBoardView.configureView(observationList)
            tabularDashBoardView.reloadView(observationList)
            Helper.displayInChildView(tabularDashBoardView,parentView:parentView)
        default:
            print("no default value is present", terminator: "")
        }
    }

    
    @IBAction func unwindToObservationList(sender:UIStoryboardSegue)
    {
        if let sourceViewController = sender.sourceViewController as? ObservationViewController
        {
             observationList.append(sourceViewController.generalObservationView.observation)
            Helper.VitalSignObservationList.append(sourceViewController.generalObservationView.observation)
        }
        observationList.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedAscending })
        graphicalDashBoardView.reloadView(observationList)
       // tabularDashBoardView.configureView(observationList)
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
