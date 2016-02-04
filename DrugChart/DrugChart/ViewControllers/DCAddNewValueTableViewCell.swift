//
//  AddNewValueTableViewCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 02/02/16.
//
//

import UIKit

class DCAddNewValueTableViewCell: UITableViewCell {

    @IBOutlet weak var newValueTextField: UITextField!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var unitValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        newValueTextField.becomeFirstResponder()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
