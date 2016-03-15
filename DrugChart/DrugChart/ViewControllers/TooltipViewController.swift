//
//  TooltipViewController.swift
//  DrugChart
//
//  Created by Noureen on 11/03/2016.
//
//

import UIKit

class TooltipViewController: UIViewController {

    @IBOutlet weak var toolTip: UILabel!
    var toolTipText:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
     toolTip.text = toolTipText
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
