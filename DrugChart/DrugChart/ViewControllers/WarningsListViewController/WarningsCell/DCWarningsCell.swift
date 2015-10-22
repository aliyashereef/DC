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
    @IBOutlet weak var warningImageView: UIImageView!
    
    func populateWarningsCellWithWarningsObject(warning : DCWarning) {
        
        titleLabel.text = warning.title
        descriptionLabel.text = warning.detail
        if warning.severity == MILD_KEY {
            warningImageView.image = UIImage.init(named: "WarningMild")
        } else if warning.severity == SEVERE_KEY {
            warningImageView.image = UIImage.init(named: "WarningSevere")
        }
        self.layoutIfNeeded()
    }
}
