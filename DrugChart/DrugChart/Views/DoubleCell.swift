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
    @IBOutlet weak var numericValue: NumericTextField!
    
    
    
    var delegate:CellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        numericValue.textAlignment = NSTextAlignment.Right
        numericValue.buttonActionDelegate = self
        numericValue.addTarget(self, action: "valueChanged:", forControlEvents: UIControlEvents.EditingChanged)
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    func valueChanged(textField: AnyObject)
    {
        delegate?.cellValueChanged(tag,object: textField)
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
        self.numericValue.becomeFirstResponder()
    }

    func  getValue() ->Double
    {
       // return (numericValue.text as NSString!).doubleValue
       return numericValue.getValue()
    }
    
    func getStringValue() ->String
    {
        return numericValue.text!
    }
    
    func isValueEntered() -> Bool
    {
        return numericValue.isValueEntered()
    }
    
    func setCellBackgroundColor(color:UIColor)
    {
        self.backgroundView = nil
        self.backgroundColor = color
        self.contentView.backgroundColor = color
        self.titleText.backgroundColor = color
        self.numericValue.backgroundColor = color
        self.selectedBackgroundView = nil
    }
    
//    func isValueEntered() -> Bool
//    {
//        if (value.text == nil || value.text!.isEmpty == true)
//        {
//            return false
//        }
//        else
//        {
//            return true
//        }
//    }
    
    
    func configureCell(title:String , valuePlaceHolderText:String , selectedValue:Double! , disableNavigation:Bool)
    {
        titleText.text = title
        numericValue.placeholder = valuePlaceHolderText
        if selectedValue != nil
        {
            numericValue.text = String(selectedValue)
        }
        self.numericValue.tag = self.tag
        self.numericValue.initialize(disableNavigation)
    }
}
