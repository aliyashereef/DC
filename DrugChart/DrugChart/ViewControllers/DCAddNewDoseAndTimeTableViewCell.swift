//
//  DCAddNewDoseAndTimeTableViewCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 05/01/16.
//
//

import UIKit

class DCAddNewDoseAndTimeTableViewCell: UITableViewCell {

    @IBOutlet weak var newDosageTextField: UITextField!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
