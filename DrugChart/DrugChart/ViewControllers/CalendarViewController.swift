//
//  CalendarViewController.swift
//  DrugChart
//
//  Created by Noureen on 01/12/2015.
//
//

import UIKit

class CalendarViewController: UIViewController {

    @IBOutlet weak var dayYearPicker: MonthYearPickerView!
    var monthToSet:Int!
    var yearToSet:Int!
    
    var delegate:ObservationDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        dayYearPicker.setSelection(monthToSet, year: yearToSet)
        //dayYearPicker = MonthYearPickerView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setSelection(month:Int,year:Int)
    {
       monthToSet = month
        yearToSet = year
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func okClick(sender: AnyObject) {
        delegate?.DateSelected(dayYearPicker.getDate())
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
