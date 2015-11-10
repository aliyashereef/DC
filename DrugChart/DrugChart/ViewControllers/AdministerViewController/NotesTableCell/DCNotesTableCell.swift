//
//  NotesTableCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/23/15.
//
//

import UIKit

protocol NotesCellDelegate {
    
    func notesSelected(editing : Bool, withIndexPath indexPath : NSIndexPath)
    func enteredNote(note : String)
}

class DCNotesTableCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var notesTextView: UITextView!
    
    var notesType : NotesType?
    var delegate: NotesCellDelegate?
    var selectedIndexPath : NSIndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //func textViewDidBeginEditing(textView: UITextView) {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if let delegate = self.delegate {
            delegate.notesSelected(true, withIndexPath: selectedIndexPath!)
        }
        if (textView.text == getHintText()) {
            textView.textColor = UIColor.blackColor()
            textView.text = EMPTY_STRING
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        
        if (textView.text != getHintText()) {
            if let delegate = self.delegate {
                delegate.enteredNote(textView.text)
            }
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if let delegate = self.delegate {
            delegate.enteredNote(textView.text)
        }
        if let delegate = self.delegate {
            delegate.notesSelected(false, withIndexPath: selectedIndexPath!)
        }

        if (textView.text == EMPTY_STRING) {
            textView.textColor = UIColor.getColorForHexString("#8f8f95")
            textView.text = getHintText()
        }
    }
    
    func getHintText() -> String {
        
        //initial hint text in table cell
        var hint : String
        if (notesType! == eNotes) {
            hint = NSLocalizedString("NOTES", comment: "notes hint")
        } else {
            hint = NSLocalizedString("REASON" , comment: "reason hint")
        }
        return hint
    }
    
}
