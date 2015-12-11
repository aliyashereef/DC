//
//  DCWindowScreenState.swift
//  DrugChart
//
//  Created by Muhammed Shaheer on 10/12/15.
//
//

import UIKit


//enum DCWindowState : NSInteger {
//    case oneThirdWindow 
//    case halfWindow
//    case twoThirdWindow
//    case fullWindow
//}
//
//enum DCScreenOrientation : NSInteger {
//    
//    case portrait
//    case landscape
//}


class DCWindowScreenState: NSObject {

//    var windowState = DCWindowState.oneThirdWindow
//    var screenOrientation = DCScreenOrientation.landscape
    
    static let sharedInstance = DCWindowScreenState()
    
    // singleton method
    class func sharedWindowScreenState() -> DCWindowScreenState {
        return DCWindowScreenState.sharedInstance
    }
    
    private override init() {
        //This prevents others from using the default '()' initializer for this class.
    }
}
