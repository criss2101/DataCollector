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
    let attData: AttCordinates
    let rotRateData: Cordinates
    
    init(timeStamp: Int64, gravData: Cordinates, userAccData: Cordinates, attData: AttCordinates, rotRateData: Cordinates )
    {
        self.timeStamp = timeStamp
        self.gravData = gravData
        self.userAccData = userAccData
        self.attData = attData
        self.rotRateData = rotRateData
    }
}

class Cordinates: Codable
{
    let x: Double
    let y: Double
    let z: Double
    
    init(x: Double, y: Double, z: Double)
    {
        self.x = x
        self.y = y
        self.z = z
    }
}

class AttCordinates: Codable
{
    let roll: Double
    let pitch: Double
    let yaw: Double
    
    init(roll: Double, pitch: Double, yaw: Double)
    {
        self.roll = roll
        self.pitch = pitch
        self.yaw = yaw
    }
}

class SettingsContainer
{
    var saveAllSensors: Bool = true
    var onlyPhone: Bool = false
    var onlyWatch: Bool = false
    var bothDevices: Bool = true
}


