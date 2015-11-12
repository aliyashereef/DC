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
    override func awakeFromNib() {
        super.awakeFromNib()
        value.delegate=self
        // Initialization code
        value.textAlignment = NSTextAlignment.Right
//        addDoneButtonToKeyboard()
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first as UITouch! {
            value.resignFirstResponder()
        }
        super.touchesBegan(touches , withEvent:event)
    }
    
    
    func  getValue() ->Double
    {
        return (value.text as NSString!).doubleValue
    }
    
    func configureCell(title:String , valuePlaceHolderText:String )
    {
        titleText.text = title;
        value.placeholder = valuePlaceHolderText
    }
    
//    func addDoneButtonToKeyboard() {
//        var doneButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "hideKeyboard")
//        
//        var space:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
//        
//        var items = [AnyObject]()
//        items.append(space)
//        items.append(doneButton)
//        var toolbar = UIToolbar.new()
//        
//        toolbar.frame.size.height = 35
//        
//        toolbar.items = items
//        
//        value.inputAccessoryView = toolbar
//    }
    
//    func hideKeyboard() {
//        value.resignFirstResponder()
//    }

}
