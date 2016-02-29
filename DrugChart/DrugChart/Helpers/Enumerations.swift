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
    case Respiratory, SpO2, Temperature , BloodPressure , Pulse /*, BM*/
    
    static var count: Int {  // I called this "maximumRawValue" in the post
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
}


enum ObservationType:Int
{
    case Date
    case Respiratory  , SpO2, Temperature , BloodPressure , Pulse , AdditionalOxygen , AVPU, News /*, BM*/
    
    static var count: Int {  // I called this "maximumRawValue" in the post
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
}

enum ShowObservationType:Int
{
    case All, None, Respiratory  , SpO2, Temperature , BloodPressure , Pulse , AdditionalOxygen , AVPU /*, BM*/
    
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
    case LineChart,BarChart
    
    static var count: Int {  // I called this "maximumRawValue" in the post
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
}
enum ObservationTabularViewRow:Int
{
    case Respiratory = 1 , SPO2 , Temperature , BloodPressure , Pulse,/* BM ,*/ News , CommaScore
    
    static var count: Int {  // I called this "maximumRawValue" in the post
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
}

enum GraphDisplayView:Int
{
    case Day = 1 , Week , Month
    
    static var count: Int {  // I called this "maximumRawValue" in the post
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
}

enum DashBoardAddOption:Int
{
    case VitalSign = 1 , GCS , NEWS
    
    static var count: Int {  // I called this "maximumRawValue" in the post
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
}


enum DataEntryObservationSource: Int
{
    case VitalSignAddIPad = 1 ,VitalSignAddIPhone , VitalSignEditIPhone ,VitalSignEditIPad , NewsIPad , NewsIPhone
    
    static var count: Int {  // I called this "maximumRawValue" in the post
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
}



