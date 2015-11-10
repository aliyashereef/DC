//
//  DCVitalSignViewController.swift
//  DrugChart
//
//  Created by aliya on 03/11/15.
//
//

import Foundation

// Strings

let titleString : NSString = "Vital Signs"

// DCBaseViewController is a subclass for UIViewController

class DCVitalSignViewController: DCBaseViewController {
    
    override func viewDidLoad() {
        
        self.title = titleString as String
        super.viewDidLoad()
    }
}