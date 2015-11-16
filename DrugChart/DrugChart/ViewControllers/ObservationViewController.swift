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
    override func viewDidLoad() {
        super.viewDidLoad()
        generalObservationView = (GeneralObservationView.instanceFromNib() as! GeneralObservationView)
        generalObservationView.commonInit()
        commaScoreView = CommaScoreView.instanceFromNib() as! CommaScoreView
        commaScoreView.commonInit()
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
        
        func RowSelected(dataSource:[KeyValue])
        {
            let selectionController = SelectionView(nibName:"SelectionView",bundle:nil)
            selectionController.dataSource=dataSource
            self.navigationController?.pushViewController(selectionController, animated: true)
            
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
