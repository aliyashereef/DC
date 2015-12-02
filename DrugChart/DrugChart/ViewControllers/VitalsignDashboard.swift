//
//  VitalsignDashboard.swift
//  vitalsigns
//
//  Created by Noureen on 09/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit


class VitalsignDashboard: PatientViewController , ObservationDelegate {

//    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var parentView: UIView!
    var observationList = [VitalSignObservation]()
    var graphicalDashBoardView:GraphicalDashBoardView!
    var tabularDashBoardView:ExcelTabularView!
    override func viewDidLoad() {
        super.viewDidLoad()
        observationList.appendContentsOf(Helper.VitalSignObservationList)
        graphicalDashBoardView = GraphicalDashBoardView.instanceFromNib() as! GraphicalDashBoardView
        graphicalDashBoardView.commonInit()
        graphicalDashBoardView.reloadView(observationList)
        Helper.displayInChildView(graphicalDashBoardView, parentView: parentView)
        tabularDashBoardView = ExcelTabularView.instanceFromNib() as! ExcelTabularView
        tabularDashBoardView.delegate = self
        tabularDashBoardView.configureView(observationList)
        self.displayTitle()
    }

    func displayTitle()
    {
        var titleView:DCCalendarNavigationTitleView?
        titleView = NSBundle.mainBundle().loadNibNamed("DCCalendarNavigationTitleView", owner: self, options: nil)[0] as? DCCalendarNavigationTitleView
        
       titleView!.populateViewWithPatientName(patient.patientName, nhsNumber:patient.nhs, dateOfBirth: patient.dob, age: patient.age)
       self.navigationItem.titleView = titleView
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
        else if let sourceViewController = sender.sourceViewController as? CommaScoreViewController
        {
            observationList.append(sourceViewController.observation)
            Helper.VitalSignObservationList.append(sourceViewController.observation)
        }

        observationList.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedAscending })
        graphicalDashBoardView.reloadView(observationList)
       // tabularDashBoardView.configureView(observationList)
    }
    
    //Mark: Delegate Implementation
    func EditObservation(navigationController:UINavigationController)
    {
        self.presentViewController(navigationController, animated: false, completion: nil)
    }
    
    func EditObservationViewController(viewController:UIViewController)
    {
        self.presentViewController(viewController, animated: false, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller:ObservationSelectionViewController = segue.destinationViewController as?ObservationSelectionViewController
        {
            controller.delegate = self
        }
    }
    
}
