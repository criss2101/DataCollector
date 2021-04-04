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

protocol MotionManagerDelegate: class
{
    func updateMotionData(_ motionManager: MotionManager, sensorData: SensorData)
}

class MotionManager
{
    //MARK: Variable
    let motionManager = CMMotionManager()
    
    let sampleInterval = 1.0 / 100
    
    weak var delegate: MotionManagerDelegate?
    
    var timeStart: Int64 = 0
    
    
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
        timeStart = Date().currentTimeMillis()
        
    }
    
    func stopMeasurement()
    {
        os_log("Stop measurement!");
        if motionManager.isDeviceMotionAvailable
        {
            motionManager.stopDeviceMotionUpdates()
        }
    }
        
    func saveDeviceMotion(_ deviceMotion: CMDeviceMotion)
    {
        let timestamp = Date().currentTimeMillis() - timeStart
        
        let gravData = Cordinates(x: deviceMotion.gravity.x, y: deviceMotion.gravity.y, z: deviceMotion.gravity.z)
        
        let userAccData = Cordinates(x: deviceMotion.userAcceleration.x, y: deviceMotion.userAcceleration.y, z: deviceMotion.userAcceleration.z)

        let attData = AttCordinates(roll: deviceMotion.attitude.roll, pitch: deviceMotion.attitude.pitch, yaw: deviceMotion.attitude.yaw)
        
        let rotRateData = Cordinates(x: deviceMotion.rotationRate.x, y: deviceMotion.rotationRate.y, z: deviceMotion.rotationRate.z)
        
        updateMetricsDelegate(SensorData(timeStamp: timestamp, gravData: gravData, userAccData: userAccData, attData: attData, rotRateData: rotRateData))
    }
    
    func updateMetricsDelegate(_ sensorData: SensorData)
    {
        delegate?.updateMotionData(self, sensorData: sensorData)
    }
}
