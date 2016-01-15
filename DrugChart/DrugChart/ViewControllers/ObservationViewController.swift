//
//  ObservationViewController.swift
//  vitalsigns
//
//  Created by Noureen on 07/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit



    class ObservationViewController: UIViewController  {
        @IBOutlet weak var observationSegmentedView: UISegmentedControl!

        @IBOutlet weak var childView: UIView!
        var generalObservationView : GeneralObservationView!
        var observation:VitalSignObservation!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        observation = VitalSignObservation()
        if(generalObservationView == nil)
        {
            generalObservationView = (GeneralObservationView.instanceFromNib() as! GeneralObservationView)
            generalObservationView.observation = observation
        }
        //generalObservationView.delegate = self
        Helper.displayInChildView(generalObservationView, parentView: childView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name:UIKeyboardDidShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
    }
    
    func configureView(observation:VitalSignObservation,showobservatioType:ShowObservationType)
    {
      self.observation = observation
      if(generalObservationView == nil)
       {
            generalObservationView = (GeneralObservationView.instanceFromNib() as! GeneralObservationView)
       }
        generalObservationView.configureView(observation, showobservatioType: showobservatioType)
    }
        
    func keyboardWasShown(sender: NSNotification) {
        let info:NSDictionary = sender.userInfo!
        let kbSize:CGSize = (info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue.size)!
        let contentInsets:UIEdgeInsets = UIEdgeInsetsMake(0.0,0.0,kbSize.height,0.0)
        generalObservationView.tableView.contentInset = contentInsets
        generalObservationView.tableView.scrollIndicatorInsets = contentInsets
        
    }
    
    func keyboardWillHide(sender: NSNotification) {
        
        let contentInsets:UIEdgeInsets  = UIEdgeInsetsZero;
        generalObservationView.tableView.contentInset = contentInsets;
        generalObservationView.tableView.scrollIndicatorInsets = contentInsets;
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
