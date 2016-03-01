//
//  DoubleCell.swift
//  vitalsigns
//
//  Created by Noureen on 01/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit

class DoubleCell: UITableViewCell ,ButtonAction{

    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var value: NumericTextField!
    var delegate:CellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        value.textAlignment = NSTextAlignment.Right
        value.buttonActionDelegate = self
        value.addTarget(self, action: "valueChanged", forControlEvents: UIControlEvents.EditingChanged)
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func valueChanged()
    {
        delegate?.cellValueChanged(tag)
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
    
    func getStringValue() ->String
    {
        return value.text!
    }
    
    func isValueEntered() -> Bool
    {
        return value.isValueEntered()
    }
    
    func configureCell(title:String , valuePlaceHolderText:String , selectedValue:Double! , disableNavigation:Bool)
    {
        titleText.text = title
        value.placeholder = valuePlaceHolderText
        if selectedValue != nil
        {
            value.text = String(selectedValue)
        }
        self.value.tag = self.tag
        self.value.initialize(disableNavigation)
    }
}
