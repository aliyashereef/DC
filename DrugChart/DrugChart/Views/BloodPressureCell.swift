//
//  BloodPressureCell.swift
//  vitalsigns
//
//  Created by Noureen on 06/11/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import UIKit

class BloodPressureCell: UITableViewCell ,ButtonAction{

    @IBOutlet weak var systolicValue: NumericTextField!
    @IBOutlet weak var diastolicValue: NumericTextField!
    var delegate:CellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        systolicValue.addTarget(self, action: "valueChanged", forControlEvents: UIControlEvents.EditingChanged)
    }
   
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func valueChanged()
    {
        delegate?.cellValueChanged(tag)
    }
    
    func isValueEntered() -> Bool
    {
        return systolicValue.isValueEntered()
    }

    func  getSystolicValue() ->Double
    {
        return (systolicValue.text as NSString!).doubleValue
    }
    
    func  getDiastolicValue() ->Double
    {
        return (diastolicValue.text as NSString!).doubleValue
    }
    
    func  getSystolicStringValue() ->String
    {
        return systolicValue.text!
    }
    
    func  getDiastolicStringValue() ->String
    {
        return diastolicValue.text!
    }
    func nextButtonAction()
    {
        if(self.systolicValue.isFirstResponder())
        {
            self.diastolicValue.becomeFirstResponder()
        }
        else if(self.diastolicValue.isFirstResponder())
        {
            delegate?.moveNext(self.tag)
        }
    }
    
    func previousButtonAction()
    {
        delegate?.movePrevious(self.tag)
    }
    
    func getFocus()
    {
        self.systolicValue.becomeFirstResponder()
    }
    
    func configureCell(disableNavigation:Bool)
    {
        systolicValue.buttonActionDelegate = self
        diastolicValue.buttonActionDelegate = self
        systolicValue.initialize(disableNavigation)
        diastolicValue.initialize(disableNavigation)
    }
}
