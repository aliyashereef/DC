//
//  DCInfusionCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/13/16.
//
//

import UIKit

class DCInfusionCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }

}
