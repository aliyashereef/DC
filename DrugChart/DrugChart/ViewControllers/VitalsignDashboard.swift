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
        graphicalDashBoardView = GraphicalDashBoardView.instanceFromNib() as! GraphicalDashBoardView
        Helper.displayInChildView(graphicalDashBoardView, parentView: parentView)
        graphicalDashBoardView.delegate = self
        swipeGraphDate(false,flipDateMode: true)
        // display the titles
        displayTitle()
        
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
        switch(graphDisplayView)
        {
            case .Day:
                dateLabel.text = graphStartDate.getFormattedDate()
            default:
                dateLabel.text = String(format:"%@ - %@", graphStartDate.getFormattedDate() , graphEndDate.getFormattedDate())
        }
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
            swipeGraphDate(false, flipDateMode: true)
        case 1:
            graphDisplayView = GraphDisplayView.Week
            swipeGraphDate(false, flipDateMode: true)
        case 2:
            graphDisplayView = GraphDisplayView.Month
            swipeGraphDate(false, flipDateMode: true)
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
    
    func GetLatestObservation(dataType:DashBoardRow)->VitalSignObservation!
    {
        switch(dataType)
        {
        case .Respiratory:
            let filterObject = observationList.filter( { return $0.respiratory != nil } ).last
            return filterObject
        case .Temperature:
            let filterObject = observationList.filter( { return $0.temperature != nil } ).last
            return filterObject
        case .Pulse:
            let filterObject = observationList.filter( { return $0.pulse != nil } ).last
            return filterObject
        case .SpO2:
            let filterObject = observationList.filter( { return $0.spo2 != nil } ).last
            return filterObject
        case .BM:
            let filterObject = observationList.filter( { return $0.bm != nil } ).last
            return filterObject
        case .BloodPressure:
            let filterObject = observationList.filter( { return $0.bloodPressure != nil } ).last
            return filterObject
        default:
            return nil
        }
     
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
        swipeGraphDate(false,flipDateMode:false)
    }
    
    func leftSwiped()
    {
        swipeGraphDate(true,flipDateMode:false)
    }
    

    func swipeGraphDate(goForward:Bool , flipDateMode : Bool)
    {
        switch(graphDisplayView)
        {
            case .Day:
                if(flipDateMode)
                {
                    graphStartDate = graphEndDate
                }
                else{
                graphStartDate =  NSCalendar.currentCalendar().dateByAddingUnit(.Day,
                    value: goForward == true ? 1:-1,
                    toDate:graphStartDate ,
                    options: NSCalendarOptions(rawValue: 0))!
                graphEndDate = graphStartDate
            }
            case .Week:
                if(flipDateMode)
                {
                    graphStartDate =  NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day,
                        value: goForward == true ? 6:-6,
                        toDate: graphEndDate ,
                        options: NSCalendarOptions(rawValue: 0))!
                }
                else
                {
                    if(goForward)
                    {
                        graphStartDate = graphEndDate
                        graphEndDate =  NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day,
                            value:  6,
                            toDate:  graphStartDate ,
                            options: NSCalendarOptions(rawValue: 0))!
                    }
                    else
                    {
                    graphEndDate = graphStartDate
                    graphStartDate =  NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day,
                        value: goForward == true ? 6:-6,
                        toDate:  graphStartDate ,
                        options: NSCalendarOptions(rawValue: 0))!
                    }
                }
            case .Month:
                if(flipDateMode)
                {
                    graphStartDate =  NSCalendar.currentCalendar().dateByAddingUnit(.Month,
                        value: goForward == true ? 1:-1,
                        toDate:graphEndDate ,
                        options: NSCalendarOptions(rawValue: 0))!
                }
                else
                {
                graphEndDate = graphStartDate
                graphStartDate =  NSCalendar.currentCalendar().dateByAddingUnit(.Month,
                    value: goForward == true ? 1:-1,
                    toDate:graphStartDate ,
                    options: NSCalendarOptions(rawValue: 0))!
            }
            default:
            print("DO NOTHING")
        }
        
        graphStartDate = graphStartDate.minTime()
        graphEndDate = graphEndDate.maxTime()
        
        showData()
    }
    
}
