//
//  Double.swift
//  DrugChart
//
//  Created by Noureen on 17/12/2015.
//
//

import Foundation

extension Double {
    var cleanValue: String {
        return self % 1 == 0 ? String(format: "%.0f", self) : String(self)
    }
}