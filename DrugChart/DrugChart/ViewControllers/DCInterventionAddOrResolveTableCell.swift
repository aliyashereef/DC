//
//  DCInterventionAddOrResolveTableCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 30/03/16.
//
//

import UIKit

class DCInterventionAddOrResolveTableCell: UITableViewCell ,UITextViewDelegate {

    @IBOutlet weak var createdByNameLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var actionNameTitleLabel: UILabel!
    @IBOutlet weak var actionDateTitleLabel: UILabel!
    @IBOutlet weak var reasonTextLabel: UILabel!
    
    override func awakeFromNib() {

        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
