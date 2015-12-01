//
//  UITextField+Utilities.swift
//  mobilecore
//
//  copied from ios-Native application
//  Copyright © 2015 EMIS Health. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    func configureForNumericInput() {
        
        //PrintF(.Verbose)
        
        clearButtonMode = .WhileEditing
        keyboardType = .NumbersAndPunctuation
        returnKeyType = .Done
        autocapitalizationType = .None
        autocorrectionType = .No
        enablesReturnKeyAutomatically = true
        
    }
    
    func configureForDefaultInput() {
        
        //PrintF(.Verbose)
        
        clearButtonMode = .WhileEditing
        keyboardType = .Default
        returnKeyType = .Done
        autocapitalizationType = .None
        autocorrectionType = .No
        enablesReturnKeyAutomatically = true
        
    }
    
    func configureForNamePhoneInput() {
        
        //PrintF(.Verbose)
        
        clearButtonMode = .WhileEditing
        keyboardType = .NamePhonePad
        returnKeyType = .Done
        autocapitalizationType = .None
        autocorrectionType = .No
        enablesReturnKeyAutomatically = true
        
    }
    
}