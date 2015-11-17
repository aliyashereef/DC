//
//  ObservationViewController.swift
//  vitalsigns
//
//  Created by Noureen on 07/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit



    class ObservationViewController: UIViewController ,RowSelectedDelegate{
        @IBOutlet weak var observationSegmentedView: UISegmentedControl!

        @IBOutlet weak var childView: UIView!
        var generalObservationView : GeneralObservationView!
        var commaScoreView:CommaScoreView!
        var observation:VitalSignObservation!
    override func viewDidLoad() {
        super.viewDidLoad()
        observation = VitalSignObservation()
        generalObservationView = (GeneralObservationView.instanceFromNib() as! GeneralObservationView)
        generalObservationView.commonInit(observation)
        commaScoreView = CommaScoreView.instanceFromNib() as! CommaScoreView
        commaScoreView.commonInit(observation)
        commaScoreView.delegate=self
        displayChildView(generalObservationView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelClick(sender: AnyObject) {
        //self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

        @IBAction func indexChange(sender: UISegmentedControl) {
            switch(sender.selectedSegmentIndex)
            {
            case 0:
                generalObservationView.configureView(self.observation)
                displayChildView(generalObservationView)
            case 1:
                displayChildView(commaScoreView)
            default:
                print("no default value is present", terminator: "")
            }
        }
    
        
        func displayChildView(subView:UIView)
        {
            for subUIView in childView.subviews {
                subUIView.removeFromSuperview()
            }
            
            subView.frame = childView.frame
            subView.frame.origin.x = 0
            subView.frame.origin.y = 0
            childView.addSubview(subView)
        }
    
        
        //MARK: Delegate implementation
        
        func RowSelectedWithList(dataSource:[KeyValue],tag:Int,selectedValue:KeyValue?)
        {
            let selectionController = SelectionView(nibName:"SelectionView",bundle:nil)
            selectionController.configureView(dataSource,tag: tag,selectedValue: selectedValue)
            selectionController.delegate = self
            self.navigationController?.pushViewController(selectionController, animated: true)
            
        }
        
        func RowSelectedWithObject(dataSource:KeyValue ,tag:Int)
        {
            switch(tag)
            {
            case CommaScoreTableRow.EyesOpen.rawValue:
                commaScoreView.eyesOpen = dataSource
            case CommaScoreTableRow.BestVerbalResponse.rawValue:
                commaScoreView.bestVerbalResponse = dataSource
            case CommaScoreTableRow.BestMotorResponse.rawValue:
                commaScoreView.bestMotorResponse = dataSource
            default:
                NSLog("Do nothing")
            }
            commaScoreView.Refresh()
            navigationController?.popViewControllerAnimated(true)
        }
        
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let _ = sender as? UIBarButtonItem
        {
            generalObservationView.prepareObjects()
            commaScoreView.prepareObject()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
