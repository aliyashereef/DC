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
    var filterObservations = [VitalSignObservation]()
    var graphicalDashBoardView:GraphicalDashBoardView!
    var graphDisplayView: GraphDisplayView = GraphDisplayView.Day
    
    var graphEndDate:NSDate = NSDate()
    var graphStartDate:NSDate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observationList.appendContentsOf(Helper.VitalSignObservationList)
        
        // display the titles
        displayTitle()
        
        // initialize the graphical view
        graphicalDashBoardView = GraphicalDashBoardView.instanceFromNib() as! GraphicalDashBoardView
        Helper.displayInChildView(graphicalDashBoardView, parentView: parentView)
        showData()
        //detecting the swipe gesture
        //------------right  swipe gestures in view--------------//
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("rightSwiped"))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        //-----------left swipe gestures in view--------------//
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("leftSwiped"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    func showData()
    {
        dateLabel.text = graphStartDate.getFormattedDate()
        filterObservations = observationList.filter( { return $0.date >= graphStartDate && $0.date < graphEndDate} )
        graphicalDashBoardView.displayData(filterObservations,graphDisplayView: graphDisplayView , graphStartDate: graphStartDate , graphEndDate: graphEndDate)
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
            showData()
        case 1:
            graphDisplayView = GraphDisplayView.Week
            showData()
        case 2:
            graphDisplayView = GraphDisplayView.Month
            showData()
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
        showData()
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
         swipeGraphDate(false)
    }
    
    func leftSwiped()
    {
        swipeGraphDate(true)
    }
    
    
    func swipeGraphDate(goForward:Bool)
    {
        
        switch(graphDisplayView)
        {
            case .Day:
                graphEndDate = graphStartDate
                graphStartDate =  NSCalendar.currentCalendar().dateByAddingUnit(.Day,
                    value: goForward == true ? 1:-1,
                    toDate:graphStartDate ,
                    options: NSCalendarOptions(rawValue: 0))!
            
            case .Week:
                graphEndDate = graphStartDate
                graphStartDate =  NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day,
                    value: goForward == true ? 6:-6,
                    toDate:graphStartDate ,
                    options: NSCalendarOptions(rawValue: 0))!
            
            case .Month:
                graphEndDate = graphStartDate
                graphStartDate =  NSCalendar.currentCalendar().dateByAddingUnit(.Month,
                    value: goForward == true ? 1:-1,
                    toDate:graphStartDate ,
                    options: NSCalendarOptions(rawValue: 0))!
            
            default:
            print("DO NOTHING")
        }
        showData()
    }
    
}
