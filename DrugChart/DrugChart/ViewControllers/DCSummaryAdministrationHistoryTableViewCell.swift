//
//  DCSummaryAdministrationHistoryTableViewCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 14/03/16.
//
//

import UIKit

class DCSummaryAdministrationHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
