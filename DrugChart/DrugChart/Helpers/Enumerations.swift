//
//  Enumerations.swift
//  vitalsigns
//
//  Created by Noureen on 09/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import Foundation



enum DashBoardRow:Int
{
    case Respiratory, SpO2, Temperature , BloodPressure , Pulse , BM
    
    static var count: Int {  // I called this "maximumRawValue" in the post
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
}


enum ObservationType:Int
{
    case Date
    case Respiratory  , SpO2, Temperature , BloodPressure , Pulse , BM
    
    static var count: Int {  // I called this "maximumRawValue" in the post
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
}
enum CellType:Int
{
    case Date,Time,Double,BloodPressure
    
    static var count: Int {  // I called this "maximumRawValue" in the post
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
}

enum CommaScoreTableSection:Int
{
    case Date,CommaScale,Pupils,LimbMovement
    
    static var count: Int {  // I called this "maximumRawValue" in the post
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
}

enum CommaScoreTableRow:Int
{
    case EyesOpen,BestVerbalResponse,BestMotorResponse,RightPupil,LeftPupil,ArmsMovement,LegsMovement
    
    static var count: Int {  // I called this "maximumRawValue" in the post
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
}
enum ChartType:Int
{
    case None,LineChart,BarChart
    
    static var count: Int {  // I called this "maximumRawValue" in the post
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
}
enum ObservationTabularViewRow:Int
{
    case Respiratory = 1 , SPO2 , Temperature , BloodPressure , Pulse, BM , News , CommaScore
    
    static var count: Int {  // I called this "maximumRawValue" in the post
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
}

