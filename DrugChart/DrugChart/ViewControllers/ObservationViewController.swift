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
        var observation:VitalSignObservation!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        observation = VitalSignObservation()
        generalObservationView = (GeneralObservationView.instanceFromNib() as! GeneralObservationView)
        generalObservationView.commonInit(observation)
        generalObservationView.delegate = self
        Helper.displayInChildView(generalObservationView, parentView: childView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

        func TakeObservationInput(viewController:UIAlertController)
        {
            self.presentViewController(viewController, animated: true)
            {
                let textView = viewController.view.viewWithTag(10) as! UITextField
                print(textView)
            }
        }
        
        
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let _ = sender as? UIBarButtonItem
        {
            generalObservationView.prepareObjects()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
