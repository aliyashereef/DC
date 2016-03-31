//
//  DCInterventionAddResolveTextViewCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 31/03/16.
//
//

import UIKit

class DCInterventionAddResolveTextViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var reasonOrResolveTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initializeTextView(placeHolderString : String) {
        
        reasonOrResolveTextView.text = placeHolderString
        reasonOrResolveTextView.textColor = UIColor.lightGrayColor()
        reasonOrResolveTextView?.delegate = self
    }

    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderString
            textView.textColor = UIColor.lightGrayColor()
        }
    }

}
