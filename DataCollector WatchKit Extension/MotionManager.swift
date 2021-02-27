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
    func updateMotionData(_ motionManager: MotionManager, gravCor: Cordinates, rotRateCor: Cordinates, userAccCor: Cordinates, attDes: AttitudeDes)
}

class MotionManager
{
    //MARK: Variable initialization
    let motionManager = CMMotionManager()
    
    var gravCor: Cordinates?
    var rotRateCor: Cordinates?
    var userAccCor: Cordinates?
    var attDes: AttitudeDes?
    
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
        gravCor = Cordinates(x: deviceMotion.gravity.x, y: deviceMotion.gravity.y, z: deviceMotion.gravity.y)
        
        userAccCor = Cordinates(x: deviceMotion.userAcceleration.x, y: deviceMotion.userAcceleration.y, z: deviceMotion.userAcceleration.y)

        attDes = AttitudeDes(roll: deviceMotion.attitude.roll, pitch: deviceMotion.attitude.pitch, yaw: deviceMotion.attitude.yaw)
        
        rotRateCor = Cordinates(x: deviceMotion.rotationRate.x, y: deviceMotion.rotationRate.y, z: deviceMotion.rotationRate.y)
        
        let timestamp = Date().currentTimeMillis()
        
        os_log("Motion: %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@",
               String(timestamp),
               String(gravCor!.x),
               String(gravCor!.y),
               String(gravCor!.z),
               String(userAccCor!.x),
               String(userAccCor!.y),
               String(userAccCor!.z),
               String(rotRateCor!.x),
               String(rotRateCor!.y),
               String(rotRateCor!.z),
               String(attDes!.roll),
               String(attDes!.pitch),
               String(attDes!.yaw))
        
        updateMetricsDelegate()
        
    }
    
    func updateMetricsDelegate()
    {
        delegate?.updateMotionData(self, gravCor: gravCor!, rotRateCor: rotRateCor!, userAccCor: userAccCor!, attDes: attDes!)
    }
}
