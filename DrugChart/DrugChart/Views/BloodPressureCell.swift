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
    }
   
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    
    func configureCell()
    {
        systolicValue.buttonActionDelegate = self
        diastolicValue.buttonActionDelegate = self
        systolicValue.initialize()
        diastolicValue.initialize()
    }
}
