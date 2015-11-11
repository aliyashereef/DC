//
//  DCSchedulingDetailViewController.swift
//  DrugChart
//
//  Created by qbuser on 11/11/15.
//
//

import UIKit

class DCSchedulingDetailViewController: DCAddMedicationDetailViewController {

   // @IBOutlet weak var detailTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    func configureNavigationTitleView() {
        
        if (self.detailType == eSchedulingType) {
            self.title = NSLocalizedString("SCHEDULING", comment:"")
        }
    }
    
}
