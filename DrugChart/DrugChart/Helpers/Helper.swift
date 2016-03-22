//
//  Helper.swift
//  vitalsigns
//
//  Created by Noureen on 17/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import Foundation
import UIKit
class Helper
{
    static func displayInChildView(subView:UIView , parentView:UIView)
    {
        for subUIView in parentView.subviews {
            subUIView.removeFromSuperview()
        }
        
        subView.frame = parentView.frame
        subView.frame.origin.x = 0
        subView.frame.origin.y = 0
        parentView.addSubview(subView)
    }
    
    static func getCareRecordCodes() ->String
    {
//        let codes = String(format:"%@,%@,%@,%@,%@,%@,%@,%@",Constant.CODE_PULSE_RATE,Constant.CODE_OXYGEN_SATURATION,Constant.CODE_RESPIRATORY_RATE,Constant.CODE_ORAL_TEMPERATURE,Constant.CODE_BLOOD_PRESSURE,Constant.CODE_ADDITIONAL_OXYGEN,Constant.CODE_AVPU,Constant.CODE_NEWS)
//        
         let codes = String(format:"%@,%@,%@,%@,%@",Constant.CODE_PULSE_RATE,Constant.CODE_OXYGEN_SATURATION,Constant.CODE_RESPIRATORY_RATE,Constant.CODE_ORAL_TEMPERATURE,Constant.CODE_BLOOD_PRESSURE)
        
        return codes
    }
}

