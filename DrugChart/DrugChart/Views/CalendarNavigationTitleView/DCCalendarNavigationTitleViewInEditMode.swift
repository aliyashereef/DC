//
//  DCCalendarNavigationTitleViewInEditMode.swift
//  DrugChart
//
//  Created by Jagajith M Kalarickal on 18/05/16.
//
//

import UIKit

class DCCalendarNavigationTitleViewInEditMode: UIView {

    @IBOutlet weak var selectedNumberLabel: UILabel!
    
    func populateWithDefaultCount(){
        selectedNumberLabel.text = "0 Selected"
    }
    
    func populateWithSelectedCount(count: NSInteger) {
        selectedNumberLabel.text = String(format: "\(count) Selected")
    }
}
