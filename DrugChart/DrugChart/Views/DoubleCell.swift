//
//  DoubleCell.swift
//  vitalsigns
//
//  Created by Noureen on 01/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit

class DoubleCell: UITableViewCell ,UITextFieldDelegate {

    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var value: UITextField!
    var delegate:CellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        value.delegate=self
        // Initialization code
        value.textAlignment = NSTextAlignment.Right
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Mark: Done button on keyboard
    func addDoneButtonOnKeyboard()
    {
        let toolbar = UIToolbar()
        toolbar.barStyle = .Default
        toolbar.translucent = true
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "doneButtonAction")
        let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        fixedSpaceButton.width = 20
        
        let previousButton  = UIBarButtonItem(image :UIImage(named:"previous"), style: .Plain, target: self, action: "previousButtonAction")
        let nextButton  = UIBarButtonItem(image :UIImage(named:"next"), style: .Plain, target: self, action: "nextButtonAction")
        
        if(self.tag == Constant.MINIMUM_OBSERVATION_ROW)
        {
            previousButton.enabled = false
        }
        else if(self.tag == Constant.MAXIMUM_OBSERVATION_ROW)
        {
            nextButton.enabled = false
        }
        toolbar.setItems([previousButton, fixedSpaceButton, nextButton, flexibleSpaceButton, doneButton], animated: false)
        toolbar.userInteractionEnabled = true
        self.value.inputAccessoryView = toolbar
    }
    
    func doneButtonAction()
    {
        self.value.resignFirstResponder()
    }
    func nextButtonAction()
    {
        delegate?.moveNext(self.tag)
    }
    func previousButtonAction()
    {
        delegate?.movePrevious(self.tag)
    }
    
    func getFocus()
    {
        self.value.becomeFirstResponder()
    }

    func  getValue() ->Double
    {
        return (value.text as NSString!).doubleValue
    }
    
    func isValueEntered() -> Bool
    {
        if (value.text == nil || value.text!.isEmpty == true)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func configureCell(title:String , valuePlaceHolderText:String , selectedValue:Double! )
    {
        titleText.text = title;
        value.placeholder = valuePlaceHolderText
        if selectedValue != nil
        {
            value.text = String(selectedValue)
        }
        addDoneButtonOnKeyboard()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        value.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String)
        -> Bool
    {
        // We ignore any change that doesn't add characters to the text field.
        // These changes are things like character deletions and cuts, as well
        // as moving the insertion point.
        //
        // We still return true to allow the change to take place.
        if string.characters.count == 0 {
            return true
        }
        
        // Check to see if the text field's contents still fit the constraints
        // with the new content added to it.
        // If the contents still fit the constraints, allow the change
        // by returning true; otherwise disallow the change by returning false.
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        return prospectiveText.containsOnlyCharactersIn("0123456789.") &&
            prospectiveText.characters.count <= 5
    }
    
    

}
