//
//  VitalsignDashboard.swift
//  vitalsigns
//
//  Created by Noureen on 09/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit
import CocoaLumberjack

class VitalsignDashboard: PatientViewController , ObservationDelegate,UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var parentView: UIView!
    var observationList = [VitalSignObservation]()
    var filterObservations = [VitalSignObservation]()
    @IBOutlet weak var nextPage: UIButton!
    var graphicalDashBoardView:GraphicalDashBoardView!
    var graphDisplayView: GraphDisplayView = GraphDisplayView.Day
    var activityIndicator:UIActivityIndicatorView!
    
    var graphEndDate:NSDate = NSDate()
    @IBOutlet weak var previousPage: UIButton!
    var graphStartDate:NSDate = NSDate()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graphicalDashBoardView = GraphicalDashBoardView.instanceFromNib() as! GraphicalDashBoardView
        Helper.displayInChildView(graphicalDashBoardView, parentView: parentView)
        graphicalDashBoardView.delegate = self
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
        
        swipeGraphDate(false,flipDateMode: true)
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        orientationChanged()
    }
    
    func showData(fetchedObservations:[VitalSignObservation] )
    {
        observationList = fetchedObservations
        switch(graphDisplayView)
        {
            case .Day:
                dateLabel.text = graphStartDate.getFormattedDate()
            default:
                dateLabel.text = String(format:"%@ - %@", graphStartDate.getFormattedDate() , graphEndDate.getFormattedDate())
        }
        filterObservations = observationList.filter( { return $0.date >= graphStartDate && $0.date < graphEndDate} )
        graphicalDashBoardView.displayData(filterObservations,graphDisplayView: graphDisplayView , graphStartDate: graphStartDate , graphEndDate: graphEndDate)
        
        stopActivityIndicator(activityIndicator)
        
    }
    
    override func viewWillAppear(animated: Bool) {
     refreshGrid()
    }
    
    func displayTitle()
    {
        let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
        if (appDelegate.windowState == DCWindowState.halfWindow || appDelegate.windowState == DCWindowState.oneThirdWindow) {
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
        }
        else if let sourceViewController = sender.sourceViewController as? CommaScoreViewController
        {
            observationList.append(sourceViewController.observation)
        }

        observationList.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedAscending })
        showData(observationList)
    }
    
    //Mark: Delegate Implementation
    func ShowModalNavigationController(navigationController:UINavigationController)
    {
        self.presentViewController(navigationController, animated: false, completion: nil)
    }
    
    func ShowModalViewController(viewController:UIViewController)
    {
        self.presentViewController(viewController, animated: false, completion: nil)
    }

    func PushViewController(navigationController:UIViewController)
    {
        self.navigationController?.pushViewController(navigationController, animated: false)
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
       /* case .BM:
            let filterObject = observationList.filter( { return $0.bm != nil } ).last
            return filterObject*/
        case .BloodPressure:
            let filterObject = observationList.filter( { return $0.bloodPressure != nil } ).last
            return filterObject
    
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
    }
    
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    
    //Mark: Rotation gesture recognizer
    
    func orientationChanged()
    {
        refreshGrid()
    }
    
    func refreshGrid()
    {
        graphicalDashBoardView.collectionView.reloadData()
    }

    //MARK: swipe gestures
    
    @IBAction func rightSwiped()
    {
        swipeGraphDate(false,flipDateMode:false)
    }
    
    @IBAction func leftSwiped()
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
                        value: -6,
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
                    if(goForward)
                    {
                       graphStartDate = graphEndDate
                        graphEndDate =  NSCalendar.currentCalendar().dateByAddingUnit(.Month,
                            value:  1,
                            toDate:graphStartDate ,
                            options: NSCalendarOptions(rawValue: 0))!
                    }
                    else
                    {
                        graphEndDate = graphStartDate
                        graphStartDate =  NSCalendar.currentCalendar().dateByAddingUnit(.Month,
                            value: -1,
                            toDate:graphStartDate ,
                            options: NSCalendarOptions(rawValue: 0))!
                    }
            }
        }
        
        graphStartDate = graphStartDate.minTime()
        graphEndDate = graphEndDate.maxTime()
        graphicalDashBoardView.graphStartDate = graphStartDate
        graphicalDashBoardView.graphEndDate = graphEndDate
        graphicalDashBoardView.graphDisplayView = graphDisplayView
        
        // now do the FHIR call
        activityIndicator = startActivityIndicator(self.view) // show the activity indicator
        let parser = VitalSignParser()
        parser.getVitalSignsObservations(patient.patientId,commaSeparatedCodes:  Helper.getCareRecordCodes(),startDate:  graphStartDate , endDate:  graphEndDate,includeMostRecent:  true , onSuccess: showData)
    }
   
    @IBAction func show(sender: AnyObject) {
        let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
        if (appDelegate.windowState == DCWindowState.halfWindow || appDelegate.windowState == DCWindowState.oneThirdWindow) {
            let mainStoryboard = UIStoryboard(name: "PatientMenu", bundle: NSBundle.mainBundle())
            let tabularView : OneThirdScreenTabularView = mainStoryboard.instantiateViewControllerWithIdentifier("OneThirdScreenTabularViewController") as! OneThirdScreenTabularView
            tabularView.patient = patient
            PushViewController(tabularView)
        }
        else
        {
            let mainStoryboard = UIStoryboard(name: "PatientMenu", bundle: NSBundle.mainBundle())
            let tabularView : TabularViewController = mainStoryboard.instantiateViewControllerWithIdentifier("TabularViewController") as! TabularViewController
            tabularView.patient = patient
            PushViewController(tabularView)
            
        }
    }
}
