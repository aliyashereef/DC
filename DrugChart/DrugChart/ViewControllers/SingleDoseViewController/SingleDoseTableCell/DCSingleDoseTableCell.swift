//
//  DCSingleDoseTableCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 2/17/16.
//
//

import UIKit

class DCSingleDoseTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
