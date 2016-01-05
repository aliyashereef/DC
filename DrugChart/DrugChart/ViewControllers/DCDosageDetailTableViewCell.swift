
//
//  DCDosageDetailTableViewCell.swift
//  DrugChart
//
//  Created by Shaheer on 11/12/15.
//
//

import UIKit

class DCDosageDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var dosageDetailDisplayCell: UILabel!
    @IBOutlet weak var dosageDetailCellLabel: UILabel!
    @IBOutlet weak var addNewDosageTextField: UITextField!
    @IBOutlet weak var dosageDetailValueLabel: UILabel!
    @IBOutlet weak var timePickerView: UIDatePicker!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
