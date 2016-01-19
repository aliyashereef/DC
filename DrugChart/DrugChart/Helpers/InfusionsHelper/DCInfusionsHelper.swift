//
//  DCInfusionsHelper.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/12/16.
//
//

import UIKit

class DCInfusionsHelper: NSObject {
    
    static func routesAndInfusionsSectionCountForSelectedRoute(route : NSString, infusion : DCInfusion) -> NSInteger {
        
        //get section count from the route selected,
        if (self.routeIsIntravenous(route)) {
            if (infusion.administerAsOption != nil) {
                if (infusion.administerAsOption == BOLUS_INJECTION) {
                    return SectionCount.eThirdSection.rawValue
                } else if (infusion.administerAsOption == DURATION_BASED_INFUSION) {
                    return SectionCount.eFourthSection.rawValue
                } else {
                    return SectionCount.eSecondSection.rawValue
                }
            } else {
                return SectionCount.eSecondSection.rawValue
            }
        } else {
            return SectionCount.eFirstSection.rawValue
        }
    }
    
    static func routeIsIntravenous(route : NSString) -> Bool {
        
        return route.containsString("Intravenous")
    }

}
