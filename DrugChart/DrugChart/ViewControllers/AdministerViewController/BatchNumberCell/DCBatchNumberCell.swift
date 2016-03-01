//
//  DCBatchNumberCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/23/15.
//
//

import UIKit

@objc public protocol BatchCellDelegate {
    
    func enteredBatchDetails(batch : String)
    func batchNumberFieldSelectedAtIndexPath(indexPath: NSIndexPath)
}

class DCBatchNumberCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var batchNumberTextField: UITextField!
    var batchDelegate : BatchCellDelegate?
    var selectedIndexPath : NSIndexPath?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if let delegate = batchDelegate {
            delegate.batchNumberFieldSelectedAtIndexPath(selectedIndexPath!)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if let delegate = batchDelegate {
            delegate.enteredBatchDetails(textField.text!)
        }
    }

}
