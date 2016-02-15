//
//  DCProgressTimeView.swift
//  DrugChart
//
//  Created by aliya on 12/02/16.
//
//

import Foundation
import UIKit

class DCProgressTimeView : UIView {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    func updateTimeLabelWithDateAndTime (date : NSString , time : NSString) {
        self.dateLabel.text = date as String
        self.timeLabel.text = time as String
    }
}
