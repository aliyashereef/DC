//
//  VitalsignDashboard.swift
//  vitalsigns
//
//  Created by Noureen on 09/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit


class VitalsignDashboard: PatientViewController , ObservationDelegate,UIPopoverPresentationControllerDelegate {

//    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var parentView: UIView!
    var observationList = [VitalSignObservation]()
    var graphicalDashBoardView:GraphicalDashBoardView!
    var graphDisplayView: GraphDisplayView = GraphDisplayView.Day
    var graphDate:NSDate = NSDate()
    override func viewDidLoad() {
        super.viewDidLoad()
        observationList.appendContentsOf(Helper.VitalSignObservationList)
        graphicalDashBoardView = GraphicalDashBoardView.instanceFromNib() as! GraphicalDashBoardView
        graphicalDashBoardView.commonInit()
        graphicalDashBoardView.reloadView(observationList,graphDisplayView: graphDisplayView , graphDate: graphDate)
        Helper.displayInChildView(graphicalDashBoardView, parentView: parentView)
        self.displayTitle()
        
        //detecting the swipe gesture
        //------------right  swipe gestures in view--------------//
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("rightSwiped"))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        //-----------left swipe gestures in view--------------//
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("leftSwiped"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        //-----------down swipe gestures in view--------------//
        let swipeDown = UISwipeGestureRecognizer(target: self, action: Selector("downSwiped"))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
        
        //-----------up swipe gestures in view--------------//
        let swipeUp = UISwipeGestureRecognizer(target: self, action: Selector("upSwiped"))
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        self.view.addGestureRecognizer(swipeUp)
        showGraphDate()
    }

    func showGraphDate()
    {
        dateLabel.text = graphDate.getFormattedDate()
    }
    
    func displayTitle()
    {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            var titleView:DCOneThirdCalendarNavigationTitleView?
            titleView = NSBundle.mainBundle().loadNibNamed("DCOneThirdCalendarNavigationTitleView", owner: self, options: nil)[0] as? DCOneThirdCalendarNavigationTitleView
            titleView!.populateViewWithPatientName(patient.patientName, nhsNumber:patient.nhs, dateOfBirth: patient.dob, age: patient.age)
            self.navigationItem.titleView = titleView;
        }
        else
        {
            var titleView:DCCalendarNavigationTitleView?
            titleView = NSBundle.mainBundle().loadNibNamed("DCCalendarNavigationTitleView", owner: self, options: nil)[0] as? DCCalendarNavigationTitleView
            titleView!.populateViewWithPatientName(patient.patientName, nhsNumber:patient.nhs, dateOfBirth: patient.dob, age: patient.age)
            self.navigationItem.titleView = titleView
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func indexChange(sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex)
        {
        case 0:
            graphDisplayView = GraphDisplayView.Day
            graphicalDashBoardView.reloadView(observationList,graphDisplayView: graphDisplayView , graphDate: graphDate)
        case 1:
            graphDisplayView = GraphDisplayView.Week
            graphicalDashBoardView.reloadView(observationList,graphDisplayView: graphDisplayView , graphDate: graphDate)
        case 2:
            graphDisplayView = GraphDisplayView.Month
            graphicalDashBoardView.reloadView(observationList,graphDisplayView: graphDisplayView , graphDate: graphDate)
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
        graphicalDashBoardView.reloadView(observationList,graphDisplayView: graphDisplayView , graphDate: graphDate)
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
            let popOverController:UIPopoverPresentationController = controller.popoverPresentationController!
            popOverController.delegate = self
            //controller.preferredContentSize = CGSizeMake(50, 100)
            controller.delegate = self
        }
        
        else if let tabularViewController:TabularViewController = segue.destinationViewController as? TabularViewController
        {
             tabularViewController.observationList = observationList
        }
    }
    
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    
    //MARK: swipe gestures
    func rightSwiped()
    {
        print("right swiped ")
    }
    
    func leftSwiped()
    {
        print("left swiped ")
    }
    
    func downSwiped()
    {
        print("down swiped ")
    }
    
    func upSwiped()
    {
        print("Up swiped ")
    }

}
