//
//  RowSeletedDelegate.swift
//  vitalsigns
//
//  Created by Noureen on 10/11/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import Foundation
import UIKit

protocol RowSelectedDelegate
{
  //  func RowSelectedWithList(dataSource:[KeyValue],tag:Int,selectedValue:KeyValue?,title:String)
     func RowSelectedWithObject(dataSource:KeyValue ,tag:Int)
}

extension RowSelectedDelegate
{
    //func RowSelectedWithList(dataSource:[KeyValue],tag:Int,selectedValue:KeyValue?,title:String){}
    func RowSelectedWithObject(dataSource:KeyValue ,tag:Int){}
}