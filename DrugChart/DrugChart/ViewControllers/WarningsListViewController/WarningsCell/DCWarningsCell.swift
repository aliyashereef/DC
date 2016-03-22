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
    @IBOutlet weak var warningDescriptionTextTrailingSpace: NSLayoutConstraint!
    @IBOutlet weak var warningDescriptionTextTopSpace: NSLayoutConstraint!
    
    func populateWarningsCellWithWarningsObject(warning : DCWarning) {
        
        titleLabel.text = warning.title
        descriptionLabel.textColor = UIColor.blackColor()
        descriptionLabel.text = warning.detail
        warningDescriptionTextTrailingSpace.constant = 47.0
        warningDescriptionTextTopSpace.constant = 5.0
        if warning.severity == MILD_KEY {
            warningImageView.image = UIImage.init(named: "WarningMild")
        } else if warning.severity == SEVERE_KEY {
            warningImageView.image = UIImage.init(named: "WarningSevere")
        }
        self.layoutIfNeeded()
    }
    
    func populateCellWithOverrideReasonObject(reason:NSString) {
        
        descriptionLabel.textColor = UIColor(forHexString: "#676767")
        warningDescriptionTextTrailingSpace.constant = 20.0
        warningDescriptionTextTopSpace.constant = 0.0
        descriptionLabel.text = reason as String

    }
}
