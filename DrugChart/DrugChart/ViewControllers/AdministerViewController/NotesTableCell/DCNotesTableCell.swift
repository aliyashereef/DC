//
//  NotesTableCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/23/15.
//
//

import UIKit

class DCNotesTableCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var notesTextView: UITextView!
    
    override func awakeFromNib() {
        notesTextView.text = NSLocalizedString("NOTES", comment: "notes hint")
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if (textView.text == NSLocalizedString("NOTES", comment: "")) {
            textView.textColor = UIColor.blackColor()
            textView.text = EMPTY_STRING
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if (textView.text == EMPTY_STRING) {
            textView.textColor = UIColor.getColorForHexString("#8f8f95")
            textView.text = NSLocalizedString("NOTES", comment: "")
        }
    }
    
}
