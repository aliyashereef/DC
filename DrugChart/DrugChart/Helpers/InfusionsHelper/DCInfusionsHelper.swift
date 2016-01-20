//
//  DCInfusionsHelper.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/12/16.
//
//

import UIKit

class DCInfusionsHelper: NSObject {
    
    static func infusionsTableViewSectionCount(administerOption : NSString?) -> NSInteger {
        
        //get section count from the route selected,
        if let option = administerOption {
            if (option == BOLUS_INJECTION) {
                return SectionCount.eSecondSection.rawValue
            } else if (option == DURATION_BASED_INFUSION) {
                return SectionCount.eThirdSection.rawValue
            } else {
                return SectionCount.eSecondSection.rawValue
            }
        } else {
            return SectionCount.eFirstSection.rawValue
        }
    }
}
