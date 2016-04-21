//
//  AdministratingDoseTableViewCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 19/04/16.
//
//

import UIKit

class DCAdministratingDoseTableViewCell: UITableViewCell, UITextFieldDelegate{

    @IBOutlet weak var doseTextField: UITextField!
    var doseString: String?
    var textViewUpdated: TextViewUpdated = { value in }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func textFieldStringDidChange(sender: AnyObject) {
        
        if doseTextField.text == doseString {
            self.textViewUpdated(false)
        } else {
            self.textViewUpdated(true)
        } 
    }
}
