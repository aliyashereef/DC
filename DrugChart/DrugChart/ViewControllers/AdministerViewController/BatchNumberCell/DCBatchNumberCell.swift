//
//  DCBatchNumberCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/23/15.
//
//

import UIKit

public protocol BatchNumberCellDelegate {
    
    func batchNumberFieldSelected()
}

class DCBatchNumberCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var batchNumberTextField: UITextField!
    var delegate: BatchNumberCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if let delegate = self.delegate {
            delegate.batchNumberFieldSelected()
        }
    }

}
