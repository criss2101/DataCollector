//
//  StructsFile.swift
//  DataCollector WatchKit Extension
//
//  Created by Krystian Rodzaj on 27/02/2021.
//

import Foundation

class SensorData: Codable
{
    let timeStamp: Int64
    let gravData: Cordinates
    let userAccData: Cordinates
    let attData: Cordinates
    let rotRateData: Cordinates
    var label: Int
    
    init(timeStamp: Int64, gravData: Cordinates, userAccData: Cordinates, attData: Cordinates, rotRateData: Cordinates)
    {
        self.timeStamp = timeStamp
        self.gravData = gravData
        self.userAccData = userAccData
        self.attData = attData
        self.rotRateData = rotRateData
        self.label = -1
    }
}

class Cordinates: Codable
{
    var x: Double //For attitude data: pitch
    var y: Double //For attitude data: roll
    var z: Double //For attitude data: yaw
    
    init(x: Double, y: Double, z: Double)
    {
        self.x = x
        self.y = y
        self.z = z
    }
    
    func resetValue()
    {
        self.x = 0
        self.y = 0
        self.z = 0
    }
}

class SettingsContainer: Codable
{
    var saveAllSensors: Bool = false
    var onlyPhone: Bool = false
    var onlyWatch: Bool = false
    var bothDevices: Bool = true
}


