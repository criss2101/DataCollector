//
//  StructsFile.swift
//  DataCollector WatchKit Extension
//
//  Created by Krystian Rodzaj on 27/02/2021.
//

import Foundation

struct Cordinates
{
    let x: Double;
    let y: Double;
    let z: Double;
    
    init(x: Double, y: Double, z: Double)
    {
        self.x = x
        self.y = y
        self.z = z
    }
}

struct AttitudeDes
{
    let roll: Double;
    let pitch: Double;
    let yaw: Double;
    
    init(roll: Double, pitch: Double, yaw: Double)
    {
        self.roll = roll
        self.pitch = pitch
        self.yaw = yaw
    }
}
