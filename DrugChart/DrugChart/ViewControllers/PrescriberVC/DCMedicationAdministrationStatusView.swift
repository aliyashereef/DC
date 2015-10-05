//
//  DCMedicationAdministrationStatusView.swift
//  DrugChart
//
//  Created by Muhammed Shaheer on 01/10/15.
//
//

import UIKit

@objc protocol DCMedicationAdministrationStatusProtocol:class {
    
    func administerMedicationWithMedicationSlots (medicationSLotDictionary: NSDictionary, atIndexPath indexPath: NSIndexPath ,withWeekDate date : NSDate)
}

class DCMedicationAdministrationStatusView: UIView {
    
    var medicationSLotDictionary: NSDictionary?
    var medicationSlot: DCMedicationSlot?
    var currentIndexPath: NSIndexPath?
    var weekdate : NSDate?
    weak var delegate:DCMedicationAdministrationStatusProtocol?

    @IBOutlet var administerButton: UIButton?
    
    
    
    @IBAction func administerButtonClicked (sender: UIButton ) {
        
        //delegate?.administerButtonClickedForViewTag(self.tag, atIndexPath: currentIndexPath!)
        if let slotDictionary = medicationSLotDictionary {
            delegate?.administerMedicationWithMedicationSlots(slotDictionary, atIndexPath: currentIndexPath!, withWeekDate: weekdate!)
        }
    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
