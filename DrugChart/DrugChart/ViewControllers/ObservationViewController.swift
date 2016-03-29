//
//  ObservationViewController.swift
//  vitalsigns
//
//  Created by Noureen on 07/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit




class ObservationViewController: PatientViewController,ObservationDelegate   {
        @IBOutlet weak var observationSegmentedView: UISegmentedControl!
        @IBOutlet weak var hiddenButton: UIButton!
        @IBOutlet weak var oneThirdHidden: UIButton!
        @IBOutlet weak var hidden1: UIButton!
        @IBOutlet weak var childView: UIView!
        var generalObservationView : GeneralObservationView!
        var observation:VitalSignObservation!
        var tag:DataEntryObservationSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hiddenButton.hidden = true
        self.hidden1.hidden = true
        self.oneThirdHidden.hidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        observation = VitalSignObservation()
        if(generalObservationView == nil)
        {
            generalObservationView = (GeneralObservationView.instanceFromNib() as! GeneralObservationView)
            generalObservationView.uitag = tag
            generalObservationView.delegate = self
            generalObservationView.observation = observation
        }
        Helper.displayInChildView(generalObservationView, parentView: childView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name:UIKeyboardDidShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
    }
    
   func configureView(observation:VitalSignObservation,showobservatioType:ShowObservationType,tag:DataEntryObservationSource)
    {
      self.observation = observation
      self.tag = tag
      if(generalObservationView == nil)
       {
            generalObservationView = (GeneralObservationView.instanceFromNib() as! GeneralObservationView)
            generalObservationView.delegate = self
       }
        generalObservationView.configureView(observation, showobservatioType: showobservatioType,tag:tag)
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
        
    @IBAction func doneClick(sender: AnyObject) {
        saveObject(sender)
    }
        
    // Navigation
    func ShowModalNavigationController(navigationController: UINavigationController) {
        self.presentViewController(navigationController, animated: true){}
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveObject(sender:AnyObject)
    {
        generalObservationView.prepareObjects()
        let parser = VitalSignParser()
        if(tag == DataEntryObservationSource.VitalSignEditIPad || tag == DataEntryObservationSource.VitalSignEditIPhone)
        {
            parser.updateVitalSignObservations(patient.patientId, requestBody: generalObservationView.observation.asJSON(), onCompletion:saveCompleted)
        }
        else
        {
            parser.saveVitalSignObservations(patient.patientId, requestBody: generalObservationView.observation.asJSON(), onCompletion:saveCompleted)
        }
        
    }
    func saveCompleted( savedSuccessfully:Bool)
    {
        if(savedSuccessfully)
        {
            switch(self.tag!)
            {
            case DataEntryObservationSource.VitalSignAddIPhone, DataEntryObservationSource.VitalSignAddIPad:
                performSegueWithIdentifier("unwindToObservationList",sender:nil)
            case DataEntryObservationSource.VitalSignEditIPhone:
                performSegueWithIdentifier("unwindToOneThirdTabularView",sender:nil)
            case DataEntryObservationSource.VitalSignEditIPad:
                performSegueWithIdentifier("unwindToTabularView",sender:nil)
            case DataEntryObservationSource.NewsIPhone,DataEntryObservationSource.NewsIPad:
                performSegueWithIdentifier("unwindToObservationList",sender:nil)
            }
        }
    }
    
}
