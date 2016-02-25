//
//  Constants.swift
//  DrugChart
//
//  Created by Noureen on 20/11/2015.
//
//

import Foundation

class Constant
{
    static let RESPIRATORY :String = "Respiratory"
    static let SPO2 :String = "SPO2"
    static let TEMPERATURE :String = "Temperature"
    static let BLOOD_PRESSURE :String = "Blood Pressure"
    static let PULSE :String = "Pulse"
    static let BM :String = "BM"
    static let NEWS :String = "News"
    static let COMMA_SCORE :String = "Comma Score"
    static let MINIMUM_OBSERVATION_ROW: Int = 1
    static let MAXIMUM_OBSERVATION_ROW: Int = 5
    static let FULL_SCREEN_GRAPH_HORIZONTAL_LINES = 10
    static let BORDER_WIDTH : CGFloat  = 0.10
    static let CORNER_RADIUS :CGFloat = 2
    static let CELL_BORDER_COLOR :CGColor = UIColor.lightGrayColor().CGColor
    static let SELECTION_CELL_BACKGROUND_COLOR:UIColor = UIColor(forHexString: "#fafafa")
    static let VITAL_SIGN_LOGGER_INDICATOR = "[Vital Sign]"
    static let GREEN_COLOR = UIColor(forHexString: "#CEE5C8")
    static let AMBER_COLOR = UIColor(forHexString: "#F5BB86")
    static let RED_COLOR = UIColor(forHexString: "#EE836D")
    static let NO_COLOR = UIColor.whiteColor()
}