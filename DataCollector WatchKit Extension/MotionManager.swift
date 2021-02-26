//
//  MotionManager.swift
//  DataCollector WatchKit Extension
//
//  Created by Krystian Rodzaj on 26/02/2021.
//

import Foundation
import CoreMotion
import os.log

extension Date
{
    func currentTimeMillis() -> Int64
    {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

protocol MotionManagerDelegate: class {
    func updateMotionData(_ motionManager: MotionManager, gravStr: String, rotRateStr: String, userAccStr: String, attStr: String)
}

class MotionManager
{
    //MARK: Variable initialization
    let motionManager = CMMotionManager()
    
    var gravStr = ""
    var rotRateStr = ""
    var userAccStr = ""
    var attStr = ""
    
    let sampleInterval = 1.0 / 50
    
    weak var delegate: MotionManagerDelegate?
    
    
    //MARK: Function
    func startMeasurement()
    {
        if !motionManager.isDeviceMotionAvailable
        {
            print("There is any motion device !")
            return
        }
        
        os_log("Start measurement!");
        
        motionManager.deviceMotionUpdateInterval = sampleInterval
        
        motionManager.startDeviceMotionUpdates(to: OperationQueue()) { (deviceMotion: CMDeviceMotion?, err: Error?) in
            if err != nil
            {
                print("Encountered error:" + err!.localizedDescription)
            }
            
            if deviceMotion != nil
            {
                self.saveDeviceMotion(deviceMotion!)
            }
        }
    }
    
    func stopMeasurement()
    {
        if motionManager.isDeviceMotionAvailable
        {
            motionManager.stopDeviceMotionUpdates()
        }
    }
        
    func saveDeviceMotion(_ deviceMotion: CMDeviceMotion)
    {
        gravStr = String(format: "X: %.1f Y: %.1f Z: %.1f",
                            deviceMotion.gravity.x, deviceMotion.gravity.y, deviceMotion.gravity.y)
        
        userAccStr = String(format: "X: %.1f Y: %.1f Z: %.1f",
                            deviceMotion.userAcceleration.x, deviceMotion.userAcceleration.y, deviceMotion.userAcceleration.y)

        attStr = String(format: "r: %.1f p: %.1f y: %.1f",
                            deviceMotion.attitude.roll, deviceMotion.attitude.pitch, deviceMotion.attitude.yaw)
        
        rotRateStr = String(format: "X: %.1f Y: %.1f Z: %.1f",
                            deviceMotion.rotationRate.x, deviceMotion.rotationRate.y, deviceMotion.rotationRate.y)
        
        let timestamp = Date().currentTimeMillis()
        
        os_log("Motion: %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@",
               String(timestamp),
               String(deviceMotion.gravity.x),
               String(deviceMotion.gravity.y),
               String(deviceMotion.gravity.z),
               String(deviceMotion.userAcceleration.x),
               String(deviceMotion.userAcceleration.y),
               String(deviceMotion.userAcceleration.z),
               String(deviceMotion.rotationRate.x),
               String(deviceMotion.rotationRate.y),
               String(deviceMotion.rotationRate.z),
               String(deviceMotion.attitude.roll),
               String(deviceMotion.attitude.pitch),
               String(deviceMotion.attitude.yaw))
        
        updateMetricsDelegate()
        
    }
    
    func updateMetricsDelegate()
    {
        delegate?.updateMotionData(self, gravStr: gravStr, rotRateStr: rotRateStr, userAccStr: userAccStr, attStr: attStr)
    }
}
