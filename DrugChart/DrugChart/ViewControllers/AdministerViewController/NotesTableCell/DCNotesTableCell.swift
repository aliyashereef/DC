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
    
    var noteType : NSString?
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
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if let delegate = self.delegate {
            delegate.notesSelected(true, withIndexPath: selectedIndexPath!)
        }
        if (textView.text == hintText()) {
            textView.textColor = UIColor.blackColor()
            textView.text = EMPTY_STRING
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        textView.textColor = UIColor.blackColor()
        if let delegate = self.delegate {
            delegate.enteredNote(textView.text)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if (textView.text != hintText()) {
            if let delegate = self.delegate {
                delegate.enteredNote(textView.text)
            }
        }
        if (textView.text == EMPTY_STRING) {
            textView.textColor = UIColor(forHexString: "#8f8f95")
            textView.text = hintText()
        }
    }
    
    func hintText() -> String {
        
        //initial hint text in table cell
        var hint : String
        if let _ = notesType {
            if (notesType! == eNotes) {
                hint = NSLocalizedString("NOTES", comment: "notes hint")
            } else {
                hint = NSLocalizedString("REASON" , comment: "reason hint")
            }
        } else {
            hint = self.noteType as! String
        }
        return hint
    }
    
}
