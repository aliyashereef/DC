//
//  PatientDetailsViewController.swift
//  DrugChart
//
//  Created by Jagajith M Kalarickal on 24/05/16.
//
//

import UIKit

class DCPatientDetailsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureNavigationBar() {
        //Navigation bar title string
        self.title = "Patient Details"
        // Navigation bar cancel button
        let cancelButton : UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(doneButtonPressed))
        if (appDelegate.windowState == DCWindowState.halfWindow || appDelegate.windowState == DCWindowState.oneThirdWindow) {
            self.navigationItem.rightBarButtonItems = [cancelButton]
        } else {
            let negativeSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
            negativeSpacer.width = -12
            self.navigationItem.rightBarButtonItems = [negativeSpacer,cancelButton]
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    func doneButtonPressed() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
