//
//  DCInterventionAddResolveTextViewCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 31/03/16.
//
//

import UIKit

typealias TextViewUpdated = (Bool) -> Void

class DCInterventionAddResolveTextViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var reasonOrResolveTextView: UITextView!
    var placeHolderString : String?
    var textViewUpdated: TextViewUpdated = { value in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initializeTextView() {
        
        reasonOrResolveTextView.text = placeHolderString
        reasonOrResolveTextView.textColor = UIColor.lightGrayColor()
        reasonOrResolveTextView?.delegate = self
    }

    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() || textView.textColor == UIColor.redColor()  {
            if placeHolderString == textView.text {
                textView.text = nil
            }
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        
        if textView.text == EMPTY_STRING {
            self.textViewUpdated(false)
        } else {
            self.textViewUpdated(true)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderString
            textView.textColor = UIColor.lightGrayColor()
            self.textViewUpdated(false)
        }
    }

}
