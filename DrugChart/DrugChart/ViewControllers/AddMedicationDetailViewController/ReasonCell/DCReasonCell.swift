//
//  DCReasonCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/17/15.
//
//

import UIKit

var REASON : String = "Reason"

@objc class DCReasonCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var reasonTextView: UITextView!
    
    override func awakeFromNib() {
        
        reasonTextView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    // MARK: TextView Delegate Methods
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        // textview begin editing
        if textView.text == REASON {
            textView.textColor = UIColor.blackColor()
            textView.text = EMPTY_STRING
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        //textview did end editing delegate action
        if textView.text == EMPTY_STRING {
            textView.textColor = UIColor(forHexString: "#8f8f95")
            textView.text = REASON
        }
    }
}
