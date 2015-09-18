//
//  DCWarningsCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/15/15.
//
//

import UIKit

let MAX_WIDTH : CGFloat = 280.0

@objc class DCWarningsCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func populateWarningsCellWithWarningsObject(warning : DCWarning) {
        
        titleLabel.text = warning.title
        descriptionLabel.text = warning.detail
        self.layoutIfNeeded()
    }
}
