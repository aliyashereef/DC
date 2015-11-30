//
//  ObservationViewController.swift
//  vitalsigns
//
//  Created by Noureen on 07/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit



    class ObservationViewController: UIViewController , ObservationDelegate {
        @IBOutlet weak var observationSegmentedView: UISegmentedControl!

        @IBOutlet weak var childView: UIView!
        var generalObservationView : GeneralObservationView!
        //var commaScoreView:CommaScoreView!
        var observation:VitalSignObservation!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        observation = VitalSignObservation()
        generalObservationView = (GeneralObservationView.instanceFromNib() as! GeneralObservationView)
        generalObservationView.commonInit(observation)
        generalObservationView.delegate = self
        //generalObservationView.layer.borderWidth = 1
//        commaScoreView = CommaScoreView.instanceFromNib() as! CommaScoreView
//        commaScoreView.commonInit(observation)
//        commaScoreView.delegate=self
        Helper.displayInChildView(generalObservationView, parentView: childView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelClick(sender: AnyObject) {
        //self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

//        @IBAction func indexChange(sender: UISegmentedControl) {
//            switch(sender.selectedSegmentIndex)
//            {
//            case 0:
//                generalObservationView.configureView(self.observation)
//                displayChildView(generalObservationView)
//            case 1:
//                displayChildView(commaScoreView)
//            default:
//                print("no default value is present", terminator: "")
//            }
//        }
    
        //MARK: Delegate implementation
        
//        func RowSelectedWithList(dataSource:[KeyValue],tag:Int,selectedValue:KeyValue?,title:String)
//        {
//            let selectionController = SelectionView(nibName:"SelectionView",bundle:nil)
//            selectionController.configureView(dataSource,tag: tag,selectedValue: selectedValue,title: title)
//            selectionController.delegate = self
//            self.navigationController?.pushViewController(selectionController, animated: true)
//            
//        }
        
        func TakeObservationInput(viewController:UIAlertController)
        {
            self.presentViewController(viewController, animated: true)
            {
                let textView = viewController.view.viewWithTag(10) as! UITextField
                print(textView)
            }
        }
        
//        func RowSelectedWithObject(dataSource:KeyValue ,tag:Int)
//        {
//            switch(tag)
//            {
//            case CommaScoreTableRow.EyesOpen.rawValue:
//                commaScoreView.eyesOpen = dataSource
//            case CommaScoreTableRow.BestVerbalResponse.rawValue:
//                commaScoreView.bestVerbalResponse = dataSource
//            case CommaScoreTableRow.BestMotorResponse.rawValue:
//                commaScoreView.bestMotorResponse = dataSource
//            case CommaScoreTableRow.RightPupil.rawValue:
//                commaScoreView.pupilRight = dataSource
//            case CommaScoreTableRow.LeftPupil.rawValue:
//                commaScoreView.pupilLeft = dataSource
//            case CommaScoreTableRow.ArmsMovement.rawValue:
//                commaScoreView.limbMovementArms = dataSource
//            case CommaScoreTableRow.LegsMovement.rawValue:
//                commaScoreView.limbMovementLegs = dataSource
//            default:
//                NSLog("Do nothing")
//            }
//            commaScoreView.Refresh()
//            navigationController?.popViewControllerAnimated(true)
//        }
        
        
        @IBAction func unwindToObservationTestList(sender:UIStoryboardSegue)
        {
//            if let sourceViewController = sender.sourceViewController as? ObservationViewController
//            {
//                observationList.append(sourceViewController.generalObservationView.observation)
//                Helper.VitalSignObservationList.append(sourceViewController.generalObservationView.observation)
//            }
//            observationList.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedAscending })
//            graphicalDashBoardView.reloadView(observationList)
//            // tabularDashBoardView.configureView(observationList)
                    let alert = UIAlertView()
                    alert.title = "my title"
                    alert.message = "things are working slowly"
                    alert.addButtonWithTitle("Ok")
                    alert.delegate = self
                    alert.show()
        }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let _ = sender as? UIBarButtonItem
        {
            generalObservationView.prepareObjects()
            //commaScoreView.prepareObject()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
