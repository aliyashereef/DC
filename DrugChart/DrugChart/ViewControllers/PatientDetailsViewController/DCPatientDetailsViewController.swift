//
//  PatientDetailsViewController.swift
//  DrugChart
//
//  Created by Jagajith M Kalarickal on 24/05/16.
//
//

import UIKit

class DCPatientDetailsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var patientDetailsTableView: UITableView!

    let HEADER_HEIGHT : CGFloat = 32.0
    let ADDRESS_CELL_HEIGHT : CGFloat = 112.0
    let PHONE_EMAIL_CELL_HEIGHT: CGFloat = 112.0
    let ALLERGY_CELL_HEIGHT : CGFloat = 30.0
    let HEADER_FONT_SIZE : CGFloat = 12.0
    let HEADER_FONT_COLOR : String = "#686868"
    
    var patientDetails : DCPatient?
    let sampleKnownAllergiesArray = ["Latex 14-Nov-1961", "Peanuts 15-Aug-1997", "Penicillin 02-Oct-2003"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        patientDetailsTableView.tableFooterView = UIView(frame: CGRect.zero)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureNavigationBar() {
        //Navigation bar title string
        self.title = patientDetails?.patientName
        // Navigation bar cancel button
        let cancelButton : UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItems = [cancelButton]
//        if (appDelegate.windowState == DCWindowState.halfWindow || appDelegate.windowState == DCWindowState.oneThirdWindow) {
//            self.navigationItem.rightBarButtonItems = [cancelButton]
//        } else {
//            let negativeSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
//            negativeSpacer.width = -12
//            self.navigationItem.rightBarButtonItems = [negativeSpacer,cancelButton]
//        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0,1 :
            return 1
        case 2:
            return sampleKnownAllergiesArray.count
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("DCPatientAddressTableViewCell") as? DCPatientAddressTableViewCell
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("DCPatientPhoneEmailTableViewCell") as? DCPatientPhoneEmailTableViewCell
            return cell!
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("DCPatientAllergiesTableViewCell") as? DCPatientAllergiesTableViewCell
            cell?.allergyLabel.text = sampleKnownAllergiesArray[indexPath.row]
            cell!.separatorInset = UIEdgeInsetsMake(0.0, 1000000, 0.0, 0.0)
            return cell!
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "" //Will set in willDisplayHeade rView delegate function
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFontOfSize(HEADER_FONT_SIZE)
        header.textLabel?.textColor = UIColor(forHexString: HEADER_FONT_COLOR)
        switch section {
        case 0:
            header.textLabel?.text = "Address"
        case 1:
            header.textLabel?.text = "Phone & Email"
        case 2:
            header.textLabel?.text = "Known Allergies"
        default:
            header.textLabel?.text = EMPTY_STRING
        }
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HEADER_HEIGHT
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return ADDRESS_CELL_HEIGHT
        case 1:
            return PHONE_EMAIL_CELL_HEIGHT
        case 2:
            return ALLERGY_CELL_HEIGHT
        default:
            return 0
        }
    }
    func doneButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
